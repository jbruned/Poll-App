data "aws_subnet" "private2" {
	filter {
		name   = "tag:Name"
		values = [local.PRIVATE_SUBNET_NAME_2]
	}
}

output "aws_subnet--private2" {
	value = data.aws_subnet.private2.id
}