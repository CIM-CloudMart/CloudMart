resource "aws_s3_bucket" "error_page" {
  bucket = "${var.project}-${var.environment}-error-page"
  website {
    index_document = "error.html"
  }
  tags = {
    Name        = "${var.project}-error-page"
    Environment = var.environment
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
}

resource "aws_s3_bucket_object" "error_page_html" {
  bucket       = aws_s3_bucket.error_page.id
  key          = "error.html"
  source       = "${path.module}/static/error.html"
  content_type = "text/html"
}
