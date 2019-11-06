terraform {
  required_version = ">= 0.12.2"
  backend "s3" {
    bucket = "bmat-tf-state"
    key    = "BMAT-tfstate/BMAT-dev-eks.tfstate"
    region = "us-east-1"
  
  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "BMAT-dev"
  project_name = "bonnie-mat"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name                   = "${local.cluster_name}-vpc"
  cidr                   = "10.0.0.0/16"
  azs                    = ["us-east-1a","us-east-1b"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets         = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "Project" = "${local.project_name}"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    "Project" = "${local.project_name}"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "Project" = "${local.project_name}"
  }
}

 module "bmat-eks" {
   source                           = "terraform-aws-modules/eks/aws"
   version                          = "6.0.2"
   cluster_name                     = "${local.cluster_name}"
   subnets                          = module.vpc.private_subnets
   vpc_id                           = module.vpc.vpc_id
   workers_role_name                = "${local.cluster_name}-worker-role"
   cluster_iam_role_name            = "${local.cluster_name}-eks-role"
   manage_cluster_iam_resources     = false
   cluster_enabled_log_types        = ["api","audit","authenticator","controllerManager","scheduler"]

   tags = {
     Project = "${local.project_name}"
   }

   worker_groups = [
     {
       name                          = "worker-group"
       instance_type                 = "t2.medium"
       additional_userdata           = ""
       autoscaling_enabled           = true
       protect_from_scale_in         = true
       asg_desired_capacity          = 2
       asg_max_size                  = 6
     },
   ]

 }
