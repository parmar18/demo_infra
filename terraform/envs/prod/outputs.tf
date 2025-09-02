output "load_balancer_ip" {
  description = "Global IP address of the HTTP Load Balancer"
  value       = module.loadbalancer.lb_ip
}

output "subnet_id" {
  description = "Subnetwork ID used by the MIG"
  value       = module.vpc.subnet_id
}

output "instance_group" {
  description = "Managed Instance Group backing the app"
  value       = module.compute.instance_group
}
