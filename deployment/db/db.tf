terraform {
  required_version = ">= 1.1.6"
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.15.0"
    }
  }
}

/*resource "aws_instance" "bastion" {
  ami           = "ami-0889a44b331db0194" // "ami-055ca7eb6574a8b94" // data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.private.id
  vpc_security_group_ids = [data.aws_security_group.public_sg.id, data.aws_security_group.private_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = local.BASTION_HOST_NAME
  }
  *//*triggers = {
    db_identifier = data.aws_db_instance.postgres.id
    db_endpoint = data.aws_db_instance.postgres.endpoint
  }*//*
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y socat
    sudo socat tcp-listen:${var.POSTGRES_PORT},reuseaddr,fork tcp:${data.aws_db_instance.postgres.endpoint}&
    EOF
}*/
# sudo yum install iptables-services -y
# sudo systemctl enable iptables
# sudo systemctl start iptables
# sudo sysctl -w net.ipv4.ip_forward=1
# sudo iptables -t nat -A PREROUTING -p tcp --dport ${var.POSTGRES_PORT} -j DNAT --to-destination ${data.dns_a_record_set.rds_ip.addrs[0]}:${aws_db_instance.postgres.port}
# sudo iptables -t nat -A POSTROUTING -j MASQUERADE
# sudo service iptables save
# sudo socat TCP4-LISTEN:${var.POSTGRES_PORT},fork TCP4:${data.dns_a_record_set.rds_ip.addrs[0]}:${aws_db_instance.postgres.port}

resource "null_resource" "wait_for_bastion" {
  depends_on = [data.aws_instance.bastion]
  provisioner "local-exec" {
    command = "until nc -z ${data.aws_instance.bastion.public_ip} ${var.POSTGRES_PORT}; do sleep 1; done"
  }
  triggers = {
    instance_id = data.aws_instance.bastion.id
  }
}

provider "postgresql" {
  host             = data.aws_instance.bastion.public_ip // "23.20.15.152" // "34.203.209.245"
  port             = var.POSTGRES_PORT
  username         = var.RDS_USERNAME
  password         = var.RDS_PASSWORD
  // database         = var.DB_NAME
  superuser = false
  expected_version = data.aws_db_instance.postgres.engine_version
  connect_timeout = 15
}

resource "postgresql_database" "polldb" {
  name = var.DB_NAME
  depends_on = [null_resource.wait_for_bastion] // [aws_instance.bastion]
  connection_limit = 100
  allow_connections = true
}

resource "postgresql_database" "kongdb" {
  name = var.KONG_DB_NAME
  depends_on = [null_resource.wait_for_bastion] // [aws_instance.bastion]
  connection_limit = 100
  allow_connections = true
}

resource "postgresql_role" "app_user" {
  name     = var.DB_USER
  password = var.DB_PASSWORD
  login = true
  depends_on = [null_resource.wait_for_bastion] // [aws_instance.bastion]
}

resource "postgresql_role" "kong_user" {
  name     = var.KONG_DB_USER
  password = var.KONG_DB_PASSWORD
  login = true
  depends_on = [null_resource.wait_for_bastion] // [aws_instance.bastion]
}

resource "postgresql_grant" "app_user_grant" {
  database    = postgresql_database.polldb.name
  role        = postgresql_role.app_user.name
  schema      = "public"
  object_type = "database"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "kong_user_grant" {
  database    = postgresql_database.kongdb.name
  role        = postgresql_role.kong_user.name
  schema      = "public"
  object_type = "database"
  privileges  = ["ALL"]
}


/*resource "null_resource" "delete_bastion" {
  depends_on = [
    postgresql_grant.app_user_grant,
    postgresql_grant.kong_user_grant
  ]
  triggers = {
    instance_id = aws_instance.bastion.id
  }
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${self.triggers.instance_id} --region ${var.AWS_REGION}"
  }
}*/
