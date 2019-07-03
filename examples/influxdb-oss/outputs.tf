output "influxdb_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = module.influxdb_oss.instance_group
}

output "influxdb_instance_group_manager" {
  description = "Self link of the InfluxDB instance group"
  value       = module.influxdb_oss.instance_group_manager
}

