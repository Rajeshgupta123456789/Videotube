variable "vpc_id" {
  type        = string
  description = "VPC ID for Redis"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for Redis"
}

variable "app_sg_id" {
  type        = string
  description = "App SG ID allowed to connect to Redis"
}
