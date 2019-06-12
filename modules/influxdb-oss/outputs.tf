output "instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = "${module.influxdb_oss.instance_group}"
}

output "instance_group_manager" {
  description = "Self link to the InfluxDB instance group manager"
  value       = "${module.influxdb_oss.instance_group_manager}"
}

output "network_tag" {
  description = "Network tag assigned to the instances"
  value       = "${local.network_tag}"
}
