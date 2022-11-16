# --- application/variables.tf ---
variable "web_instance" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  type    = string
}
variable "role_name" {
  type    = string
}
variable "instance_profile" {
  type    = string
}
variable "kms_key_id" {
  type    = string
}
variable "web_sg" {}
variable "private_subnet" {}
variable "ec2_tags" {}


