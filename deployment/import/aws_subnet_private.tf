data "aws_subnet" "private" {
	filter {
		name   = "tag:Name"
		values = [local.PRIVATE_SUBNET_NAME]
	}
}

output "aws_subnet--private" {
	value = data.aws_subnet.private.id
}