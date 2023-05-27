data "aws_lb" "backend" {
	name = "${local.PREFIX}-lb-backend"
}

output "aws_lb--backend" {
	value = try(data.aws_lb.backend.id, null)
}