terraform {
  required_providers {
    kong = {
      source  = "philips-labs/kong"
      version = "6.630.0"
    }
  }
}

provider "kong" {
	kong_admin_uri      = "http://${data.aws_lb.main.dns_name}${var.KONG_ADMIN_ROUTE}"
	# kong_api_key      = "admin"
	# kong_admin_token  = "admin"
}

resource "kong_certificate" "ssl" {
	count       = local.USE_SSL ? 1 : 0
	certificate = base64decode(var.SSL_CERT_BASE64)
	private_key = base64decode(var.SSL_KEY_BASE64)
}

resource "kong_service" "flask" {
	name     = "flask"
	protocol = "http"
	host     = data.aws_lb.backend.dns_name
	port     = var.EXPOSED_PORT
	//depends_on = [null_resource.set_kong_headers]
}

resource "kong_route" "flask" {
	service_id = kong_service.flask.id
	name       = "flask"
	paths      = ["/"]
	protocols  = local.USE_SSL ? ["http", "https"] : ["http"]
	snis       = local.USE_SSL ? [kong_certificate.ssl[0].id] : []
	strip_path = false
}

resource "kong_route" "protected" {
	service_id = kong_service.flask.id
	name       = "protected"
	paths = [
		"${var.API_BASE_URL}/option",
		"${var.API_BASE_URL}/poll"
	]
	methods        = ["POST", "DELETE"]
	protocols      = local.USE_SSL ? ["http", "https"] : ["http"]
	snis           = local.USE_SSL ? [kong_certificate.ssl[0].id] : []
	strip_path     = false
	regex_priority = 1
}

resource "kong_service" "admin" {
	name     = "admin"
	protocol = "http"
	host     = "localhost"
	port     = var.KONG_ADMIN_PORT
}

resource "kong_route" "admin" {
	service_id = kong_service.admin.id
	name       = "admin"
	paths      = [var.KONG_ADMIN_ROUTE]
	protocols  = local.USE_SSL ? ["http", "https"] : ["http"]
	snis       = local.USE_SSL ? [kong_certificate.ssl[0].id] : []
	strip_path = true
}

resource "kong_consumer" "admin" {
	username  = "admin"
	custom_id = "admin"
}

resource "kong_plugin" "key_auth_plugin" {
	name        = "key-auth"
	route_id    = kong_route.protected.id
	config_json = <<EOT
    {
		"key_in_header": true,
		"key_names": ["apikey"],
		"hide_credentials": false
    }
  EOT
}

resource "kong_plugin" "admin_login" {
	name        = "key-auth"
	route_id    = kong_route.admin.id
	config_json = <<EOT
    {
		"key_in_header": true,
		"key_names": ["apikey"],
		"hide_credentials": false
    }
  EOT
}

resource "kong_consumer_key_auth" "consumer_key_auth" {
	consumer_id = kong_consumer.admin.id
	key         = var.KONG_ADMIN_PASSWORD
}

resource "kong_plugin" "file_log" {
	name        = "file-log"
	config_json = <<EOT
	{
	  "path": "/logs/file-log.log",
	  "reopen": false
	}
	EOT
}

resource "null_resource" "wait_for_web" {
	triggers = {
		url        = data.aws_lb.main.dns_name
		run_always = timestamp()
	}
	depends_on = [kong_route.admin, kong_route.flask, kong_route.protected, kong_service.admin, kong_service.flask, kong_plugin.admin_login, kong_plugin.key_auth_plugin, kong_consumer.admin, kong_consumer_key_auth.consumer_key_auth]
	provisioner "local-exec" {
		# Wait until a request returns a 200 response
		# If the timeout is reached, the resource is marked as errored
		command = "curl --fail --retry-all-errors --silent --output /dev/null --retry 20 --retry-delay 5 --retry-connrefused ${local.USE_SSL ? "https" : "http"}://${data.aws_lb.main.dns_name}:${var.EXPOSED_PORT}"
	}
}

output "url" {
	value      = "${local.USE_SSL ? "https" : "http"}://${data.aws_lb.main.dns_name}"
	depends_on = [null_resource.wait_for_web]
}
