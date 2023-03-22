locals {
  lifecycle_configuration_rules = merge(
    { for i in [{
      id     = "ExpireNonCurrentVersion"
      status = "Enabled"

      expiration = {
        expired_object_delete_marker = true
      }

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }] : i.id => i },
    { for i in var.lifecycle_configuration_rules : i.id => i }
  )
}

variable "bucket" {
  type        = string
  description = "Name of the bucket."
}

variable "policy" {
  type        = string
  description = "Policy to apply on the bucket."
  default     = "{}"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload = object({
      days_after_initiation = number
    })

    expiration = any

    noncurrent_version_expiration = any
  }))
  description = "A list of lifecycle rules."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the bucket."
  default     = {}
}
