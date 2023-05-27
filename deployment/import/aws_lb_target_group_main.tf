data "aws_lb_target_group" "main" {
	name = "${local.PREFIX}-target-group"
}

output "aws_lb_target_group--main" {
	value = data.aws_lb_target_group.main.id
}