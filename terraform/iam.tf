resource "aws_iam_user" "developer" {
  name = "innovatemart-developer"
  path = "/developers/"

  tags = {
    Role = "Developer"
  }
}

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

resource "aws_iam_policy" "eks_readonly" {
  name        = "EKSReadOnlyAccess"
  description = "Read-only access to EKS cluster resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "developer_eks_readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.eks_readonly.arn
}

resource "kubernetes_cluster_role" "readonly" {
  metadata {
    name = "readonly-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "services", "deployments", "configmaps", "secrets", "logs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "developer_readonly" {
  metadata {
    name = "developer-readonly-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.readonly.metadata[0].name
  }

  subject {
    kind = "User"
    name = "innovatemart-developer"
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode([
      {
        userarn  = aws_iam_user.developer.arn
        username = "innovatemart-developer"
        groups   = []
      }
    ])
  }

  force = true

  depends_on = [module.eks]
}
