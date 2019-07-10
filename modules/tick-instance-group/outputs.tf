output "instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = google_compute_region_instance_group_manager.default.instance_group
}

output "instance_group_manager" {
  description = "Self link to the InfluxDB instance group manager"
  value       = google_compute_region_instance_group_manager.default.self_link
}

output "network_tag" {
  description = "Tag name the compute instances are tagged with"
  value       = var.network_tag
}

