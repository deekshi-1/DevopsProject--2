provider "aws" {
  region = var.region
}

module "networking" {
  source                = "../../modules/networking"
  env                   = terraform.workspace
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
}

module "security" {
  source     = "../../modules/security"
  env        = terraform.workspace
  vpc_id     = module.networking.vpc_id
  admin_cidr = var.admin_cidr
}

module "iam" {
  source = "../../modules/iam"
  env    = terraform.workspace
}

module "compute" {
  source                = "../../modules/compute"
  env                   = terraform.workspace
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  instance_count        = var.instance_count
  public_subnet_ids     = module.networking.public_subnet_ids
  sg_id                 = module.security.web_sg_id
  instance_profile_name = module.iam.instance_profile_name
  key_name              = var.key_name
}