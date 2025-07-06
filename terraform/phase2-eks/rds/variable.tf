variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "db_name" {
  description = "The name of the default database to create"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  type        = string
}
