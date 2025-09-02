variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region to deploy resources in"
}

variable "zone" {
  type        = string
  description = "Zone to deploy the MIG"
}

variable "docker_image" {
  type        = string
  description = "Docker image to deploy from Artifact Registry"
}