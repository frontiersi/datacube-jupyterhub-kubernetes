## Data template to create the kubernetes config file ##
data "template_file" "cluster-config" {
  template =  "${file("cluster-template.tpl")}"
  vars {
    name = "${var.name}"
    domain = "${var.domain}"
    statestore = "${var.kubernetes_state_store}"
    vpc_cidr = "${var.vpc_cidr}"
    vpc_id = "${aws_vpc.default.id}"
    private_subnet_cidr1 = "${var.private_subnet_cidr1}"
    private_subnet_id1  = "${aws_subnet.private-subnet1.id}"
    private_az1 = "${var.private_az1}"
    private_subnet_cidr2 = "${var.private_subnet_cidr2}"
    private_subnet_id2 = "${aws_subnet.private-subnet2.id}"
    private_az2 = "${var.private_az2}"
    public_subnet_cidr1 = "${var.public_subnet_cidr1}"
    public_subnet_id1  = "${aws_subnet.public-subnet1.id}"
    public_az1 = "${var.public_az1}"
    public_subnet_cidr2 = "${var.public_subnet_cidr2}"
    public_subnet_id2 = "${aws_subnet.public-subnet2.id}"
    public_az2 = "${var.public_az2}"
    master_role = "${aws_iam_instance_profile.masters_profile.arn}"
    master_size = "${var.master_size}"
    master_count = "${var.master_count}"
    node_role = "${aws_iam_instance_profile.nodes_profile.arn}"
    node_size = "${var.node_size}"
    node_count = "${var.node_count}"
  }
}