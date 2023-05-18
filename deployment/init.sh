echo "Creating symlinks for common files"
ln -f -s ../common/common.tf core/common.tf
ln -f -s ../common/common.tf db/common.tf
ln -f -s ../common/core.tf db/core.tf
ln -f -s ../common/bastion.tf db/bastion.tf
ln -f -s ../common/common.tf app/common.tf
ln -f -s ../common/core.tf app/core.tf
ln -f -s ../common/common.tf bastion/common.tf
ln -f -s ../common/core.tf bastion/core.tf

echo "Loading environment variables"
# source .env
if [ -f .env ]; then
	export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi