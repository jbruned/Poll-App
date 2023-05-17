variable "KONG_DB_SERVICE" {
  default = "kong-database"
}

variable "KONG_DB_POSTGRES_VERSION" {
  default = "15.1"
}

variable "KONG_DB_HOST" {
  default = "kong-database"
}

variable "KONG_DB_EXPOSED_PORT" {
  default = 10000
}

variable "KONG_DB_PORT" {
  default = 10001
}

variable "KONG_DB_NAME" {
  default = "kong"
}

variable "KONG_DB_USER" {
  default = "kong"
}

variable "KONG_DB_PASSWORD" {
  default = "1234"
}

variable "KONG_DB_VOL_PATH" {
  default = "/var/lib/postgresql/data"
}

variable "KONG_ADMIN_PORT" {
  default = 8001
}

variable "KONG_ADMIN_PORT_EXPOSED" {
  default = 8001
}
