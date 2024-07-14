# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "lambda_identity_timeout" {

  description = "Lambda Identity timeout"

  type    = number
  default = 3000
}

variable "node_runtime" {

  description = "NodeJS runtime version"
  type = string
  default = "nodejs18.x"
}

variable "image_tag" {

  description = "Image Version"
  type = string
  default = "1.0.0"
}

variable "stage_name" {

  description = "Stage Name"
  type = string
  default = "dev"
}

variable "project_name" {

  description = "Project Name"
  type = string
  default = "pwd"
}

variable "service_name" {

  description = "Service Name"
  type = string
  default = "password"
}

variable "domain_name" {

  description = "Domain Name"
  type = string
  default = "Password"
}

variable "commit_id" {

  description = "SCM Commit ID"
  type = string
  default = "cbf6c7b"
}