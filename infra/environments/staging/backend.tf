terraform {
  backend "s3" {
    bucket         = "cloudmart-tfstate-team-axel-8"
    key            = "environments/staging/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}
