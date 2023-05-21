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

variable "CONTAINER_NAME" {
	type    = string
	default = "pollapp"
}

variable "CPU" {
	type    = number
	default = 256
}

variable "MEMORY" {
	type    = number
	default = 512
}

variable "AWS_IMAGE_NAME" {
	type    = string
	default = "poll-app-gtio"
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

locals {
	ROLE_ARN  = "arn:aws:iam::${var.AWS_ACCOUNT_ID}:role/LabRole"
	IMAGE_URL = "${var.AWS_ACCOUNT_ID}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.AWS_IMAGE_NAME}:latest"
	PREFIX    = var.PREFIX

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
}

provider "aws" {
	region = var.AWS_REGION
}

data "aws_availability_zones" "available" {}
