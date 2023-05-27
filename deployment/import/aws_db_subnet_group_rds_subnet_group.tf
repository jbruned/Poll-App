data "aws_db_subnet_group" "rds_subnet_group" {
	name = local.RDS_SUBNET_GROUP_NAME
}

output "aws_db_subnet_group--rds_subnet_group" {
	value = data.aws_db_subnet_group.rds_subnet_group.id
}