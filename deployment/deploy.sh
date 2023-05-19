#!/bin/bash
set -e

source init.sh

if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
    echo "Deploying core"
    cd core && terraform init
    # If import.sh exists and no terraform.tfstate exists, then run it
    if [ -f import.sh ] && [ ! -f terraform.tfstate ]; then
		terraform init && bash import.sh && rm import.sh
	else
		terraform init
	fi
    terraform apply -auto-approve && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Deploying bastion"
	cd bastion && terraform init
	# If import.sh exists and no terraform.tfstate exists, then run it
	if [ -f import.sh ] && [ ! -f terraform.tfstate ]; then
		terraform init && bash import.sh && rm import.sh
	else
		terraform init
	fi
	terraform apply -auto-approve && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
    echo "Creating databases and users"
    cd db && terraform init
    # If import.sh exists and no terraform.tfstate exists, then run it
	if [ -f import.sh ] && [ ! -f terraform.tfstate ]; then
		terraform init && bash import.sh && rm import.sh
	else
		terraform init
	fi
	terraform apply -auto-approve && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Deploying app"
	cd app && terraform init
	# If import.sh exists and no terraform.tfstate exists, then run it
	if [ -f import.sh ] && [ ! -f terraform.tfstate ]; then
		terraform init && bash import.sh && rm import.sh
	else
		terraform init
	fi
	terraform apply -auto-approve && cd ..
fi
echo "Done deploying"