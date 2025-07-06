output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.videotube_cdn.id
  description = "ID of the CloudFront distribution"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.videotube_cdn.domain_name
  description = "Domain name of the CloudFront distribution"
}
