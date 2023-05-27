#!/bin/bash
set -e

TEMP="temp"
IMPORT="tf_import.sh"

source init.sh

echo "Importing already existing resources from the cloud"
cd import
rm -rf "$IMPORT"
rm -rf "$TEMP"
touch $IMPORT
mkdir -p "$TEMP"
cd "$TEMP"
for file in ../*.tf; do
	cp "$file" .
	cp ../common.ln.tf .
	echo -n "> Importing $file... "
	(
		terraform init > /dev/null && terraform apply -auto-approve -compact-warnings -input=false > /dev/null 2>&1 && \
		terraform output | grep -E '^([A-Za-z0-9_]+)--([A-Za-z0-9_]+) = "([^"]*)"$' | sed -e 's/--/./g' -e 's/ = / /g' -e 's/\"//g' -e 's/^/(terraform import /' -e 's/$/ > \/dev\/null 2>\&1 \&\& echo "Resource imported") || echo "Imported resource not found in the configuration"/' >> ../$IMPORT && \
		echo "Done"
	) || echo "Resource doesn't exist in the cloud"
	# Remove all files
	rm -rf ./*
done

cd ..
rm -rf "$TEMP"
cp $IMPORT ../app/$IMPORT
cp $IMPORT ../bastion/$IMPORT
cp $IMPORT ../core/$IMPORT
cp $IMPORT ../db/$IMPORT
cp $IMPORT ../domain/$IMPORT
cp $IMPORT ../kong/$IMPORT
cp $IMPORT ../kong_init/$IMPORT
rm $IMPORT

echo "Done importing"
