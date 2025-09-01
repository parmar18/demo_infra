output "instance_group" {
  description = "Self link of the managed instance group for LB backend"
  value       = google_compute_instance_group_manager.app_group.instance_group
}
