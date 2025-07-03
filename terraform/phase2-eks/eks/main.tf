
resource "aws_eks_cluster" "this" {
    name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.public_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  version = "1.33"
}
