echo "Initializing deployment environment"
echo "> Creating symlinks for common files"
# App
ln -f -s ../common.tf app/common.ln.tf
ln -f -s ../import/aws_subnet_private.tf app/aws_subnet_private.ln.tf
ln -f -s ../import/aws_subnet_private_2.tf app/aws_subnet_private_2.ln.tf
ln -f -s ../import/aws_subnet_public.tf app/aws_subnet_public.ln.tf
ln -f -s ../import/aws_subnet_public_2.tf app/aws_subnet_public_2.ln.tf
ln -f -s ../import/aws_security_group_private_sg.tf app/aws_security_group_private_sg.ln.tf
ln -f -s ../import/aws_security_group_public_sg.tf app/aws_security_group_public_sg.ln.tf
ln -f -s ../import/aws_vpc_main.tf app/aws_vpc_main.ln.tf
ln -f -s ../import/aws_ecs_cluster_cluster.tf app/aws_ecs_cluster_cluster.ln.tf
ln -f -s ../import/aws_cloudwatch_log_group_ecs.tf app/aws_cloudwatch_log_group_ecs.ln.tf
ln -f -s ../import/aws_db_instance_postgres.tf app/aws_db_instance_postgres.ln.tf
# Bastion
ln -f -s ../common.tf bastion/common.ln.tf
ln -f -s ../import/aws_subnet_private.tf bastion/aws_subnet_private.ln.tf
ln -f -s ../import/aws_security_group_private_sg.tf bastion/aws_security_group_private_sg.ln.tf
ln -f -s ../import/aws_security_group_public_sg.tf bastion/aws_security_group_public_sg.ln.tf
ln -f -s ../import/aws_db_instance_postgres.tf bastion/aws_db_instance_postgres.ln.tf
# Core
ln -f -s ../common.tf core/common.ln.tf
# DB
ln -f -s ../common.tf db/common.ln.tf
ln -f -s ../import/aws_instance_bastion.tf db/aws_instance_bastion.ln.tf
ln -f -s ../import/aws_db_instance_postgres.tf db/aws_db_instance_postgres.ln.tf
# Domain
ln -f -s ../common.tf domain/common.ln.tf
ln -f -s ../import/aws_lb_main.tf domain/aws_lb_main.ln.tf
# Import
ln -f -s ../common.tf import/common.ln.tf
# Kong
ln -f -s ../common.tf kong/common.ln.tf
ln -f -s ../import/aws_lb_main.tf kong/aws_lb_main.ln.tf
ln -f -s ../import/aws_lb_backend.tf kong/aws_lb_backend.ln.tf
# Kong init
ln -f -s ../common.tf kong_init/common.ln.tf
ln -f -s ../import/aws_instance_bastion.tf kong_init/aws_instance_bastion.ln.tf
ln -f -s ../import/aws_ecs_cluster_cluster.tf kong_init/aws_ecs_cluster_cluster.ln.tf
ln -f -s ../import/aws_lb_target_group_main.tf kong_init/aws_lb_target_group_main.ln.tf
ln -f -s ../import/aws_lb_listener_main.tf kong_init/aws_lb_listener_main.ln.tf
ln -f -s ../import/aws_subnet_private.tf kong_init/aws_subnet_private.ln.tf
ln -f -s ../import/aws_subnet_private_2.tf kong_init/aws_subnet_private_2.ln.tf
ln -f -s ../import/aws_security_group_private_sg.tf kong_init/aws_security_group_private_sg.ln.tf
ln -f -s ../import/aws_cloudwatch_log_group_ecs.tf kong_init/aws_cloudwatch_log_group_ecs.ln.tf
ln -f -s ../import/aws_db_instance_postgres.tf kong_init/aws_db_instance_postgres.ln.tf

echo "> Loading environment variables"
# source .env
if [ -f .env ]; then
	export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
else
	echo "No .env file found"
fi

echo "> Checking login credentials"
bash test_login.sh

echo "Done initializing"
echo ""