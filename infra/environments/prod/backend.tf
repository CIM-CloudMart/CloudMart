// Remote state backend for prod environment
terraform {
  backend "s3" {
    bucket         = "${var.project}-tfstate-${var.team}"
    key            = "environments/prod/terraform.tfstate"
    region         = var.region
    dynamodb_table = "${var.project}-tfstate-lock"
    encrypt        = true
  }
}
