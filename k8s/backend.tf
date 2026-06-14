terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team_axel"
    key            = "cloudmart/k8s-config/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "cloudmart-tfstate-lock"
  }
}
