data "aws_security_group" "public_sg" {
	name = local.PUBLIC_SG_NAME
}

output "aws_security_group--public_sg" {
	value = data.aws_security_group.public_sg.id
}