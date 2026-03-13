terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}
module "rds" {
  source                 = "./modules/rds"
  project_name           = var.project_name
  db_username            = var.db_username
  db_password            = var.db_password
  rds_sg_id              = module.security_groups.rds_sg_id
  private_db_subnet_1_id = module.vpc.private_db_subnet_1_id
  private_db_subnet_2_id = module.vpc.private_db_subnet_2_id
}
provider "aws" {
  region  = var.aws_region
  profile = "zamweather"
}
