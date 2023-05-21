data "aws_instance" "bastion" {
	filter {
		name   = "tag:Name"
		values = [local.BASTION_HOST_NAME]
	}
	filter {
		name   = "instance-state-name"
		values = ["running", "pending"]
	}
}

output "aws_instance--bastion" {
	value = data.aws_instance.bastion.id
}
