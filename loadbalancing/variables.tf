# --- loadbalancing/variables.tf ---

variable "lb_sg" {}
variable "public_subnets" {}
variable "app_asg" {}
variable "vpc_id" {}
variable "http_listener_port" {}
variable "http_listener_protocol" {}
variable "https_listener_port" {}
variable "https_listener_protocol" {}
variable "azs" {}
variable "domain_name" {}