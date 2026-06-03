terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team-axel"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}
