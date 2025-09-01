output "vpc_name" {
  value = module.vpc.vpc_name
}

output "subnet_id" {
  value = module.vpc.subnet_id
}
output "lb_ip" {
  value       = module.loadbalancer.lb_ip
  description = "Global IP of the HTTP load balancer"
}