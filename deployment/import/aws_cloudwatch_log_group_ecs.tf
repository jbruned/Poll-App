data "aws_cloudwatch_log_group" "ecs" {
	name = local.LOG_GROUP_NAME
}

output "aws_cloudwatch_log_group--ecs" {
	value = data.aws_cloudwatch_log_group.ecs.name
}