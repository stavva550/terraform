provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
  create_igw     = false
  igw_name       = "${var.vpc_name}-igw"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

