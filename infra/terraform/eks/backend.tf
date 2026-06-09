terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team-axel"
    key            = "cloudmart/eks/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudmart-tfstate-lock"
  }
}
