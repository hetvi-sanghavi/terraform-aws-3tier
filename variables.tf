# --- root/variables.tf ---

variable "access_ip" {
  type = string
}

variable "db_name" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "secret_name" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type = string
}