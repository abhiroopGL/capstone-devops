resource "aws_ecr_repository" "capstone_app_repo" {
  name = "capstone-app-repo"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "capstone-app-repo"
    Project = "capstone"
  }
}

