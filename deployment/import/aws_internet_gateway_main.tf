data "aws_internet_gateway" "main" {
	filter {
		name   = "tag:Name"
		values = ["${local.PREFIX}-internet-gateway"]
	}
}

output "aws_internet_gateway--main" {
	value = data.aws_internet_gateway.main.id
}