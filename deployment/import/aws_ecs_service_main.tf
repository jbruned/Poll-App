data "aws_ecs_cluster" "cluster" {
	cluster_name = "${local.PREFIX}-ecs-cluster"
}

data "aws_ecs_service" "main" {
	cluster_arn = data.aws_ecs_cluster.cluster.arn
	service_name = "${local.PREFIX}-ecs-service"
}

output "aws_ecs_service--main" {
	value = "${data.aws_ecs_cluster.cluster.cluster_name}/${data.aws_ecs_service.main.service_name}"
}