terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source             = "./modules/vpc"
  cidr_block         = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                = var.azs
  tags               = var.tags
}

# IAM Roles for EKS
module "iam_eks" {
  source       = "./modules/iam-eks"
  cluster_name = var.cluster_name
  tags         = var.tags
}

# EKS Cluster
module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_key_pair_name  = var.ec2_key_pair_name
  cluster_role_arn   = module.iam_eks.cluster_role_arn
  node_role_arn      = module.iam_eks.node_role_arn
  tags               = var.tags
}

# RDS PostgreSQL
module "rds" {
  source                    = "./modules/rds"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  db_password               = var.db_password
  allowed_security_group_ids = [module.eks.node_security_group_id] # update this accordingly
  tags                      = var.tags
}

# S3 Bucket
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
  versioning  = var.s3_versioning
  tags        = var.tags
}
