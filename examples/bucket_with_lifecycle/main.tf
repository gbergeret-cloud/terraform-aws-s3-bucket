resource "random_id" "bucket_suffix" {
  byte_length = 8
}

module "aws_s3_bucket" {
  source = "../.."

  bucket = "simple-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = module.aws_s3_bucket.this.bucket

  rule {
    id     = "tf-delete-old-versions-after-30-days"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}


output "bucket" {
  value = module.aws_s3_bucket.this.bucket
}
