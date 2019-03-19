## Define the internet gateway ##
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.name}.${var.domain} VPC IGW1"
  }
}

## Define a route table record to the internet gateway for public subnet 1 ##
resource "aws_route_table" "odc-public-subnet1-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Public Subnet 2 RT",
      "KubernetesCluster", "${var.name}.${var.domain}",
      "kubernetes.io/kops/role", "private"
    )
  )}"
}

## Define a route table record to the internet gateway for public subnet 2 ##
resource "aws_route_table" "odc-public-subnet2-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.name}.${var.domain} - Public Subnet 2 RT",
      "KubernetesCluster", "${var.name}.${var.domain}",
      "kubernetes.io/kops/role", "private"
    )
  )}"
}

## Assign the route table records to the public Subnets ##
resource "aws_route_table_association" "odc-public-rt-os1" {
  subnet_id = "${aws_subnet.public-subnet1.id}"
  route_table_id = "${aws_route_table.odc-public-subnet1-rt.id}"
}
resource "aws_route_table_association" "odc-public-rt-os2" {
  subnet_id = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.odc-public-subnet2-rt.id}"
}