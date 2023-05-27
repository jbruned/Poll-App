data "aws_ecs_task_definition" "main" {
	task_definition = "${local.PREFIX}-flask-task"
}

output "aws_ecs_task_definition--main" {
	value = data.aws_ecs_task_definition.main.id
}