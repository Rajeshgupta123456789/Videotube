resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "my-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.ami_type
  disk_size       = 20

  remote_access {
    ec2_ssh_key = var.key_name
  }  

   scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]


  labels = {
    env = "dev"
  }

  tags = {
    Name = "eks-node-group"
  }

  depends_on = [aws_eks_node_group.this]
}
