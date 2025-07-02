
resource "aws_s3_bucket" "video_bucket" {
  bucket = "youtube-video-uploads-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "YouTube Video Bucket"
    Environment = "Dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
