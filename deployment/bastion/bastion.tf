resource "aws_instance" "bastion" {
	ami                         = "ami-0889a44b331db0194" // data.aws_ssm_parameter.amazon_linux_2.value
	instance_type               = "t2.micro"
	subnet_id                   = data.aws_subnet.private.id
	security_groups             = [data.aws_security_group.public_sg.id, data.aws_security_group.private_sg.id]
	vpc_security_group_ids      = [data.aws_security_group.public_sg.id, data.aws_security_group.private_sg.id]
	associate_public_ip_address = true
	tags                        = {
		Name = local.BASTION_HOST_NAME
	}
	user_data = <<-EOF
#!/bin/bash
sudo yum install -y socat
(sudo socat tcp-listen:${var.POSTGRES_PORT},reuseaddr,fork tcp:${data.aws_db_instance.postgres.endpoint} &)
    EOF
	# (sudo socat tcp-listen:${var.KONG_ADMIN_PORT},reuseaddr,fork tcp:${data.aws_lb.main.dns_name}:${var.KONG_ADMIN_PORT} &)
}

resource "null_resource" "wait_for_postgres" {
	provisioner "local-exec" {
		// command = "until nc -z ${aws_instance.bastion.public_ip} ${var.POSTGRES_PORT}; do sleep 1; done"
		command = "for i in $(seq 1 60); do nc -z ${aws_instance.bastion.public_ip} ${var.POSTGRES_PORT} && echo \"Port is open\" && exit 0; sleep 5; done; echo \"Port is not open after 5 minutes\" && exit 1"
	}
	triggers = {
		instance_id = aws_instance.bastion.id
		run_always  = timestamp()
	}
}

output "postgres_endpoint" {
	value      = "${aws_instance.bastion.public_ip}:${var.POSTGRES_PORT}"
	depends_on = [null_resource.wait_for_postgres]
}