include .env
all:
	make -B symlinks
	make -B core
	make -B db
	make -B app
	@echo "Everything has been deployed"
symlinks:
	ln -f -s ../common/common.tf core/common.tf
	ln -f -s ../common/common.tf db/common.tf
	ln -f -s ../common/core.tf db/core.tf
	ln -f -s ../common/bastion.tf db/bastion.tf
	ln -f -s ../common/common.tf app/common.tf
	ln -f -s ../common/core.tf app/core.tf
	ln -f -s ../common/common.tf bastion/common.tf
	ln -f -s ../common/core.tf bastion/core.tf
core:
	cd core && terraform init && terraform apply -auto-approve
db:
	# cd db && terraform state list | grep postgresql_ | xargs -I {} terraform state rm {}
	# Remove the state files if they exist
	# cd db && rm -f terraform.tfstate terraform.tfstate.backup
	# cd db && terraform init && terraform apply -auto-approve
	cd db && terraform init
	cd db && (terraform import postgresql_database.polldb polldb || @echo "polldb not found")
	cd db && (terraform import postgresql_database.kongdb kongdb || @echo "kongdb not found")
	cd db && (terraform import postgresql_role.app_user flask || @echo "flask role not found")
	cd db && (terraform import postgresql_role.kong_user kong || @echo "kong role not found")
	cd db && terraform apply -auto-approve
bastion:
	cd bastion && terraform init && terraform apply -auto-approve
app:
	cd app && terraform init && terraform apply -auto-approve
load_env:
	bash load_env.sh