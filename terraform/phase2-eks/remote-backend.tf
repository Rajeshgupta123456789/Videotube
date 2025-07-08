terraform {
  backend "s3" {
    bucket         = "videotube-terraform-state"
    key            = "videotube/phase2-eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "videotube-terraform-lock"
  }
}

