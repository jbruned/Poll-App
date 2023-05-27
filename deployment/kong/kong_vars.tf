variable "KONG_ADMIN_USER" {
	type = string
	default = "admin"
}

variable "KONG_ADMIN_PASSWORD" {
	type      = string
	sensitive = true
}

variable "API_BASE_URL" {
	type    = string
	default = "/api/v1"
}

variable "SSL_CERT_BASE64" {
	type      = string
	sensitive = true
	default   = ""
}

variable "SSL_KEY_BASE64" {
	type      = string
	sensitive = true
	default   = ""
}

locals {
	USE_SSL = var.SSL_CERT_BASE64 != "" && var.SSL_KEY_BASE64 != ""
}