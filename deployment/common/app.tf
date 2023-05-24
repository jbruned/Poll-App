data "aws_lb" "backend" {
	name = "${local.PREFIX}-lb-backend"
}

output "aws_lb--backend" {
	value = data.aws_lb.backend.id
}

data "aws_lb_target_group" "backend" {
	name = "${local.PREFIX}-backend-tg"
}

output "aws_lb_target_group--backend" {
	value = data.aws_lb_target_group.backend.id
}

data "aws_lb_listener" "backend" {
	load_balancer_arn = data.aws_lb.backend.arn
	port              = var.EXPOSED_PORT
}

output "aws_lb_listener--backend" {
	value = data.aws_lb_listener.backend.id
}

data "aws_ecs_service" "main" {
	cluster_arn = data.aws_ecs_cluster.cluster.arn
	service_name = "${local.PREFIX}-ecs-service"
}

output "aws_ecs_service--main" {
	value = "${data.aws_ecs_cluster.cluster.cluster_name}/${data.aws_ecs_service.main.service_name}"
}

data "aws_ecs_task_definition" "main" {
	task_definition = "${local.PREFIX}-flask-task"
}

output "aws_ecs_task_definition--main" {
	value = data.aws_ecs_task_definition.main.id
}
