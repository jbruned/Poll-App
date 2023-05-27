data "aws_ecs_task_definition" "kong" {
	task_definition = "${local.PREFIX}-kong"
}

output "aws_ecs_task_definition--kong" {
	value = data.aws_ecs_task_definition.kong.id
}