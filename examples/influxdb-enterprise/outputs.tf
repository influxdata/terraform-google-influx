output "influxdb_data_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = module.influxdb_data.instance_group
}

output "influxdb_data_instance_group_manager" {
  description = "Name of the InfluxDB instance group"
  value       = module.influxdb_data.instance_group_manager
}

output "influxdb_meta_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = module.influxdb_meta.instance_group
}

output "influxdb_meta_instance_group_manager" {
  description = "Name of the InfluxDB instance group"
  value       = module.influxdb_meta.instance_group_manager
}

