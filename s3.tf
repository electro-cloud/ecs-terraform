resource "aws_s3_bucket" "nginx_logs_bucket" {
  bucket = "nginx-logs-bucket-${random_string.bucket_suffix.result}"  # Ensure unique bucket name

  tags = {
    Name = "nginx-logs-bucket"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}