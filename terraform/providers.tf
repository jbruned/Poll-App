terraform {
  required_providers {
    kong = {
      source  = "philips-labs/kong"
      version = "6.630.0"
    }
  }
}

provider "kong" {
  kong_admin_uri = "http://localhost:${var.KONG_ADMIN_PORT_EXPOSED}"
  #  kong_api_key      = "admin" # Replace with your actual API key
  #  kong_admin_tenant = "default"
}
