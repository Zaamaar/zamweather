# S3 bucket to host the frontend static files
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${random_id.bucket_suffix.hex}"

  tags = { Name = "${var.project_name}-frontend" }
}

# Random suffix to ensure bucket name is globally unique
# S3 bucket names must be unique across ALL AWS accounts worldwide
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Block all public access to the bucket
# CloudFront will access it privately via OAC
# Nobody can access S3 directly - must go through CloudFront
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload index.html to the bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.root}/frontend/index.html"
  content_type = "text/html"

  # Reupload if the file content changes
  etag = filemd5("${path.root}/frontend/index.html")
}
