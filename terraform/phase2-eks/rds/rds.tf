resource "aws_db_subnet_group" "videotube_subnet_group" {
  name       = "videotube-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "videotube-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "videotube-rds-sg"
  description = "Allow RDS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "videotube-rds-sg"
  }
}


data "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = var.secret_arn
}

resource "aws_db_instance" "videotube_rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.videotube_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  username = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)["password"]
  tags = {
    Name = "videotube-rds"
  }
}
