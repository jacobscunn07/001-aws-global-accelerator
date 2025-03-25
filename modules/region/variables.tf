variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}