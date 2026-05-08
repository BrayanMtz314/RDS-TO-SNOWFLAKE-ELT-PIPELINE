variable "vpc_id" {
    type = string
}

variable "db_subnet_group_name" {
    type = string
}

variable "db_username" {
    type = string
}


variable "db_password" {
    type = string
    sensitive = true
}

variable "instance_class" {
    type = string
}

variable "allocated_storage" {
    type = number
}

variable "project_name" {
    type = string
}


variable "private_subnet_ids" {
  type        = list(string)
}

variable "public_subnet_id" {
  type        = string
}

variable "bucket_name" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "ec2_ami" {
    type = string
}  

variable "glue_sg_id" {
    type = string
}