resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "videotube-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "videotube-redis-subnet-group"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "videotube-redis-sg"
  description = "Allow access to Redis from app"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.app_sg_id] # App or backend SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "videotube-redis-sg"
  }
}

resource "aws_elasticache_replication_group" "videotube_redis" {
  replication_group_id          = "videotube-redis"
  description                   = "Videotube Redis for caching"
  engine                        = "redis"
  engine_version                = "7.1"
  node_type                     = "cache.t3.micro"
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  replicas_per_node_group       = 1
  num_node_groups               = 1
  parameter_group_name          = "default.redis7"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids            = [aws_security_group.redis_sg.id]

  tags = {
    Name = "videotube-redis"
  }
}
