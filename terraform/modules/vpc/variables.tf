variable "project_name" {
  description = "project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "public subnet cidr"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "private subnet cidr"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

