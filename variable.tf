variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
  de
}

variable "subnet_public_1_cidr" {
  type = string
}

variable "subnet_public_2_cidr" {
  type = string
}

variable "subnet_private_web_1_cidr" {
  type = string
}

variable "subnet_private_web_2_cidr" {
  type = string
}

variable "az1_name" {
  type = string
}

variable "az2_name" {
  type = string
}

variable "mgmt_eni_az1" {
  type = string
}

variable "mgmt_eni_az2" {
  type = string
  default = ""
}

variable "stack_name" {
  type = string
  default = "NewRelic"
}
