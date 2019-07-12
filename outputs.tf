output "tick_oss_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = module.tick_oss.instance_group
}

output "tick_oss_instance_group_manager" {
  description = "Self link of the InfluxDB instance group manager"
  value       = module.tick_oss.instance_group_manager
}

