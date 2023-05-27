data "aws_ecs_cluster" "cluster" {
	cluster_name = "${local.PREFIX}-ecs-cluster"
}

data "aws_ecs_service" "kong" {
	cluster_arn = data.aws_ecs_cluster.cluster.arn
	service_name = "${local.PREFIX}-kong"
}

output "aws_ecs_service--kong" {
	value = "${data.aws_ecs_cluster.cluster.cluster_name}/${data.aws_ecs_service.kong.service_name}"
}