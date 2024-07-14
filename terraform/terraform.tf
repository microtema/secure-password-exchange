terraform {

  backend "s3" {
    bucket = "pwd-dev-eu-central-1"
    key    = "customer/terraform-state.json"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.2"
}
