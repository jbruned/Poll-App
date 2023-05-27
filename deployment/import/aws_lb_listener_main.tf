data "aws_lb" "main" {
	name = "${local.PREFIX}-load-balancer"
}

data "aws_lb_listener" "main" {
	load_balancer_arn = data.aws_lb.main.arn
	port              = var.EXPOSED_PORT
}

output "aws_lb_listener--main" {
	value = data.aws_lb_listener.main.id
}