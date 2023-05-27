# PollApp Cloud Deployment

This is a guide to deploy the PollApp application to the cloud. The application is deployed to AWS using *Terraform*. The resources have been divided into several modules:

- `core`: VPC, subnets, security groups, database, cluster, load balancer... Common resources that should never be destroyed.
- `bastion`: bastion host to access the private instances.
- `db`: database initialization, creation of the databases, roles and permission grants.
- `kong_init`: run migrations and create the Kong container.
- `app`: application containers, load balancer, auto scaling group, etc.
- `kong`: setup Kong, create the services, routes, auth plugins, etc.
- `common`: contains common variables and resource imports via `data` blocks.

Some *bash* scripts have been created to automate the deployment process. They are located in the `/deployment` folder and explained in the following section.

## Deploy process

As stated in the main [README](../README.md), the deployment process is automated using *GitHub Actions*. However, you can also deploy the application manually by following these steps:

0. Install *Terraform* and set up your AWS account. Create and complete the `.env` file in the `/deployment` folder → see [`.env.example`](.env.example).
    - Multiple independent environments can be created in the same AWS account by using the `TF_VAR_PREFIX` variable. Example: `TF_VAR_PREFIX=dev`. 
1. Run `import.sh` to import the resources from the cloud (optional).
2. Run `deploy.sh` to deploy the application to the cloud.
    - Optionally, you can run `deploy.sh <module>` to deploy only a specific module out of the previous list (except `common`). Example: `deploy.sh app`.
3. Run `destroy.sh <module>` to destroy the resources of a module if necessary. Example: `destroy.sh app`.
    - You can also run `destroy.sh` to destroy all the resources.
4. Run `clean.sh` to clear the *Terraform* states. You can then run `import.sh` again to import the resources from the cloud when necessary.
    - You can also clean the states of a specific module by running `clean.sh <module>`.
