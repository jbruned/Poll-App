resource "null_resource" "setup_kong_db" {
	provisioner "local-exec" {
		#   --platform linux/amd64
		command = <<EOT
			docker pull kong/kong-gateway:${var.KONG_VERSION}
			docker run --rm \
				-e "KONG_DATABASE=postgres" \
				-e "KONG_PG_HOST=${data.aws_instance.bastion.public_ip}" \
				-e "KONG_PG_PORT=${var.POSTGRES_PORT}" \
				-e "KONG_PG_USER=${var.KONG_DB_USER}" \
				-e "KONG_PG_PASSWORD=${var.KONG_DB_PASSWORD}" \
				-e "KONG_PG_DATABASE=${var.KONG_DB_NAME}" \
				kong/kong-gateway:${var.KONG_VERSION} /bin/bash -c \
				'kong migrations bootstrap && (printf "_format_version: \"1.1\"\nservices:\n- name: kong-admin\n  url: http://localhost:${var.KONG_ADMIN_PORT}\n  routes:\n  - name: kong-admin\n    strip_path: true\n    paths:\n    - ${var.KONG_ADMIN_ROUTE}\n    protocols:\n    - http" > /tmp/tmp.yml && cat /tmp/tmp.yml && kong config db_import /tmp/tmp.yml)'
		EOT
	}
	# 				'kong migrations bootstrap | grep "already bootstrapped" > /dev/null || (printf "_format_version: \"1.1\"\nservices:\n- name: kong-admin\n  url: http://localhost:${var.KONG_ADMIN_PORT}\n  routes:\n  - name: kong-admin\n    strip_path: true\n    paths:\n    - ${var.KONG_ADMIN_ROUTE}\n    protocols:\n    - http" > /tmp/tmp.yml && cat /tmp/tmp.yml && kong config db_import /tmp/tmp.yml)'
	triggers = {
		always_run = timestamp()
	}
}

resource "aws_ecs_service" "kong" {
	name                 = "${local.PREFIX}-kong"
	cluster              = data.aws_ecs_cluster.cluster.id
	task_definition      = aws_ecs_task_definition.kong.arn
	desired_count        = var.CONTAINER_COUNT
	launch_type          = "FARGATE"
	force_new_deployment = true

	deployment_maximum_percent		   = 200
	deployment_minimum_healthy_percent = 100

	network_configuration {
		security_groups  = [data.aws_security_group.private_sg.id]
		subnets          = [data.aws_subnet.private.id, data.aws_subnet.private2.id]
		assign_public_ip = true
	}

	load_balancer {
		target_group_arn = data.aws_lb_target_group.main.arn
		container_name   = var.KONG_CONTAINER_NAME
		container_port   = var.KONG_DEFAULT_PORT
	}

	depends_on = [data.aws_lb_listener.main, null_resource.setup_kong_db]
}

resource "aws_ecs_task_definition" "kong" {
	family                   = "${local.PREFIX}-kong"
	cpu                      = var.CONTAINER_CPU
	memory                   = var.CONTAINER_MEMORY
	network_mode             = "awsvpc"
	requires_compatibilities = ["FARGATE"]
	execution_role_arn       = local.ROLE_ARN

	container_definitions = <<DEFINITION
	[
		{
			"name": "${var.KONG_CONTAINER_NAME}",
			"image": "kong/kong-gateway:${var.KONG_VERSION}",
			"essential": true,
			"memory": ${var.CONTAINER_MEMORY},
			"cpu": ${var.CONTAINER_CPU},
			"logConfiguration": {
				"logDriver": "awslogs",
				"options": {
				  "awslogs-group": "${data.aws_cloudwatch_log_group.ecs.name}",
				  "awslogs-region": "${var.AWS_REGION}",
				  "awslogs-stream-prefix": "${local.PREFIX}-ecs"
				}
			},
			"portMappings": [
				{
					"containerPort": ${var.KONG_DEFAULT_PORT},
					"hostPort": ${var.KONG_DEFAULT_PORT},
					"protocol": "tcp"
				},
				{
					"containerPort": ${var.KONG_ADMIN_PORT},
					"hostPort": ${var.KONG_ADMIN_PORT},
					"protocol": "tcp"
				}
			],
			"environment": [
				{
					"name": "KONG_DATABASE",
					"value": "postgres"
				},
				{
					"name": "KONG_PG_HOST",
					"value": "${data.aws_db_instance.postgres.address}"
				},
				{
					"name": "KONG_PG_PORT",
					"value": "${var.POSTGRES_PORT}"
				},
				{
					"name": "KONG_PG_USER",
					"value": "${var.KONG_DB_USER}"
				},
				{
					"name": "KONG_PG_PASSWORD",
					"value": "${var.KONG_DB_PASSWORD}"
				},
				{
					"name": "KONG_PG_DATABASE",
					"value": "${var.KONG_DB_NAME}"
				},
				{
					"name": "KONG_PROXY_ACCESS_LOG",
					"value": "${var.KONG_LOG_PATH}/access.log"
				},
				{
					"name": "KONG_ADMIN_ACCESS_LOG",
					"value": "${var.KONG_LOG_PATH}/admin_access.log"
				},
				{
					"name": "KONG_PROXY_ERROR_LOG",
					"value": "${var.KONG_LOG_PATH}/error.log"
				},
				{
					"name": "KONG_ADMIN_ERROR_LOG",
					"value": "${var.KONG_LOG_PATH}/admin_error.log"
				},
				{
					"name": "KONG_ADMIN_LISTEN",
					"value": "0.0.0.0:${var.KONG_ADMIN_PORT}"
				},
				{
					"name": "KONG_PROXY_LISTEN",
					"value": "0.0.0.0:${var.KONG_DEFAULT_PORT}"
				}
			]
		}
	]
	DEFINITION
}

resource "null_resource" "wait_for_kong" {
	depends_on = [aws_ecs_service.kong, null_resource.setup_kong_db]
	provisioner "local-exec" {
		# command = "for i in $(seq 1 60); do wget -q ${data.aws_lb.main.dns_name}${var.KONG_ADMIN_ROUTE} && echo \"Port is open\" && exit 0; sleep 5; done; echo \"Port is not open after 5 minutes\" && exit 1"
		# "for i in $(seq 1 60); do wget -q ${data.aws_lb.main.dns_name}${var.KONG_ADMIN_ROUTE} && echo \"Port is open\" && exit 0; sleep 5; done; echo \"Port is not open after 5 minutes\" && exit 1"
		command = <<EOT
		#!/bin/bash
		for i in $(seq 1 60); do
			url="${data.aws_lb.main.dns_name}${var.KONG_ADMIN_ROUTE}"
			response=$(wget --no-check-certificate --auth-no-challenge --user=admin --password=secret --server-response --spider "$url" 2>&1)
			http_code=$(echo "$response" | awk '/^  HTTP/{print $2}')
			echo "HTTP code: $http_code"
			if [ "$http_code" = "200" ] || [ "$http_code" = "401" ]; then
				echo "Port is open"
				exit 0
			fi
			sleep 5
		done
		echo "Port is not open after 5 minutes"
		exit 1
		EOT
	}
	triggers = {
		always_run = timestamp()
	}
}