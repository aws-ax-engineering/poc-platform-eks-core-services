data "aws_eks_cluster" "existing_cluster" {
  name = var.instance_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.instance_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.existing_cluster.identity[0].oidc[0].issuer
}
