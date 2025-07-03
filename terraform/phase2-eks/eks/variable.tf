variable "vpc_id" {
        type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
        type = string
}

variable "cluster_name" {
  default = "my-eks-cluster"
   type = string

}
