data "aws_vpc" "main" {
	filter {
		name   = "tag:Name"
		values = [local.VPC_NAME]
	}
}

data "aws_internet_gateway" "main" {
	filter {
		name   = "tag:Name"
		values = ["${local.PREFIX}-internet-gateway"]
	}
}

data "aws_route" "gateway" {
	route_table_id = data.aws_vpc.main.main_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = data.aws_internet_gateway.main.id
}

output "aws_route--gateway" {
	value = "${data.aws_route.gateway.route_table_id}_${data.aws_route.gateway.destination_cidr_block}"
}