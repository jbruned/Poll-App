if [ "$#" -eq 0 ] || [ "$1" = "core" ]; then
    echo "Cleaning core state"
    cd core && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "bastion" ]; then
	echo "Cleaning bastion state"
	cd bastion && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "db" ]; then
		echo "Cleaning db state"
	cd db && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong_init" ]; then
	echo "Cleaning kong_init state"
	cd kong_init && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "app" ]; then
	echo "Cleaning app state"
	cd app && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "kong" ]; then
	echo "Cleaning kong state"
	cd kong && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
fi
if [ "$#" -eq 0 ] || [ "$1" = "import" ]; then
	echo "Cleaning import states"
	cd import || exit 1 # && rm -rf .terraform* && rm -rf terraform.tfstate*
	cd core && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
	cd bastion && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
	cd db && rm -rf .terraform* && rm -rf terraform.tfstate* && cd ..
	cd app && rm -rf .terraform* && rm -rf terraform.tfstate* &&
	cd ..
fi
echo "Done cleaning"
