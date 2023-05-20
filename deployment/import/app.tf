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
