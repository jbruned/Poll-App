variable "AWS_REGION" {
	type    = string
	default = "us-east-1"
}

variable "AWS_ACCOUNT_ID" {
	type      = string
	sensitive = true
}

variable "RDS_USERNAME" {
	type    = string
	default = "postgres"
}

variable "RDS_PASSWORD" {
	type      = string
	sensitive = true
}

variable "POSTGRES_VERSION" {
	type    = string
	default = "14.6"
}

variable "POSTGRES_PORT" {
	type    = number
	default = 5432
}

variable "EXPOSED_PORT" {
	type    = number
	default = 80
}

variable "DB_NAME" {
	type    = string
	default = "polldb"
}

variable "DB_USER" {
	type    = string
	default = "flask"
}

variable "DB_PASSWORD" {
	type      = string
	sensitive = true
}

variable "KONG_DB_NAME" {
	type    = string
	default = "kongdb"
}

variable "KONG_DB_USER" {
	type    = string
	default = "kong"
}

variable "KONG_DB_PASSWORD" {
	type      = string
	sensitive = true
}

variable "KONG_VERSION" {
	type    = string
	default = "3.2.1.0"
}

variable "KONG_CONTAINER_NAME" {
	type    = string
	default = "kong"
}

variable "KONG_LOG_PATH" {
	type    = string
	default = "/usr/local/kong/logs"
}

variable "KONG_ADMIN_PORT" {
	type    = number
	default = 8001
}

variable "KONG_ADMIN_ROUTE" {
	type    = string
	default = "/kong-admin"
}

variable "KONG_DEFAULT_PORT" {
	type    = number
	default = 8000
}

variable "CONTAINER_NAME" {
	type    = string
	default = "pollapp"
}

variable "AWS_IMAGE_NAME" {
	type    = string
	default = "poll-app-gtio"
}

variable "CONTAINER_COUNT" {
	type        = number
	description = "Number of containers with our app to run"
	default     = 2
}

variable "CONTAINER_CPU" {
	type        = number
	description = "CPU to allocate to each container of our app"
	default     = 512
}

variable "CONTAINER_MEMORY" {
	type        = number
	description = "Memory to allocate to each container of our app"
	default     = 1024
}

variable "PREFIX" {
	type    = string
	default = "pollapp"
}

variable "BASTION_HOST_NAME" {
	type    = string
	default = "host"
}

variable "BASTION_DISPOSABLE_ID" {
	type    = string
	default = ""
}

variable "SSL_CERT_BASE64" {
	type      = string
	sensitive = true
	default   = ""
}

variable "SSL_KEY_BASE64" {
	type      = string
	sensitive = true
	default   = ""
}

locals {
	ROLE_ARN  = "arn:aws:iam::${var.AWS_ACCOUNT_ID}:role/LabRole"
	IMAGE_URL = "${var.AWS_ACCOUNT_ID}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.AWS_IMAGE_NAME}:latest"
	PREFIX    = var.PREFIX
	USE_SSL = var.SSL_CERT_BASE64 != "" && var.SSL_KEY_BASE64 != ""
	myip = chomp(data.http.myip.response_body)

	// Identifiers
	DB_INSTANCE_IDENTIFIER = "${local.PREFIX}-postgres"
	PRIVATE_SUBNET_NAME    = "${local.PREFIX}-private-subnet"
	PRIVATE_SUBNET_NAME_2  = "${local.PREFIX}-private-subnet2"
	PUBLIC_SUBNET_NAME     = "${local.PREFIX}-public-subnet"
	PUBLIC_SUBNET_NAME_2   = "${local.PREFIX}-public-subnet2"
	VPC_NAME               = "${local.PREFIX}-vpc"
	PRIVATE_SG_NAME        = "${local.PREFIX}-private-sg"
	PUBLIC_SG_NAME         = "${local.PREFIX}-public-sg"
	RDS_SG_NAME            = "${local.PREFIX}-rds-sg"
	RDS_SUBNET_GROUP_NAME  = "${local.PREFIX}-rds-subnet-group"
	BASTION_HOST_NAME      = "${local.PREFIX}-bastion-${var.BASTION_HOST_NAME}${var.BASTION_DISPOSABLE_ID}"
	LOG_GROUP_NAME		   = "${local.PREFIX}-ecs-logs"
}

provider "aws" {
	region = var.AWS_REGION
}

data "aws_availability_zones" "available" {}

data "http" "myip" {
	url = "https://api.my-ip.io/ip.txt"
}
