output "public_zone1" {
    value = "${var.public_az1}"
}
output "public_zone2" {   
    value = "${var.public_az2}"
}
output "state_store" {
  value = "s3://${aws_s3_bucket.kubernetes_state_store.id}"
}
output "name" {
  value = "${var.name}"
}
output "domain" {
  value = "${var.domain}"
}
output "master_size" {
  value = "${var.master_size}"
}
output "cluster-config" {
  value = "${data.template_file.cluster-config.rendered}"
}
output "cluster_name" {
  value = "${var.name}.${var.domain}"
}
output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "db_hostname" {
  value = "${aws_db_instance.odb_postgres.address}"
}
