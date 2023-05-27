#!/bin/bash
set -e

TEMP="temp"
IMPORT="tf_import.sh"
MODULES=(app bastion core db domain kong kong_init)

source init.sh
cd import

if [ "$#" -eq 0 ] || [ "$1" = "fetch" ]; then
	echo "Importing already existing resources from the cloud"
	rm -rf "$IMPORT"
	rm -rf "$TEMP"
	touch $IMPORT
	mkdir -p "$TEMP"
	cd "$TEMP"
	for file in ../*.tf; do
		cp "$file" .
		cp ../common.ln.tf .
		echo -n "> Importing resource $file... "
		(
			terraform init > /dev/null && terraform apply -auto-approve -compact-warnings -input=false > /dev/null 2>&1 && \
			terraform output | grep -E '^([A-Za-z0-9_]+)--([A-Za-z0-9_]+) = "([^"]*)"$' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/(terraform import /' -e 's/$/ > \/dev\/null 2>\&1 \&\& echo "Resource imported") || echo "Imported resource not found in the configuration"/' >> ../$IMPORT && \
			echo "Done"
		) || echo "Resource doesn't exist in the cloud"
		# Remove all files
		rm -rf ./*
	done
	cd ..
	for module in "${MODULES[@]}"; do
		cp $IMPORT "../$module/$IMPORT"
	done
	rm -rf "$TEMP"
	rm $IMPORT
fi

if [ "$#" -eq 0 ] || [ "$1" = "apply" ]; then
	echo "Running generated import scripts"
	for module in "${MODULES[@]}"; do
		echo "> Importing $module Terraform state... "
		terraform init > /dev/null &&  (
			cd "../$module"
			bash $IMPORT
			rm $IMPORT
		) || echo "> Failed to import $module Terraform state"
	done
fi

echo "Done importing"
