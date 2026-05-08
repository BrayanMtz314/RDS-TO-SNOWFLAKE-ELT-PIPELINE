#Main info
variable "region" {
    type = string
}


variable "azs" {
  type = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "You must give at least two azs"
  }
}

variable "public_subnets_cidr" {
  type = list(string)

  validation {
    condition     = length(var.public_subnets_cidr) == length(var.azs)
    error_message = "Public subnets must coincide with the AZ."
  }
}

variable "private_subnets_cidr" {
  type = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) == length(var.azs)
    error_message = "Private subnets must coincide with the AZ"
  }
}

variable "vpc_cidr" {
  type = string
}


variable "project_name" {
  type = string
  
}


# RDS
variable "instance_class" {
  type = string
  
}

variable "allocated_storage" {
  type = number 
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "account_id" {
  type = string
}


# ec2
variable "instance_type" {
    type = string
}

variable "ec2_ami" {
    type = string
}


#SNOWFLAKE
variable "snowflake_organization" {
  type = string
}

variable "snowflake_account" {
  type = string
}

variable "snowflake_user" {
  type = string
}

variable "snowflake_password" {
  type = string
}

variable "snowflake_role" {
  type = string
}

variable "snowflake_external_id" {
  type = string
  default = ""
}

variable "snowflake_iam_user_arn" {
  type = string
  default = ""
}

