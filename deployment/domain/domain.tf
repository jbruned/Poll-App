terraform {
	required_providers {
		ionosdeveloper = {
			source = "ionos-developer/ionosdeveloper"
			version = "0.0.1"
		}
	}
}

variable "DOMAIN" {
	type    = string
	default = "jorgebruned.com"
}

variable "SUBDOMAIN" {
	type    = string
	default = "pollapp"
}

data "ionosdeveloper_dns_zone" "main" {
	name = var.DOMAIN
}

resource "ionosdeveloper_dns_record" "cname" {
	zone_id = data.ionosdeveloper_dns_zone.main.id
	name    = "${var.SUBDOMAIN}.${data.ionosdeveloper_dns_zone.main.name}"
	type    = "CNAME"
	content = trimprefix(trimsuffix(data.aws_lb.main.dns_name, "/"), "http://")
	ttl     = 3600
}

output "public_url" {
	value = "http://${ionosdeveloper_dns_record.cname.name}"
}
