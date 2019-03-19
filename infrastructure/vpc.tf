## Define our VPC ##
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - opendatacube-vpc"
    )
  )}"
}