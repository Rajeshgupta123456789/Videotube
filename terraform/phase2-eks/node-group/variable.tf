variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for worker nodes"
  type        = list(string)
}

variable "ami_type" {
  description = "AMI type for EKS nodes (e.g., BOTTLEROCKET_x86_64)"
  type        = string
  default     = "BOTTLEROCKET_x86_64"
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  description = "EC2 Key Pair name to enable SSH access"
  type        = string
  default     = "id_rsa"
}
