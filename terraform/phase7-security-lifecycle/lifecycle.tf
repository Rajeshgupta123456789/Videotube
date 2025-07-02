
resource "aws_s3_bucket_lifecycle_configuration" "video_lifecycle" {
  bucket = aws_s3_bucket.video_bucket.id

  rule {
    id     = "ArchiveTranscodedVideos"
    status = "Enabled"

    filter {
      prefix = "transcoded/"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}
