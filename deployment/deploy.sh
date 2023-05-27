#!/bin/bash
set -e

source init.sh
IMPORT="tf_import.sh"

if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
    echo "Deploying core"
    cd core
    terraform init
    if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
    terraform apply -auto-approve -compact-warnings -input=false
    cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Deploying bastion"
	cd bastion
	terraform init
	if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
	terraform apply -auto-approve -compact-warnings -input=false
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
    echo "Creating databases and users"
    cd db
    terraform init
	if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
	terraform apply -auto-approve -compact-warnings -input=false
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong_init" ]; then
	echo "Creating and initializing Kong"
	cd kong_init
	terraform init
	if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
	terraform apply -auto-approve -compact-warnings -input=false
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Deploying app"
	cd app
	terraform init
	if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
	terraform apply -auto-approve -compact-warnings -input=false
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong" ]; then
	echo "Deploying Kong"
	cd kong
	terraform init
	if [ -f $IMPORT ]; then
		bash $IMPORT && rm $IMPORT
	fi
	terraform apply -auto-approve -compact-warnings -input=false || echo "Kong already deployed"
	cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "domain" ]; then
	if [ -z "$IONOS_API_KEY" ]; then
		echo "DOMAIN environment variable is not set"
	else
		echo "Deploying domain"
		cd domain
		terraform init
		if [ -f $IMPORT ]; then
			bash $IMPORT && rm $IMPORT
		fi
		terraform apply -auto-approve -compact-warnings -input=false
		cd ..
	fi
fi
echo "Done deploying"
