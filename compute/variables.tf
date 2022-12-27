# --- compute/variables.tf ---

variable "bastion_sg" {}
variable "frontend_app_sg" {}
variable "backend_app_sg" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "key_name" {}
variable "lb_tg" {
  type = list(string)
}

variable "bastion_instance_count" {
  type = number
}

variable "instance_type" {
  type = string
}