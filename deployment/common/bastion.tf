data "aws_instance" "bastion" {
  filter {
    name   = "tag:Name"
    values = [local.BASTION_HOST_NAME]
  }
}