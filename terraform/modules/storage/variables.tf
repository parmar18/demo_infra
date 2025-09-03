variable "bucket_name" { type = string }
variable "project_id"  { type = string }
variable "location"    { type = string }
variable "enable_versioning" {
  type    = bool
  default = true
}
variable "delete_after_days" {
  type    = number
  default = 30
}
