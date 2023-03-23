resource "random_id" "bucket_suffix" {
  byte_length = 8
}

data "aws_vpc" "default" {
  default = true
}

module "aws_s3_bucket" {
  source = "../.."

  bucket = "simple-bucket-${random_id.bucket_suffix.hex}"

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "DenyObjectAccessFromOutsideVpcs"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Deny"
    actions = [
      "s3:*Object",
      "s3:*ObjectVersion"
    ]
    resources = ["${module.aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"
      values   = [data.aws_vpc.default.id]
    }
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
