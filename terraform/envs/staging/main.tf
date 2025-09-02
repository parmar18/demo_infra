provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("~/.config/gcloud/staging-key.json")
}

module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.project_id
  region     = var.region
}

module "firewall" {
  source   = "../../modules/firewall"
  vpc_name = module.vpc.vpc_name
}

module "compute" {
  source       = "../../modules/compute"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  subnet_id    = module.vpc.subnet_id
  docker_image = var.docker_image
}

module "loadbalancer" {
  source         = "../../modules/loadbalancer"
  instance_group = module.compute.instance_group
}
