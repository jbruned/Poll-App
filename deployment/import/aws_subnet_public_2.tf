data "aws_subnet" "public" {
	filter {
		name   = "tag:Name"
		values = [local.PUBLIC_SUBNET_NAME]
	}
}

output "aws_subnet--public" {
	value = data.aws_subnet.public.id
}