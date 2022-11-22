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
        #key = "*/terraform.tfstate"
        #region = "eu-west-2"
        #dynamodb_table = "ikram-terraform-statelock"
    #}
    }
    

provider "aws" {
    region = "eu=west-2"
    #setting ENVIRONMENTAL VARIABLES for ACCESS CREDENTIALS
}
module "ethereum-node" {
  source  = "cardstack/ethereum-node/aws"
  version = "0.1.3"
  network = "rinkeby"
  public_key = file("./geth-key.pem") #remember to add this file to gitignore, when committing
  availability_zone = "eu-west-2"
  instance_type = "m4.xlarge"
}

#https://github.com/cardstack/terraform-aws-ethereum-node
#https://registry.terraform.io/modules/cardstack/ethereum-node/aws/latest
