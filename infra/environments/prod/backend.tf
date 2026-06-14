terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team-axel-8"
    key            = "environments/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudmart-tfstate-lock"
    encrypt        = true
  }
}
