module "vpc" {
  source = "./modules/vpc"
  project_name = var.project_name
  region       = var.region
  vpc_cidr = var.vpc_cidr
  azs = var.azs
  public_subnets_cidr = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
}

module "rds" {
  source               = "./modules/rds"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.rds_sg_name
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  db_username          = var.db_username
  db_password          = var.db_password
  instance_class      = var.instance_class
  allocated_storage = var.allocated_storage
  bucket_name = module.s3.bucket_name
  ec2_ami = var.ec2_ami
  instance_type = var.instance_type
  glue_sg_id = module.glue.glue_sg_id
}

data "aws_caller_identity" "current" {}

module "s3" {
  source = "./modules/s3"
  project_name = var.project_name
  account_id = data.aws_caller_identity.current.account_id
}

module "glue" {
  source = "./modules/glue"
  project_name = var.project_name
  bucket_name = module.s3.bucket_name
  db_username = var.db_username
  db_password = var.db_password
  db_endpoint = module.rds.db_endpoint
  private_subnet_id = module.vpc.private_subnet_ids[0]
  availability_zone = var.azs[0]
  vpc_id = module.vpc.vpc_id
}

module "snowflake" {
  source = "./modules/snowflake"
  project_name = var.project_name
  bucket_name = module.s3.bucket_name
  account_id = var.account_id
  snowflake_external_id = var.snowflake_external_id
  snowflake_iam_user_arn = var.snowflake_iam_user_arn
}