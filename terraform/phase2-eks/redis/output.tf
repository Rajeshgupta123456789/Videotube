output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.videotube_redis.primary_endpoint_address
}
