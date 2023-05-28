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
