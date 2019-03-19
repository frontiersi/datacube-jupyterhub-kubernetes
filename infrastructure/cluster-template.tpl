apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: 2019-01-15T05:23:03Z
  name: ${name}.${domain}
spec:
  api:
    loadBalancer:
      type: Public
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://${statestore}/${name}.${domain}
  dnsZone: ${domain}
  etcdClusters:
  - etcdMembers:
    - instanceGroup: master-${private_az1}
      name: a
    name: main
  - etcdMembers:
    - instanceGroup: master-${private_az1}
      name: a
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: 1.10.12
  masterPublicName: api.${name}.${domain}
  networkCIDR: ${vpc_cidr}
  networkID: ${vpc_id}
  networking:
    calico: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: ${private_subnet_cidr1}
    id: ${private_subnet_id1}
    name: Private-subnet1
    type: Private
    zone: ${private_az1}
  - cidr: ${private_subnet_cidr2}
    id: ${private_subnet_id2}
    name: Private-subnet2
    type: Private
    zone: ${private_az2}
  - cidr: ${public_subnet_cidr1}
    id: ${public_subnet_id1}
    name: utility-${public_az1}
    type: Utility
    zone: ${public_az1}
  - cidr: ${public_subnet_cidr2}
    id: ${public_subnet_id2}
    name: utility-${public_az2}
    type: Utility
    zone: ${public_az2}
  topology:
    dns:
      type: Public
    masters: private
    nodes: private
---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2019-01-14T01:16:44Z
  labels:
    kops.k8s.io/cluster: ${name}.${domain}
  name: master-${private_az1}
spec:
  profile: ${master_role}
  image: kope.io/k8s-1.10-debian-jessie-amd64-hvm-ebs-2018-08-17
  machineType: ${master_size}
  maxSize: ${master_count}
  minSize: ${master_count}
  nodeLabels:
    kops.k8s.io/instancegroup: master-${private_az1}
  role: Master
  subnets:
  - Private-subnet1
---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: 2019-01-14T01:16:44Z
  labels:
    kops.k8s.io/cluster: ${name}.${domain}
  name: nodes
spec:
  profile: ${node_role}
  image: kope.io/k8s-1.10-debian-jessie-amd64-hvm-ebs-2018-08-17
  machineType: ${node_size}
  maxSize: ${node_count}
  minSize: ${node_count}
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  cloudLabels:
    k8s.io/cluster-autoscaler/${name}.${domain}: ""
    k8s.io/cluster-autoscaler/enabled: ""
    k8s.io/cluster-autoscaler/node-template/label: ""
    kubernetes.io/cluster/${name}.${domain}: owned
  role: Node
  subnets:
  - Private-subnet1
  - Private-subnet2