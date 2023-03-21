resource "random_id" "bucket_suffix" {
  byte_length = 8
}

module "aws_s3_bucket" {
  source = "../.."

  bucket = "simple-bucket-${random_id.bucket_suffix.hex}"
}

output "bucket" {
  value = module.aws_s3_bucket.this.bucket
}
