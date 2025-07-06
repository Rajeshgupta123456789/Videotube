output "rds_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.videotube_rds.endpoint
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}
