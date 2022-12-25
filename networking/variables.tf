#Note that the variables I have listed must be present in the root main.tf file
# --- networking/variables.tf ---

variable "vpc_cidr" {
  type = string
}

variable "private_sn_cidr" {
  type = list(string)
}

variable "public_sn_cidr" {
  type = list(string)
}

variable "private_sn_cidr_db" {
  type = list(string)
}
variable "access_ip" {
  type = string
}

variable "db_subnet_group" {
  type = bool
}

variable "availabilityzone" {}

variable "azs" {}