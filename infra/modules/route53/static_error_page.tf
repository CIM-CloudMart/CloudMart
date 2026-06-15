data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "error_page" {
  bucket = "${var.project}-${var.environment}-error-page-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  tags = {
    Name        = "${var.project}-error-page"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "error_page" {
  bucket = aws_s3_bucket.error_page.id
  index_document {
    suffix = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "error_page" {
  bucket = aws_s3_bucket.error_page.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
resource "aws_s3_bucket_public_access_block" "error_page" {
  bucket = aws_s3_bucket.error_page.id
  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "error_page_public" {
  bucket = aws_s3_bucket.error_page.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = ["${aws_s3_bucket.error_page.arn}/*"]
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.error_page]
}

resource "aws_s3_object" "error_page_html" {
  bucket       = aws_s3_bucket.error_page.id
  key          = "error.html"
  source       = "${path.module}/static/error.html"
  content_type = "text/html"
}
