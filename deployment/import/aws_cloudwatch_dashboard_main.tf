/*data "aws_cloudwatch_dashboard" "main" {
	dashboard_name = "${local.PREFIX}-dashboard"
}

output "aws_cloudwatch_dashboard--main" {
	value = try(data.aws_cloudwatch_dashboard.main.dashboard_name, null)
}*/