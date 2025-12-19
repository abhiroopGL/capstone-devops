module "capstone_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "capstone-eks-cluster"
  cluster_version = "1.29"

  vpc_id     = aws_vpc.capstone_vpc.id
  subnet_ids = aws_subnet.capstone_private_subnet[*].id

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    Name = "capstone-eks-cluster"
    Project = "capstone"
  }

  eks_managed_node_groups = {
    capstone_nodegroup = {
      name           = "capstone-eks-nodegroup"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      tags = {
        Name = "capstone-eks-nodegroup"
      }
    }
  }
}

