terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team-axel"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudmart-tfstate-lock"
    encrypt        = true
  }
}
