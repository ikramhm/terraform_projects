terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  #backend "s3" {
  #bucket         = "ikram-terraform-s3"
  #key            = "3-tier-arch/terraform.tfstate"
  #region         = "eu-west-2"
  #dynamodb_table = "ikram-terraform-statelock"
  #}
}

provider "aws" {
  region = "eu-west-2"
}
