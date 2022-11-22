variable "cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0.24"]
}

variable "az" {
  type    = list(any)
  default = ["eu-west-2", "eu-west-1"]
}