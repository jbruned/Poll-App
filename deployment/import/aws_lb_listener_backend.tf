data "aws_lb" "backend" {
	name = "${local.PREFIX}-lb-backend"
}

data "aws_lb_listener" "backend" {
	load_balancer_arn = data.aws_lb.backend.arn
	port              = var.EXPOSED_PORT
}

output "aws_lb_listener--backend" {
	value = data.aws_lb_listener.backend.id
}