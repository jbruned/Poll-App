#!/bin/bash
set -e

source init.sh

if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Destroying app"
	cd app
	terraform init && terraform destroy -auto-approve
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong" ]; then
	echo "Destroying Kong"
	cd kong
	terraform init && terraform destroy -auto-approve
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong_init" ]; then
	echo "Destroying Kong init"
	cd kong_init
	terraform init && terraform destroy -auto-approve
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
    echo "Destroying databases and users"
    cd db
    (terraform init && terraform destroy -auto-approve) || echo "Could not destroy databases and users"
    cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Destroying bastion"
	cd bastion
	terraform init && terraform destroy -auto-approve
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
    echo "Destroying core"
    cd core
    terraform init && terraform destroy -auto-approve
    cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "domain" ]; then
	echo "Destroying domain"
	cd domain
	terraform init && terraform destroy -auto-approve
	cd ..
fi
echo "Done destroying"