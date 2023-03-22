variable "bucket" {
  type        = string
  description = "Name of the bucket."
}

variable "policy" {
  type        = string
  description = "Policy to apply on the bucket."
  default     = "{}"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the bucket."
  default     = {}
}
