resource "aws_s3_bucket" "this" {

  bucket = var.bucket

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy" {
  source_policy_documents = [var.policy]

  statement {
    sid    = "DenyDeleteObjectVersion"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:DeleteObjectVersion"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    sid = "DenyPutObjectWithoutEncryption"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = local.lifecycle_configuration_rules

    content {
      id     = rule.value.id
      status = "Enabled"

      expiration {
        expired_object_delete_marker = try(rule.value.expiration.expired_object_delete_marker, null)
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = try(rule.value.abort_incomplete_multipart_upload.days_after_initiation, null)
      }

      noncurrent_version_expiration {
        noncurrent_days = try(rule.value.noncurrent_version_expiration.noncurrent_days, null)
      }
    }
  }
}
