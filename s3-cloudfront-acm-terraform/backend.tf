terraform {
    #required_version =  "0.11.0"
     required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    #backend "s3" {
        #bucket = "ikram-terraform-s3"
        #key = "mystorybucket/terraform.tfstate"
        #region = "eu-west-2"
        #dynamodb_table = "ikram-terraform-statelock"
    #}
    }
    

provider "aws" {
    region = "eu=west-2"
    #SET ENVIRONMENTAL VARIABLES for ACCESS CREDENTIALS
}
provider "aws" {
    region = "us-east-1"
    alias = "us-east-1"
}