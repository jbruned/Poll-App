data "aws_security_group" "private_sg" {
	name = local.PRIVATE_SG_NAME
}

output "aws_security_group--private_sg" {
	value = data.aws_security_group.private_sg.id
}