variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}
variable "availability_zone" {
  default = "us-west-1a"
}
variable "my_ip_address" {
  default = "157.131.152.31/32"
}
variable "instance_type" {
  default = "t3.medium"
}
variable "env_prefix" {
  default = "development"
}
variable "my_key_name" {
  default = "terraform"
}

variable "jenkins_ip_address" {
  default = "165.232.141.93/32"
}

variable "private_key_location" {
  default = "../../../../.ssh/terraform.pem"
}