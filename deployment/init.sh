echo "Creating symlinks for common files"
ln -f -s ../common/common.tf core/common.tf

ln -f -s ../common/common.tf db/common.tf
ln -f -s ../common/core.tf db/core.tf
ln -f -s ../common/bastion.tf db/bastion.tf

ln -f -s ../common/common.tf app/common.tf
ln -f -s ../common/core.tf app/core.tf

ln -f -s ../common/common.tf bastion/common.tf
ln -f -s ../common/core.tf bastion/core.tf

ln -f -s ../common/bastion.tf import/bastion.tf
ln -f -s ../common/core.tf import/core.tf
ln -f -s ../common/common.tf import/common.tf
ln -f -s ../common/kong_init.tf import/kong_init.tf
ln -f -s ../common/app.tf import/app.tf

ln -f -s ../common/core.tf domain/core.tf
ln -f -s ../common/common.tf domain/common.tf

ln -f -s ../common/bastion.tf kong_init/bastion.tf
ln -f -s ../common/common.tf kong_init/common.tf
ln -f -s ../common/core.tf kong_init/core.tf

ln -f -s ../common/bastion.tf kong/bastion.tf
ln -f -s ../common/common.tf kong/common.tf
ln -f -s ../common/app.tf kong/app.tf
ln -f -s ../common/core.tf kong/core.tf

echo "Loading environment variables"
# source .env
if [ -f .env ]; then
	export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi