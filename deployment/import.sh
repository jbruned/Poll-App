#!/bin/bash
set -e

source init.sh

cd import
mkdir -p bastion
ln -f -s ../common.tf bastion/common.tf
ln -f -s ../bastion.tf bastion/bastion.tf
mkdir -p core
ln -f -s ../common.tf core/common.tf
ln -f -s ../core.tf core/core.tf
mkdir -p db
ln -f -s ../common.tf db/common.tf
ln -f -s ../db.tf db/db.tf
mkdir -p app
ln -f -s ../common.tf app/common.tf
ln -f -s ../app.tf app/app.tf

if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
	echo "Creating core import script..."
	cd core
	terraform init && terraform apply -auto-approve && terraform output | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../core/import.sh
	cd .. # cd ../../core && terraform init && bash import_core.sh && rm import_core.sh && cd ../import
	echo "Done creating core import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Creating bastion import script..."
	cd bastion
	terraform init && terraform apply -auto-approve && terraform output | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../bastion/import.sh
	cd .. # cd ../../bastion && terraform init && bash import_bastion.sh && rm import_bastion.sh && cd ../import
	echo "Done creating bastion import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
	echo "Creating db import script..."
	cd db
	terraform init && terraform apply -auto-approve && terraform output | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' -e 's/$/ || echo "Resource not found"/' > ../../db/import.sh
	cd .. # cd ../../db && terraform init && bash import_db.sh && rm import_db.sh && cd ../import
	echo "Done creating db import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Creating app import script..."
	cd app
	terraform init && terraform apply -auto-approve && terraform output | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../app/import.sh
	cd .. # cd ../../app && terraform init && bash import_app.sh && rm import_app.sh && cd ../import
	echo "Done creating app import script"
fi


# terraform import postgresql_database.polldb polldb

#if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
#    echo "Importing core"
#    cd import && terraform init && terraform apply -auto-approve && cd ..
#fi
#if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
#	echo "Deploying bastion"
#	cd bastion && terraform init && terraform apply -auto-approve && cd ..
#fi
#if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
#    echo "Creating databases and users"
#    cd db && terraform init \
#		&& terraform apply -auto-approve && cd ..
#		# && (terraform import postgresql_database.polldb polldb || echo "polldb doesn't exist and will be created") \
#		# && (terraform import postgresql_database.kongdb kongdb || echo "kongdb doesn't exist and will be created") \
#		# && (terraform import postgresql_role.app_user flask || echo "flask role doesn't exist and will be created") \
#		# && (terraform import postgresql_role.kong_user kong || echo "kong role doesn't exist and will be created") \
#fi
#if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
#	echo "Deploying app"
#	cd app && terraform init && terraform apply -auto-approve && cd ..
#fi
echo "Done importing"