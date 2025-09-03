resource "google_secret_manager_secret" "this" {
  secret_id  = var.secret_id
  project    = var.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "version" {
  secret      = google_secret_manager_secret.this.id
  secret_data = var.secret_value
}
