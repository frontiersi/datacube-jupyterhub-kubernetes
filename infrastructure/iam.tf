## Define the kubenetes master instance profile and link the master role ##
resource "aws_iam_instance_profile" "masters_profile" {
  name = "masters.${var.name}.${var.domain}"
  role = "${aws_iam_role.masters_role.name}"
}
## Define the master role ##
resource "aws_iam_role" "masters_role" {
  name = "masters.${var.name}.${var.domain}"
  path = "/"
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "master role",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
## Define the master IAM policy ##
resource "aws_iam_role_policy" "masters_policy" {
  name = "masters_policy"
  role = "${aws_iam_role.masters_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DescribeVolumesModifications",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/KubernetesCluster": "${var.name}.${var.domain}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/KubernetesCluster": "${var.name}.${var.domain}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListServerCertificates",
                "iam:GetServerCertificate"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.kubernetes_state_store}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*"
            ],
            "Resource": "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets",
                "route53:GetHostedZone"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/Z3986PWI67LUG9"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetChange"
            ],
            "Resource": [
                "arn:aws:route53:::change/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
## Define the kubernetes node instance profile ##
resource "aws_iam_instance_profile" "nodes_profile" {
  name = "nodes.${var.name}.${var.domain}"
  role = "${aws_iam_role.nodes_role.name}"
}
## Define the kubernetes node role ##
resource "aws_iam_role" "nodes_role" {
  name = "nodes.${var.name}.${var.domain}"
  path = "/"
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "nodes role",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  provisioner "local-exec" {
    command = "sleep 15"
  }
}
## Define the kubernetes node policy ##
resource "aws_iam_role_policy" "nodes_policy" {
  name = "nodes_policy"
  role = "${aws_iam_role.nodes_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.kubernetes_state_store}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/addons/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/cluster.spec",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/config",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/instancegroup/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/pki/issued/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/pki/private/kube-proxy/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/pki/private/kubelet/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/pki/ssh/*",
                "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/secrets/dockerconfig"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*"
            ],
            "Resource": "arn:aws:s3:::${var.kubernetes_state_store}/${var.name}.${var.domain}/pki/private/calico-client/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/k8s-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}
## Define a indexer role give required access to AWS resources ##
resource "aws_iam_role" "indexer_role" {
  name = "k8s-${var.name}-indexer-role"
  depends_on = ["aws_iam_role.nodes_role"]
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "indexer role",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.name}.${var.domain}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
## Define the IAM permission the indexer pods should have ##
resource "aws_iam_role_policy" "indexer_policy" {
  name = "indexer-policy"
  role = "${aws_iam_role.indexer_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["S3:GetObject"],
      "Resource": [
        "arn:aws:s3:::dea-public-data/*",
        "arn:aws:s3:::landsat-pds/*",
        "arn:aws:s3:::dea-public-data-dev/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["S3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::dea-public-data",
        "arn:aws:s3:::landsat-pds",
        "arn:aws:s3:::dea-public-data-dev"
      ]
    }
  ]
}
EOF
}
## Define the jupyter role to give only the required AWS permissions to jupyter users ##
resource "aws_iam_role" "juypter_role" {
  name = "k8s-${var.name}-jupyter-role"
  depends_on = ["aws_iam_role.indexer_role"]
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "jupyter role",
      "KubernetesCluster", "${var.name}.${var.domain}"
    )
  )}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.name}.${var.domain}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
## Define jupyter AWS permissions ##
resource "aws_iam_role_policy" "juypter_policy" {
  name = "juypter-policy"
  role = "${aws_iam_role.juypter_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["S3:GetObject"],
      "Resource": [
        "arn:aws:s3:::dea-public-data/*",
        "arn:aws:s3:::landsat-pds/*",
        "arn:aws:s3:::dea-public-data-dev/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["S3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::dea-public-data",
        "arn:aws:s3:::landsat-pds",
        "arn:aws:s3:::dea-public-data-dev"
      ]
    }
  ]
}
EOF
}
