output "postgresql_database--polldb" {
	value = var.DB_NAME
}

output "postgresql_database--kongdb" {
	value = var.KONG_DB_NAME
}

output "postgresql_role--app_user" {
	value = var.DB_USER
}

output "postgresql_role--kong_user" {
	value = var.KONG_DB_USER
}
