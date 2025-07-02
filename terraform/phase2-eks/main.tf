
module "vpc" {
  source = "./vpc"
}

module "eks" {
  source         = "./eks"
  cluster_name   = "my-eks-cluster"
  cluster_role_arn = aws_iam_role.eks_cluster.arn
  subnet_ids     = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}
