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

data "aws_ecs_cluster" "cluster" {
	cluster_name = "${local.PREFIX}-ecs-cluster"
}

output "aws_ecs_cluster--cluster" {
	value = data.aws_ecs_cluster.cluster.cluster_name
}

data "aws_ecs_service" "main" {
	cluster_arn = data.aws_ecs_cluster.cluster.arn
	service_name = "${local.PREFIX}-ecs-service"
}

output "aws_ecs_service--main" {
	value = "${data.aws_ecs_cluster.cluster.cluster_name}/${data.aws_ecs_service.main.service_name}"
}

data "aws_cloudwatch_log_group" "ecs" {
	name = "${local.PREFIX}-ecs-logs"
}

output "aws_cloudwatch_log_group--ecs" {
	value = data.aws_cloudwatch_log_group.ecs.name
}

data "aws_ecs_task_definition" "main" {
	task_definition = "${local.PREFIX}-flask-task"
}

output "aws_ecs_task_definition--main" {
	value = data.aws_ecs_task_definition.main.id
}
