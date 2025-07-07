variable "s3_bucket_name" {
  description = "The S3 bucket for uploads"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the RDS DB secret in Secrets Manager"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL DB name"
  type        = string
}
