data "aws_subnet" "public2" {
	filter {
		name   = "tag:Name"
		values = [local.PUBLIC_SUBNET_NAME_2]
	}
}

output "aws_subnet--public2" {
	value = data.aws_subnet.public2.id
}