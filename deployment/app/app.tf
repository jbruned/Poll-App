resource "aws_lb" "backend" {
	name               = "${local.PREFIX}-lb-backend"
	security_groups    = [data.aws_security_group.private_sg.id]
	subnets            = [data.aws_subnet.private.id, data.aws_subnet.private2.id]
	load_balancer_type = "application"
	internal = true

	tags = {
		Name = "${local.PREFIX}-lb-backend"
	}
}

resource "aws_lb_listener" "backend" {
	load_balancer_arn = aws_lb.backend.arn
	port              = var.EXPOSED_PORT
	protocol          = "HTTP"

	default_action {
		target_group_arn = aws_lb_target_group.backend.arn
		type             = "forward"
	}
}

resource "aws_lb_target_group" "backend" {
	name     = "${local.PREFIX}-backend-tg"
	port     = var.EXPOSED_PORT
	protocol = "HTTP"
	vpc_id   = data.aws_vpc.main.id
	target_type = "ip"

	health_check {
		enabled             = true
		healthy_threshold   = 3
		unhealthy_threshold = 3
		timeout             = 5
		interval            = 30
		path                = "/"
	}
}

resource "aws_ecs_service" "main" {
	name                 = "${local.PREFIX}-ecs-service"
	cluster              = data.aws_ecs_cluster.cluster.id
	task_definition      = aws_ecs_task_definition.main.arn
	desired_count        = var.CONTAINER_COUNT
	launch_type          = "FARGATE"
	force_new_deployment = true
	deployment_maximum_percent = 200
	deployment_minimum_healthy_percent = 100

	network_configuration {
		subnets          = [data.aws_subnet.private.id, data.aws_subnet.private2.id]
		security_groups  = [data.aws_security_group.private_sg.id]
		assign_public_ip = true
	}

	load_balancer {
		target_group_arn = aws_lb_target_group.backend.arn
		container_name   = var.CONTAINER_NAME
		container_port   = var.EXPOSED_PORT
	}

	depends_on = [aws_lb_listener.backend]
}

resource "aws_ecs_task_definition" "main" {
	family                   = "${local.PREFIX}-flask-task"
	execution_role_arn       = local.ROLE_ARN
	network_mode             = "awsvpc"
	requires_compatibilities = ["FARGATE"]
	cpu                      = var.CONTAINER_CPU
	memory                   = var.CONTAINER_MEMORY

	runtime_platform {
		operating_system_family = "LINUX"
		cpu_architecture        = "X86_64"
	}

	container_definitions = <<DEFINITION
    [
        {
        "name": "${var.CONTAINER_NAME}",
        "image": "${local.IMAGE_URL}",
        "essential": true,
		"memory": ${var.CONTAINER_MEMORY},
		"cpu": ${var.CONTAINER_CPU},
        "portMappings": [
            {
              "containerPort": ${var.EXPOSED_PORT},
              "hostPort": ${var.EXPOSED_PORT},
              "protocol": "tcp"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "${data.aws_cloudwatch_log_group.ecs.name}",
              "awslogs-region": "${var.AWS_REGION}",
              "awslogs-stream-prefix": "${local.PREFIX}-ecs"
            }
        },
        "environment": [
            {
              "name": "BACKEND_PORT",
              "value": "80"
            },
            {
              "name": "DEBUG_ON",
              "value": "True"
            },
            {
              "name": "INSERT_TEST_DATA",
              "value": "True"
            },
            {
              "name": "DB_HOST",
              "value": "${data.aws_db_instance.postgres.address}"
            },
            {
              "name": "DB_PORT",
              "value": "${data.aws_db_instance.postgres.port}"
            },
            {
              "name": "DB_USER",
              "value": "${var.DB_USER}"
            },
            {
              "name": "DB_PASSWORD",
              "value": "${var.DB_PASSWORD}"
            },
            {
              "name": "DB_NAME",
              "value": "${var.DB_NAME}"
            }
        ]
        }
    ]
    DEFINITION
}
