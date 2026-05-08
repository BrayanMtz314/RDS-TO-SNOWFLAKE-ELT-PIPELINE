terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"    
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.0.0" 
    }
  }
}
provider "aws" {
    region = var.region
}

provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role 

  preview_features_enabled = [
    "snowflake_storage_integration_resource",
    "snowflake_file_format_resource",
    "snowflake_stage_resource",
    "snowflake_table_resource",
    "snowflake_table_constraint_resource"
  ]
}