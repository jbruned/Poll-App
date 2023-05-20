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
	terraform init
	(terraform apply -auto-approve -compact-warnings -input=false &&
		terraform output | grep -v -E '^(::debug::|\[command\])' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../core/import.sh) \
		|| echo "The core module is not yet deployed"
	cd ..
	echo "Done creating core import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Creating bastion import script..."
	cd bastion
	terraform init
	(terraform apply -auto-approve -compact-warnings -input=false &&
		terraform output | grep -v -E '^(::debug::|\[command\])' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../bastion/import.sh) \
		|| echo "The bastion host doesn't currently exist"
	cd ..
	echo "Done creating bastion import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
	echo "Creating db import script..."
	cd db
	terraform init
	(terraform apply -auto-approve -compact-warnings -input=false &&
		terraform output | grep -v -E '^(::debug::|\[command\])' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' -e 's/$/ || echo "Resource not found"/' > ../../db/import.sh) \
		|| echo "The databases and users aren't setup yet"
	cd ..
	echo "Done creating db import script"
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Creating app import script..."
	cd app
	terraform init
	(terraform apply -auto-approve -compact-warnings -input=false &&
		terraform output | grep -v -E '^(::debug::|\[command\])' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/terraform import /' > ../../app/import.sh) \
		|| echo "The app isn't deployed yet"
	cd ..
	echo "Done creating app import script"
fi

echo "Done importing"
