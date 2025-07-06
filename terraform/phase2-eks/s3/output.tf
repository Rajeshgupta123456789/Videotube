output "s3_bucket_name" {
  value = aws_s3_bucket.video_uploads.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.video_uploads.arn
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.video_uploads.bucket_regional_domain_name
  description = "S3 bucket domain name for CloudFront origin"
}
