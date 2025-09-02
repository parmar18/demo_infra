resource "google_compute_firewall" "allow-http-https" {
  name    = "allow-http-https"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-lb-health-check" {
  name    = "allow-lb-health-check"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["search-app"]
}
