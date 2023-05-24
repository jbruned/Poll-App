data "aws_db_instance" "postgres" {
	db_instance_identifier = local.DB_INSTANCE_IDENTIFIER
}

output "aws_db_instance--postgres" {
	value = data.aws_db_instance.postgres.id
}

data "aws_subnet" "private" {
	filter {
		name   = "tag:Name"
		values = [local.PRIVATE_SUBNET_NAME]
	}
}

output "aws_subnet--private" {
	value = data.aws_subnet.private.id
}

data "aws_subnet" "private2" {
	filter {
		name   = "tag:Name"
		values = [local.PRIVATE_SUBNET_NAME_2]
	}
}

output "aws_subnet--private2" {
	value = data.aws_subnet.private2.id
}

data "aws_subnet" "public" {
	filter {
		name   = "tag:Name"
		values = [local.PUBLIC_SUBNET_NAME]
	}
}

output "aws_subnet--public" {
	value = data.aws_subnet.public.id
}

data "aws_subnet" "public2" {
	filter {
		name   = "tag:Name"
		values = [local.PUBLIC_SUBNET_NAME_2]
	}
}

output "aws_subnet--public2" {
	value = data.aws_subnet.public2.id
}

data "aws_security_group" "public_sg" {
	name = local.PUBLIC_SG_NAME
}

output "aws_security_group--public_sg" {
	value = data.aws_security_group.public_sg.id
}

data "aws_security_group" "private_sg" {
	name = local.PRIVATE_SG_NAME
}

output "aws_security_group--private_sg" {
	value = data.aws_security_group.private_sg.id
}

data "aws_vpc" "main" {
	filter {
		name   = "tag:Name"
		values = [local.VPC_NAME]
	}
}

output "aws_vpc--main" {
	value = data.aws_vpc.main.id
}

data "aws_internet_gateway" "main" {
	filter {
		name   = "tag:Name"
		values = ["${local.PREFIX}-internet-gateway"]
	}
}

output "aws_internet_gateway--main" {
	value = data.aws_internet_gateway.main.id
}

data "aws_route" "gateway" {
	route_table_id = data.aws_vpc.main.main_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = data.aws_internet_gateway.main.id
}

output "aws_route--gateway" {
	value = "${data.aws_route.gateway.route_table_id}_${data.aws_route.gateway.destination_cidr_block}"
}

data "aws_security_group" "rds_sg" {
	name = local.RDS_SG_NAME
}

output "aws_security_group--rds_sg" {
	value = data.aws_security_group.rds_sg.id
}

data "aws_db_subnet_group" "rds_subnet_group" {
	name = local.RDS_SUBNET_GROUP_NAME
}

output "aws_db_subnet_group--rds_subnet_group" {
	value = data.aws_db_subnet_group.rds_subnet_group.id
}

data "aws_lb" "main" {
	name = "${local.PREFIX}-load-balancer"
}

output "aws_lb--main" {
	value = data.aws_lb.main.id
}

data "aws_lb_target_group" "main" {
	name = "${local.PREFIX}-target-group"
}

output "aws_lb_target_group--main" {
	value = data.aws_lb_target_group.main.id
}

data "aws_lb_listener" "main" {
	load_balancer_arn = data.aws_lb.main.arn
	port              = var.EXPOSED_PORT
}

output "aws_lb_listener--main" {
	value = data.aws_lb_listener.main.id
}

/*data "aws_lb_target_group" "kong_admin" {
	name = "${local.PREFIX}-kong-admin-tg"
}

output "aws_lb_target_group--kong_admin" {
	value = data.aws_lb_target_group.kong_admin.id
}

data "aws_lb_listener" "kong_admin" {
	load_balancer_arn = data.aws_lb.main.arn
	port              = var.KONG_ADMIN_PORT
}

output "aws_lb_listener--kong_admin" {
	value = data.aws_lb_listener.kong_admin.id
}*/

data "aws_ecs_cluster" "cluster" {
	cluster_name = "${local.PREFIX}-ecs-cluster"
}

output "aws_ecs_cluster--cluster" {
	value = data.aws_ecs_cluster.cluster.cluster_name
}

data "aws_cloudwatch_log_group" "ecs" {
	name = "${local.PREFIX}-ecs-logs"
}

output "aws_cloudwatch_log_group--ecs" {
	value = data.aws_cloudwatch_log_group.ecs.name
}
