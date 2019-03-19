variable "vpc_cidr" {
  description = "CIDR for the VPC"
}
variable "public_subnet_cidr1" {
  description = "CIDR for the public subnet1"
}
variable "public_subnet_cidr2" {
  description = "CIDR for the public subnet2"
}
variable "private_subnet_cidr1" {
  description = "CIDR for the private subnet1"
}
variable "private_subnet_cidr2" {
  description = "CIDR for the private subnet1"
}
variable "name" {
  description = "Name for you cluster. Only use alphanumeric characters and hypens"
}
variable "domain" {
  description = "Domain for you cluster. Use .k8s.local at the end for local cluster otherwise use a domain name owned by your account"
}
variable "public_az1" {
  description = "Public availability zone1"
}
variable "public_az2" {
  description = "Public availability zone2"
}
variable "private_az1" {
  description = "Private availability zone1"
}

variable "private_az2" {
  description = "Private availability zone2"
}
variable "region" {
  description = "Region for you cluster"
}
variable "kubernetes_state_store" {
  description = "The s3 bucket to create to store your kubernetes_state_store"
}
variable "db_instance_type" {
  description = "AWS DB instance type for your rds postgres db. E.G. db.t2.small"
}
variable "db_instance_size" {
  description = "AWS rds postgres db size in GB, e.g 20"
}
variable "db_name" {
  description = "The name for your db. Must be alphanumeric characters, underscores, or digits (0-9)."
}
variable "db_username" {
  description = "The master username for your db. Must contain 1 to 63 alphanumeric characters. First character must be a letter."
}
variable "db_password" {
  description = "The master password for your db. Must contain 8 to 128 characters."
}
variable "node_count" {
  description = "The amount of nodes for your kubeneres cluster. E.G. 2"
}
variable "node_size" {
  description = "The AWS instance size for your nodes. E.G. t2.medium"
}
variable "master_count" {
  description = "The amount of masters for your kubernetes cluster. Must be a odd number for consensis. E.G. 1"
}
variable "master_size" {
  description = "The AWS instance size for your master/s. E.G. t2.micro"
}

## Required creation of a local variable here to be used in subnets because of limits of using variables in the name of a tag for subnets.  ##
locals {
  common_tags = "${map(
    "kubernetes.io/cluster/${var.name}.${var.domain}", "shared"
  )}"
}