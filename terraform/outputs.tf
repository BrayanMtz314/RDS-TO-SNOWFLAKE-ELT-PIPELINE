

output "generated_snowflake_iam_user_arn" {
  value = module.snowflake.generated_snowflake_iam_user_arn
}

output "generated_snowflake_external_id" {
  value = module.snowflake.generated_snowflake_external_id
}

output "glue_job_name" {
  value = module.glue.glue_job_name
}