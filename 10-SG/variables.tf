variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "Created Security group for bastion instance"
}

variable "vpn_ingress" {
  type    = list(number)
  default = [22, 443, 943, 1194]
}