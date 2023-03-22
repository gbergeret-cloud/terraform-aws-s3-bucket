resource "random_id" "bucket_suffix" {
  byte_length = 8
}

module "aws_s3_bucket" {
  source = "../.."

  bucket = "simple-bucket-${random_id.bucket_suffix.hex}"

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "RandomNewPolicy"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:DeleteObject"]
    resources = ["${module.aws_s3_bucket.this.arn}/*"]
  }

  statement {
    sid = "DenyPutObjectWithoutEncryption" # Attempt to override module policy

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${module.aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [false] # <-- false should be discarded
    }
  }
}

output "bucket" {
  value = module.aws_s3_bucket.this.bucket
}
