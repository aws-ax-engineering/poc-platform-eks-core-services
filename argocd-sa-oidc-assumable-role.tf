# module "irsa_argocd_server_role" {
#   count                         = var.argo_server ? 1 : 0
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "5.30.0"
#   create_role                   = true

#   role_name                     = "${var.instance_name}-argocd-server-sa"
#   provider_url                  = data.aws_eks_cluster.existing_cluster.identity[0].oidc[0].issuer

#   role_policy_arns              = [aws_iam_policy.argocd_server_role_policy.arn]
#   oidc_fully_qualified_subjects = [
#     "system:serviceaccount:argocd:argocd-server",
#     "system:serviceaccount:argocd:argocd-application-controller",
#     "system:serviceaccount:argocd:argocd-applicationset-controller",
#     "system:serviceaccount:argocd:argocd-notifications-controller"
#   ]
#   number_of_role_policy_arns    = 1
# }

# resource "aws_iam_policy" "argocd_server_role_policy" {
#   name        = "${var.instance_name}-argocd-server-sa-policy"
#   policy      = data.aws_iam_policy_document.argocd_server.json
# }

# data "aws_iam_policy_document" "argocd_server" {
#   statement {
#     effect = "Allow"
#     actions = ["*"]
#     resources = ["*"]
#   }
# }

resource "aws_iam_role" "argocd_server_sa" {
  name               = "${var.instance_name}-argocd-server-sa"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/${data.aws_eks_cluster.existing_cluster.identity[0].oidc[0].issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "ForAllValues:StringEquals": {
          "${data.aws_eks_cluster.existing_cluster.identity[0].oidc[0].issuer}:sub": [
            "system:serviceaccount:argocd:argocd-server",
            "system:serviceaccount:argocd:argocd-application-controller",
            "system:serviceaccount:argocd:argocd-applicationset-controller",
            "system:serviceaccount:argocd:argocd-notifications-controller"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "argocd_sa_policy" {
  name        = "${var.instance_name}-argocd-server-sa-policy"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::<prod-aws-account-id>:role/POCTerraformRole"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argocd_sa_policy_attachment" {
  role       = aws_iam_role.argocd_server_sa.name
  policy_arn = aws_iam_policy.argocd_sa_policy.arn
}
