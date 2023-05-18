resource "aws_instance" "bastion" {
	ami                         = "ami-0889a44b331db0194"
	// "ami-055ca7eb6574a8b94" // data.aws_ssm_parameter.amazon_linux_2.value
	instance_type               = "t2.micro"
	subnet_id                   = data.aws_subnet.private.id
	vpc_security_group_ids      = [data.aws_security_group.public_sg.id, data.aws_security_group.private_sg.id]
	associate_public_ip_address = true
	tags                        = {
		Name = local.BASTION_HOST_NAME
	}
	user_data = <<-EOF
    	#!/bin/bash
    	sudo yum install -y socat
    	sudo socat tcp-listen:${var.POSTGRES_PORT},reuseaddr,fork tcp:${data.aws_db_instance.postgres.endpoint}&
    EOF
}

resource "null_resource" "wait_for_postgres" {
	provisioner "local-exec" {
		command = "until nc -z ${aws_instance.bastion.public_ip} ${var.POSTGRES_PORT}; do sleep 1; done"
	}
}

output "postgres_endpoint" {
	value      = "${aws_instance.bastion.public_ip}:${var.POSTGRES_PORT}"
	depends_on = [null_resource.wait_for_postgres]
}