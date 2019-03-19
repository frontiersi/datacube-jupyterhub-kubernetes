## Define elastic ip1 for nat1 ##
resource "aws_eip" "nat1" {
  vpc = true
}
## Define elastic ip2 for nat2 ##
resource "aws_eip" "nat2" {
  vpc = true
}
## Define nat1 and link the elatic ip1 with public subnet 1 ##
resource "aws_nat_gateway" "nat1" {
  allocation_id = "${aws_eip.nat1.id}"
  subnet_id     = "${aws_subnet.public-subnet1.id}"
}
## Define nat2 and link the elatic ip2 with public subnet 2 ##
resource "aws_nat_gateway" "nat2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id     = "${aws_subnet.public-subnet2.id}"
}

## Create a private route table record for nat1 ##
resource "aws_route_table" "private_routetable1" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat1.id}"
  }

  tags {
    label = "private_nat_routetable1"
  }
}
## Create a private route table record for nat2 ##
resource "aws_route_table" "private_routetable2" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat2.id}"
  }

  tags {
    label = "private_nat_routetable2"
  }
}
## Assocate nat1 routetable record with private subnet 1 ##
resource "aws_route_table_association" "private-subnet1" {
  subnet_id      = "${aws_subnet.private-subnet1.id}"
  route_table_id = "${aws_route_table.private_routetable1.id}"
}
## Assocate nat2 routetable record with private subnet 2 ##
resource "aws_route_table_association" "private-subnet2" {
  subnet_id      = "${aws_subnet.private-subnet2.id}"
  route_table_id = "${aws_route_table.private_routetable2.id}"
}