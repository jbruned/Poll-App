resource "aws_vpc" "main" {
	cidr_block           = "10.0.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support   = true

	tags = {
		Name = local.VPC_NAME
	}
}

resource "aws_internet_gateway" "main" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "${local.PREFIX}-internet-gateway"
	}
}

resource "aws_route" "gateway" {
	route_table_id         = aws_vpc.main.main_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "private" {
	vpc_id            = aws_vpc.main.id
	cidr_block        = "10.0.1.0/24"
	availability_zone = data.aws_availability_zones.available.names[0]

	tags = {
		Name = local.PRIVATE_SUBNET_NAME
	}
}

resource "aws_subnet" "private2" {
	vpc_id            = aws_vpc.main.id
	cidr_block        = "10.0.2.0/24"
	availability_zone = data.aws_availability_zones.available.names[1]

	tags = {
		Name = local.PRIVATE_SUBNET_NAME_2
	}
}

resource "aws_subnet" "public" {
	vpc_id            = aws_vpc.main.id
	cidr_block        = "10.0.3.0/24"
	availability_zone = data.aws_availability_zones.available.names[0]

	tags = {
		Name = local.PUBLIC_SUBNET_NAME
	}
}

resource "aws_subnet" "public2" {
	vpc_id            = aws_vpc.main.id
	cidr_block        = "10.0.4.0/24"
	availability_zone = data.aws_availability_zones.available.names[1]

	tags = {
		Name = local.PUBLIC_SUBNET_NAME_2
	}
}

resource "aws_security_group" "private_sg" {
	name        = local.PRIVATE_SG_NAME
	description = "Private security group for internal communication"
	vpc_id      = aws_vpc.main.id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [aws_vpc.main.cidr_block]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "public_sg" {
	name        = local.PUBLIC_SG_NAME
	description = "Public security group for internet exposure"
	vpc_id      = aws_vpc.main.id

	ingress {
		from_port   = var.EXPOSED_PORT
		to_port     = var.EXPOSED_PORT
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "Access from local network"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [aws_vpc.main.cidr_block]
	}

	ingress {
		description = "Access from current IP"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["${local.myip}/32"]
	}

	/*ingress {
		from_port   = var.POSTGRES_PORT
		to_port     = var.POSTGRES_PORT
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = var.KONG_ADMIN_PORT
		to_port = var.KONG_ADMIN_PORT
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}*/

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "rds_sg" {
	name        = local.RDS_SG_NAME
	description = "RDS security group for PostgreSQL"
	vpc_id      = aws_vpc.main.id

	ingress {
		from_port   = var.POSTGRES_PORT
		to_port     = var.POSTGRES_PORT
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		// security_groups = [aws_security_group.private_sg.id]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_db_subnet_group" "rds_subnet_group" {
	name       = local.RDS_SUBNET_GROUP_NAME
	subnet_ids = [aws_subnet.private.id, aws_subnet.private2.id]

	tags = {
		Name = "${local.PREFIX}-rds-subnet-group"
	}
}

resource "aws_db_instance" "postgres" {
	identifier             = local.DB_INSTANCE_IDENTIFIER
	engine                 = "postgres"
	engine_version         = var.POSTGRES_VERSION
	instance_class         = "db.t3.micro"
	allocated_storage      = 20
	max_allocated_storage  = 100
	storage_type           = "gp2"
	username               = var.RDS_USERNAME
	password               = var.RDS_PASSWORD
	db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
	vpc_security_group_ids = [aws_security_group.rds_sg.id]
	skip_final_snapshot    = true
	publicly_accessible    = true

	lifecycle {
		# Avoid modifications after importing the resource
		# (the password is not imported because it's sensitive)
		ignore_changes = [password, apply_immediately]
	}

	tags = {
		Name = "${local.PREFIX}-postgres"
	}
}

resource "aws_lb" "main" {
	name               = "${local.PREFIX}-load-balancer"
	internal           = false
	load_balancer_type = "application"
	security_groups    = [aws_security_group.public_sg.id, aws_security_group.private_sg.id]
	subnets            = [aws_subnet.public.id, aws_subnet.public2.id]

	tags = {
		Name = "${local.PREFIX}-load-balancer"
	}
}

resource "aws_lb_target_group" "main" {
	name        = "${local.PREFIX}-target-group"
	port        = var.KONG_DEFAULT_PORT
	protocol    = "HTTP"
	vpc_id      = aws_vpc.main.id
	target_type = "ip"

	health_check {
		enabled             = true
		interval            = 30
		path                = "/"
		timeout             = 5
		healthy_threshold   = 3
		unhealthy_threshold = 3
		matcher             = "200,401,403,404"
	}

}

resource "aws_lb_listener" "main" {
	load_balancer_arn = aws_lb.main.arn
	port              = var.EXPOSED_PORT
	protocol          = "HTTP"

	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.main.arn
	}
}

resource "aws_lb_target_group" "kong_admin" {
	name        = "${local.PREFIX}-kong-admin-tg"
	port        = var.KONG_ADMIN_PORT
	protocol    = "HTTP"
	vpc_id      = aws_vpc.main.id
	target_type = "ip"

	health_check {
		enabled             = true
		interval            = 30
		path                = "/"
		timeout             = 5
		healthy_threshold   = 3
		unhealthy_threshold = 3
	}
}

resource "aws_lb_listener" "kong_admin" {
	load_balancer_arn = aws_lb.main.arn
	port              = var.KONG_ADMIN_PORT
	protocol          = "HTTP"

	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.kong_admin.arn
	}
}

resource "aws_ecs_cluster" "cluster" {
	name = "${local.PREFIX}-ecs-cluster"

	tags = {
		Name = "${local.PREFIX}-ecs-cluster"
	}
}

resource "aws_cloudwatch_log_group" "ecs" {
	name              = "${local.PREFIX}-ecs-logs"
	retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "main" {
	dashboard_name = "${local.PREFIX}-dashboard"
	dashboard_body = <<EOF
	{
		"widgets": [
			{
				"type": "metric",
				"x": 0,
				"y": 0,
				"width": 24,
				"height": 6,
				"properties": {
					"metrics": [
						[ "AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", "${aws_lb.main.arn}", "TargetGroup", "${aws_lb_target_group.main.arn}" ],
						[ ".", "UnHealthyHostCount", ".", "." ]
					],
					"view": "timeSeries",
					"stacked": false,
					"region": "${var.AWS_REGION}",
					"stat": "Average",
					"period": 60,
					"title": "Healthy Hosts",
					"legend": {
						"position": "bottom"
					},
					"yAxis": {
						"left": {
							"min": 0
						}
					}
				}
			}
		]
	}
	EOF
}

output "url" {
	value = aws_lb.main.dns_name
}
