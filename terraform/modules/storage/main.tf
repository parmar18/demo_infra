resource "google_storage_bucket" "this" {
  name     = var.bucket_name
  project  = var.project_id
  location = var.location

  uniform_bucket_level_access = true

  versioning {
    enabled = var.enable_versioning
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.delete_after_days
    }
  }
}
