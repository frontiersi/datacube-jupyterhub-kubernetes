## Define the security group for the postgres rds db. Only allow access to db from the private subnets ##
resource "aws_security_group" "rds_security_group" {
  name        = "${var.name}.${var.domain} - rds_security_group"
  description = "Allow all inbound traffic from the vpc"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr1}","${var.private_subnet_cidr2}"]
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr1}","${var.private_subnet_cidr2}"]
  }
}