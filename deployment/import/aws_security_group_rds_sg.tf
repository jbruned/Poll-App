data "aws_security_group" "rds_sg" {
	name = local.RDS_SG_NAME
}

output "aws_security_group--rds_sg" {
	value = data.aws_security_group.rds_sg.id
}