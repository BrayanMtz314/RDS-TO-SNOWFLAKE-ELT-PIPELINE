output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "rds_sg_name" {
  value = module.vpc.rds_sg_name
}

output "generated_snowflake_iam_user_arn" {
  value = module.snowflake.generated_snowflake_iam_user_arn
}

output "generated_snowflake_external_id" {
  value = module.snowflake.generated_snowflake_external_id
}