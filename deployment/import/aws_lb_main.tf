data "aws_lb" "main" {
	name = "${local.PREFIX}-load-balancer"
}

output "aws_lb--main" {
	value = data.aws_lb.main.id
}