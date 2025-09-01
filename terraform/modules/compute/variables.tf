variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (for surrounding modules; not used by instance_template)"
  type        = string
}

variable "zone" {
  description = "GCP zone where MIG will run"
  type        = string
}

variable "subnet_id" {
  description = "Subnetwork self_link where instances will attach"
  type        = string
}

variable "docker_image" {
  description = "Artifact Registry image to run (e.g. us-central1-docker.pkg.dev/PROJECT/repo/app:tag)"
  type        = string
}
