
resource "aws_db_instance" "youtube_metadata" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.t3.micro"
  name                 = "youtubeapp"
  username             = "postgres"
  password             = "securepassword123"
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
}
