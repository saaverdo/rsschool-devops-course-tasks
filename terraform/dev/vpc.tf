locals {
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  vpc_subnets     = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 7), cidrsubnet(local.vpc_cidr, 8, 8)]
  nat_gateway     = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.vpc_subnets
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = local.nat_gateway
  single_nat_gateway = true

  tags = {
    Terraform = "true"
  }
}