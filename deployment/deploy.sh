#!/bin/bash
set -e

source init.sh

if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
    echo "Deploying core"
    cd core && terraform init && terraform apply -auto-approve && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Deploying bastion"
	cd bastion && terraform init && terraform apply -auto-approve && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
    echo "Creating databases and users"
    cd db && terraform init \
		&& terraform apply -auto-approve && cd ..
		# && (terraform import postgresql_database.polldb polldb || echo "polldb doesn't exist and will be created") \
		# && (terraform import postgresql_database.kongdb kongdb || echo "kongdb doesn't exist and will be created") \
		# && (terraform import postgresql_role.app_user flask || echo "flask role doesn't exist and will be created") \
		# && (terraform import postgresql_role.kong_user kong || echo "kong role doesn't exist and will be created") \
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Deploying app"
	cd app && terraform init && terraform apply -auto-approve && cd ..
fi
echo "Done deploying"