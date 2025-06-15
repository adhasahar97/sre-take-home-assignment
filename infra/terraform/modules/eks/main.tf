resource "aws_eks_cluster" "feedme-sre" {
  name = "feedme-sre"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.33"

  vpc_config {
    subnet_ids = [
      var.subnet_a_id,
      var.subnet_b_id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
}

data "tls_certificate" "feedme-sre" {
  url = aws_eks_cluster.feedme-sre.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "feedme-sre" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.feedme-sre.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.feedme-sre.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "feedme_sre_ebs_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.feedme-sre.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.feedme-sre.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs-csi" {
  assume_role_policy = data.aws_iam_policy_document.feedme_sre_ebs_csi_assume_role_policy.json
  name               = "AmazonEKS_EBS_CSI_DriverRole"
}

resource "aws_iam_role_policy_attachment" "ebs-csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs-csi.name
}

resource "aws_iam_role" "cluster" {
  name               = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "node" {
  name               = "eks-auto-node-example"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}

## Node Group IAM Role and Policies
# This IAM Role is used by the EKS Node Group to allow EC2 instances to
# communicate with the EKS Cluster and perform necessary operations.
# The policies attached to this role provide the necessary permissions
# for the worker nodes to function properly within the EKS environment.

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.feedme-sre.name
  node_group_name = "nodegroup"
  node_role_arn   = aws_iam_role.nodegroup.arn
  subnet_ids      = [
      var.subnet_a_id,
      var.subnet_b_id
  ]
  instance_types = [
    "r6g.xlarge",
    "r7g.xlarge",
    "m6g.2xlarge",
    "m7g.2xlarge",
  ]
  ami_type = "BOTTLEROCKET_ARM_64"
  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.nodegroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodegroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodegroup-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "nodegroup" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "nodegroup-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "nodegroup-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup.name
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "current-user-admin" {
  cluster_name  = aws_eks_cluster.feedme-sre.name
  principal_arn = "arn:aws:iam::955059924186:role/terraform-admin-role"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "current-user-admin" {
  cluster_name  = aws_eks_cluster.feedme-sre.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::955059924186:role/terraform-admin-role"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "sso-user-admin" {
  cluster_name  = aws_eks_cluster.feedme-sre.name
  principal_arn = "arn:aws:iam::955059924186:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_40cd3c332a9d6ca6"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso-user-admin" {
  cluster_name  = aws_eks_cluster.feedme-sre.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::955059924186:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_40cd3c332a9d6ca6"

  access_scope {
    type = "cluster"
  }
}