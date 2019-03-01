
## S3 Bucket for the kubernetes state store ##
resource "aws_s3_bucket" "kubernetes_state_store" {
  bucket = "${var.kubernetes_state_store}"
  acl    = "private"
  tags {
    Name        = "${var.kubernetes_state_store}"
  }
}

## RDS instance ##
resource "aws_db_instance" "odb_postgres" {
  identifier           = "${var.name}-indexer-db"
  allocated_storage    = "${var.db_instance_size}"
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.11"
  instance_class       = "${var.db_instance_type}"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  skip_final_snapshot = true
  vpc_security_group_ids = ["${aws_security_group.rds_security_group.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
}

## RDS instance ##
resource "aws_db_subnet_group" "default" {
  name       = "${var.name}.${var.domain} db subnet group"
  subnet_ids = ["${aws_subnet.private-subnet1.id}","${aws_subnet.private-subnet2.id}"]

  tags {
    Name = "${var.name}.${var.domain} DB subnet group"
  }
}