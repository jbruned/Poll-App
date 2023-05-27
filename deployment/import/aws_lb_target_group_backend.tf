data "aws_lb_target_group" "backend" {
	name = "${local.PREFIX}-backend-tg"
}

output "aws_lb_target_group--backend" {
	value = data.aws_lb_target_group.backend.id
}