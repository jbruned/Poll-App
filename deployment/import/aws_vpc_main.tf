data "aws_vpc" "main" {
	filter {
		name   = "tag:Name"
		values = [local.VPC_NAME]
	}
}

output "aws_vpc--main" {
	value = data.aws_vpc.main.id
}