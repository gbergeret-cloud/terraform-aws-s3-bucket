resource "random_id" "bucket_suffix" {
  byte_length = 8
}

module "aws_s3_bucket" {
  source = "../.."

  bucket = "simple-bucket-${random_id.bucket_suffix.hex}"

  lifecycle_configuration_rules = [{
    # Override module lifecycle
    id      = "ExpireNonCurrentVersion"
    enabled = true

    expiration = {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload = {
      days_after_initiation = 7
    }

    noncurrent_version_expiration = {
      noncurrent_days = 7
    }
    }, {
    # Add a custom lifecycle
    id      = "ExpireCurrentVersion"
    enabled = true

    expiration = {
      days = 30
    }

    abort_incomplete_multipart_upload = {}
    noncurrent_version_expiration     = {}
  }]
}


output "bucket" {
  value = module.aws_s3_bucket.this.bucket
}
