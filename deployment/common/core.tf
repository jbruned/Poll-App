data "aws_db_instance" "postgres" {
  db_instance_identifier = local.DB_INSTANCE_IDENTIFIER
}

data "aws_subnet" "private" {
  filter {
      name   = "tag:Name"
      values = [local.PRIVATE_SUBNET_NAME]
  }
}

data "aws_subnet" "private2" {
  filter {
      name   = "tag:Name"
      values = [local.PRIVATE_SUBNET_NAME_2]
  }
}

data "aws_subnet" "public" {
  filter {
      name   = "tag:Name"
      values = [local.PUBLIC_SUBNET_NAME]
  }
}

data "aws_subnet" "public2" {
  filter {
      name   = "tag:Name"
      values = [local.PUBLIC_SUBNET_NAME_2]
  }
}

data "aws_security_group" "public_sg" {
  name = local.PUBLIC_SG_NAME
}

data "aws_security_group" "private_sg" {
  name = local.PRIVATE_SG_NAME
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [local.VPC_NAME]
  }
}
