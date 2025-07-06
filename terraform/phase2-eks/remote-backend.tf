terraform {
  backend "s3" {
    bucket         = "Ankitguptavideotube"      ### it should be your bucket name
    key            = "global/dev/terraform.tfstate"
    region         = "us-east-1" # change if you're using a different region
    dynamodb_table = "VideotubeAnkit"           ### it should be your Dynamodb_table name
    encrypt        = true
  }
}
