output "eks_cluster_name" {
  value = module.capstone_eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.capstone_eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.capstone_app_repo.repository_url
}

