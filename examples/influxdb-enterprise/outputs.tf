output "influxdb_data_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = "${module.influxdb_data.instance_group}"
}

output "influxdb_data_instance_group_manager" {
  description = "Name of the InfluxDB instance group"
  value       = "${module.influxdb_data.instance_group_manager}"
}

output "influxdb_meta_instance_group" {
  description = "Self link to the InfluxDB instance group"
  value       = "${module.influxdb_meta.instance_group}"
}

output "influxdb_meta_instance_group_manager" {
  description = "Name of the InfluxDB instance group"
  value       = "${module.influxdb_meta.instance_group_manager}"
}

output "load_balancer_ip_address" {
  description = "Self link to the InfluxDB instance group"
  value       = "${module.load_balancer.load_balancer_ip_address}"
}

output "load_balancer_domain_name" {
  description = "Name of the InfluxDB instance group"
  value       = "${module.load_balancer.load_balancer_domain_name}"
}
