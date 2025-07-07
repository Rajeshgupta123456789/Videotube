output "rds_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.videotube_rds.endpoint
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "secret_arn" {
  description = "The ARN of the RDS credentials secret"
  value       = var.secret_arn
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.videotube_rds.endpoint
}
