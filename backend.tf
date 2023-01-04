terraform {
  backend "s3" {
    bucket = "awss3clonebucket"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}