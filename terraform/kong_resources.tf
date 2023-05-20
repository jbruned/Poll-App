resource "kong_route" "flask" {
  service_id = kong_service.flask.id
  name       = "flask"
  paths      = ["/"]
  protocols  = ["http"]
}

resource "kong_route" "protected" {
  service_id     = kong_service.flask.id
  name           = "protected"
  paths          = ["/api/v1/option", "/api/v1/poll"]
  methods        = ["POST", "DELETE"]
  protocols      = ["http"]
  strip_path     = false
  regex_priority = 1
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

resource "kong_consumer_key_auth" "consumer_key_auth" {
  consumer_id = kong_consumer.admin.id
  key         = "admin"
}

resource "kong_service" "flask" {
  name     = "flask"
  protocol = "http"
  host     = "backend"
  port     = 9000
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
