# ==================== S3 Module ====================

resource "aws_s3_bucket" "storage" {
  bucket        = "${var.project}-storage-${var.team}-${var.environment}"
  force_destroy = var.environment != "prod"

  tags = {
    Name = "${var.project}-storage-${var.team}-${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==================== S3 Failover Website ====================
resource "aws_s3_bucket" "failover_website" {
  bucket        = "failover-${var.project}-${var.environment}-${var.team}"
  force_destroy = true

  tags = {
    Name = "failover-${var.project}-${var.environment}-${var.team}"
  }
}

resource "aws_s3_bucket_public_access_block" "failover_website" {
  bucket = aws_s3_bucket.failover_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "failover_website" {
  bucket = aws_s3_bucket.failover_website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "failover_website" {
  bucket = aws_s3_bucket.failover_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.failover_website.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.failover_website]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.failover_website.id
  key          = "index.html"
  content      = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>CloudMart - Service Temporarily Unavailable</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 100px; background-color: #f7f9fa; color: #333; }
        h1 { font-size: 50px; color: #ff9900; }
        p { font-size: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="container">
        <h1>Maintenance Mode</h1>
        <p>We are currently experiencing a service disruption. Our engineering team has been alerted and is actively working on it.</p>
        <p>Please check back shortly.</p>
    </div>
</body>
</html>
EOF
  content_type = "text/html"
}
