resource "aws_ecs_service" "main" {
	name                 = "${local.PREFIX}-ecs-service"
	cluster              = data.aws_ecs_cluster.cluster.id
	task_definition      = aws_ecs_task_definition.main.arn
	desired_count        = 2
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
		target_group_arn = data.aws_lb_target_group.main.arn
		container_name   = var.CONTAINER_NAME
		container_port   = var.EXPOSED_PORT
	}

	depends_on = [data.aws_lb_listener.main]
}

resource "aws_cloudwatch_log_group" "ecs" {
	name              = "${local.PREFIX}-ecs-logs"
	retention_in_days = 7
}

resource "aws_ecs_task_definition" "main" {
	family                   = "${local.PREFIX}-flask-task"
	execution_role_arn       = local.ROLE_ARN
	network_mode             = "awsvpc"
	requires_compatibilities = ["FARGATE"]
	cpu                      = var.CPU
	memory                   = var.MEMORY

	runtime_platform {
		operating_system_family = "LINUX"
		cpu_architecture        = "X86_64"
	}

	container_definitions = <<DEFINITION
    [
        {
        "name": "${var.CONTAINER_NAME}",
        "image": "${local.IMAGE_URL}",
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
              "awslogs-group": "${aws_cloudwatch_log_group.ecs.name}",
              "awslogs-region": "${var.AWS_REGION}",
              "awslogs-stream-prefix": "${local.PREFIX}-ecs"
            }
        },
        "essential": true,
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

resource "null_resource" "wait_for_web" {
	triggers = {
		url = data.aws_lb.main.dns_name
		run_always = timestamp()
	}
	depends_on = [data.aws_lb.main, aws_ecs_service.main]
	provisioner "local-exec" {
		# Wait until a request returns a 200 response
		# If the timeout is reached, the resource is marked as errored
		command = "curl --fail --retry-all-errors --silent --output /dev/null --retry 20 --retry-delay 5 --retry-connrefused http://${data.aws_lb.main.dns_name}:${var.EXPOSED_PORT}"
	}
}

output "url" {
	value      = "http://${data.aws_lb.main.dns_name}"
	depends_on = [null_resource.wait_for_web]
}
