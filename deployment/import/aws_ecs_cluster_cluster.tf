data "aws_ecs_cluster" "cluster" {
	cluster_name = "${local.PREFIX}-ecs-cluster"
}

output "aws_ecs_cluster--cluster" {
	value = data.aws_ecs_cluster.cluster.cluster_name
}