variable "instance_name" { type = string }
variable "project_id"    { type = string }
variable "region"        { type = string }
variable "db_version" {
  type    = string
  default = "POSTGRES_14"
}
variable "tier" {
  type    = string
  default = "db-f1-micro"
}
