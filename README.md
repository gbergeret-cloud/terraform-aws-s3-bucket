# terraform-aws-s3-bucket

This module creates an S3 bucket with versioning, lifecycles, encryption and a
default policy.

## Basic
* Keep old versions for 30 days (`id: ExpireNonCurrentVersion`)
* Encrypt object using AES:256
* Prevent deleting object versions (`Sid: DenyDeleteObjectVersion`)

## Usage

**IMPORTANT**: We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest
released versions. We highly recommend that in your code you pin the version to
the exact version you are using so that your infrastructure remains stable, and
update versions in a systematic way so that they do not catch you by surprise.

```hcl
module "aws_s3_bucket" {
  source = "git@github.com:gbergeret/terraform-aws-s3-bucket"

  bucket = "assets"

  tags = {
    Environment = "Test"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|--------|
| bucket | Name of the bucket. | `string` |  | yes |
| policy | Policy to apply on the bucket. | `string` | `{}`  | no |
| lifecycle_configuration_rules | A list of lifecycle rules. | `list(object)` | `[]` | no |
| tags | Map of tags to assign to the bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| this | Bucket object. Used to access all bucket properties (e.g. `arn`) | `object` |
