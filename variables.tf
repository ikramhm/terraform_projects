variable "cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0.24"]
}

variable "cidr-private-subnet" {
  type    = list(any)
  default = ["10.0.3.0/24", "10.0.4.0.24"]
}


variable "az" {
  type    = list(any)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "record_name" {
  type        = string
  default     = "www"
  description = "subdomain name of www"
}