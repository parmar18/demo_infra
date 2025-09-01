# Instance Template (blueprint for VMs)
resource "google_compute_instance_template" "app_template" {
  name_prefix  = "search-app-template-"
  machine_type = "e2-micro"

  lifecycle {
    create_before_destroy = true
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {} # external IP so VM can pull image
  }

  service_account {
    email  = null # use default compute service account
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    echo "[startup] beginning setup" | tee /var/log/startup-script.log

    # Install prerequisites + Docker
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common docker.io

    systemctl enable docker
    systemctl start docker

    # Install Google Cloud SDK (for Artifact Registry auth)
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
      | tee /etc/apt/sources.list.d/google-cloud-sdk.list
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor > /usr/share/keyrings/cloud.google.gpg
    apt-get update -y
    apt-get install -y google-cloud-sdk

    # Configure Docker for Artifact Registry
    gcloud auth configure-docker us-central1-docker.pkg.dev --quiet || true

    # Pull with retries
    for i in {1..5}; do
      if docker pull ${var.docker_image}; then
        echo "[startup] docker image pulled successfully" | tee -a /var/log/startup-script.log
        break
      fi
      echo "[startup] retrying docker pull in 5s..." | tee -a /var/log/startup-script.log
      sleep 5
    done

    # Remove any old container
    docker rm -f search-app || true

    # Run container with name + logging
    docker run -d --restart=always --name search-app -p 8080:8080 ${var.docker_image} \
      >> /var/log/search-app.log 2>&1

    echo "[startup] container launched" | tee -a /var/log/startup-script.log
  EOT

  tags = ["search-app"]
}

# Zonal Managed Instance Group (MIG)
resource "google_compute_instance_group_manager" "app_group" {
  name               = "search-app-group"
  base_instance_name = "search-app"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.app_template.self_link
  }

  target_size = 1

  # Port mapping for LB
  named_port {
    name = "http"
    port = 8080
  }

  update_policy {
    type               = "PROACTIVE"
    minimal_action     = "REPLACE"
    max_surge_fixed    = 1
    max_unavailable_fixed = 0
  }
}

