terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./vpc"
  region = var.region
}

module "iam" {
  source = "./iam"
}

module "eks" {
  source             = "./eks-cluster"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  cluster_role_arn   = module.iam.eks_cluster_role_arn
}

module "nodegroup" {
  source         = "./node-group"
  cluster_name   = module.eks.cluster_name
  node_role_arn  = module.iam.eks_node_role_arn
  subnet_ids     = module.vpc.public_subnet_ids
  ami_type       = "BOTTLEROCKET_x86_64"
  security_group_ids  = [module.vpc.security_group_id]
  key_name = "id_rsa"
}
