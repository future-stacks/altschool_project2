module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    main = {
      name = "main-node-group"
      
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      
      min_size     = 2
      max_size     = 4
      desired_size = 2
      
      disk_size = 20
      
      labels = {
        role = "worker"
      }
    }
  }

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}
