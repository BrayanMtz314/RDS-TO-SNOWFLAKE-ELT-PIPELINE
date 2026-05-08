variable "project_name" {
    type = string
}

variable "bucket_name" {
    type = string
}


variable "snowflake_iam_user_arn" {
  type        = string
  description = "ARN del usuario de IAM generado por Snowflake"
}

variable "snowflake_external_id" {
  type        = string
  description = "External ID generado por Snowflake"
}

variable "account_id" {
    type = string
  
}