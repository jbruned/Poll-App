terraform {
	required_version = ">= 1.1.6"
	required_providers {
		postgresql = {
			source  = "cyrilgdn/postgresql"
			version = "1.15.0"
		}
	}
}

resource "null_resource" "wait_for_bastion" {
	depends_on = [data.aws_instance.bastion]
	provisioner "local-exec" {
		command = "for i in $(seq 1 60); do nc -z ${data.aws_instance.bastion.public_ip} ${var.POSTGRES_PORT} && echo \"Port is open\" && exit 0; sleep 5; done; echo \"Port is not open after 5 minutes\" && exit 1"
	}
	triggers = {
		instance_id = data.aws_instance.bastion.id
	}
}

provider "postgresql" {
	host             = data.aws_instance.bastion.public_ip
	port             = var.POSTGRES_PORT
	username         = var.RDS_USERNAME
	password         = var.RDS_PASSWORD
	superuser        = false
	expected_version = data.aws_db_instance.postgres.engine_version
	connect_timeout  = 15
}

resource "postgresql_database" "polldb" {
	name              = var.DB_NAME
	depends_on        = [null_resource.wait_for_bastion]
	connection_limit  = 100
	allow_connections = true
}

resource "postgresql_database" "kongdb" {
	name              = var.KONG_DB_NAME
	depends_on        = [null_resource.wait_for_bastion]
	connection_limit  = 100
	allow_connections = true
}

resource "postgresql_role" "app_user" {
	name       = var.DB_USER
	password   = var.DB_PASSWORD
	login      = true
	depends_on = [null_resource.wait_for_bastion]
}

resource "postgresql_role" "kong_user" {
	name       = var.KONG_DB_USER
	password   = var.KONG_DB_PASSWORD
	login      = true
	depends_on = [null_resource.wait_for_bastion]
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
