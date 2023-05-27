data "aws_db_instance" "postgres" {
	db_instance_identifier = local.DB_INSTANCE_IDENTIFIER
}

output "aws_db_instance--postgres" {
	value = data.aws_db_instance.postgres.id
}