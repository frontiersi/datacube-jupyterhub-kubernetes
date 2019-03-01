## Define the public subnet1 ##
resource "aws_subnet" "public-subnet1" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr1}"
  availability_zone = "${var.public_az1}"
  map_public_ip_on_launch = false

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Public Subnet 1",
      "kubernetes.io/role/elb", "1",
      "SubnetType", "Utility",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
}
## Define the public subnet2 ##
resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr2}"
  availability_zone = "${var.public_az2}"
  map_public_ip_on_launch = false

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Public Subnet 2",
      "kubernetes.io/role/elb", "1",
      "SubnetType", "Utility",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
}

## Define the private subnet1 ##
resource "aws_subnet" "private-subnet1" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr1}"
  availability_zone = "${var.private_az1}"

    tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Private Subnet 1",
      "kubernetes.io/role/internal-elb", "1",
      "SubnetType", "Private",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
}
## Define the private subnet2 ##
resource "aws_subnet" "private-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr2}"
  availability_zone = "${var.private_az2}"

    tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Private Subnet 2",
      "kubernetes.io/role/internal-elb", "1",
      "SubnetType", "Private",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
}