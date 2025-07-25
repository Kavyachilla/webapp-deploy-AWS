provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "webapp-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"  # ✅ downgrade to stable version

  cluster_name    = "webapp-cluster"
  cluster_version = "1.29"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    web_nodes = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
    }
  }

  enable_irsa = true
}
