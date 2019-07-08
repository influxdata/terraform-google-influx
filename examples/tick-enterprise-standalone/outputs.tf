output "influxdb_data_instance_group" {
  description = "Self link to the InfluxDB Data instance group"
  value       = module.influxdb_data.instance_group
}

output "influxdb_data_instance_group_manager" {
  description = "Self link to the InfluxDB Data instance group manager"
  value       = module.influxdb_data.instance_group_manager
}

output "telegraf_instance_group" {
  description = "Self link to the Telegraf instance group"
  value       = module.telegraf.instance_group
}

output "telegraf_instance_group_manager" {
  description = "Self link to the Telegraf instance group manager"
  value       = module.telegraf.instance_group_manager
}

output "kapacitor_instance_group" {
  description = "Self link to the Kapacitor instance group"
  value       = module.kapacitor.instance_group
}

output "kapacitor_instance_group_manager" {
  description = "Self link to the Kapacitor instance group manager"
  value       = module.kapacitor.instance_group_manager
}

output "chronograf_instance_group" {
  description = "Self link to the Chronograf instance group"
  value       = module.chronograf.instance_group
}

output "chronograf_instance_group_manager" {
  description = "Self link to the Chronograf instance group manager"
  value       = module.chronograf.instance_group_manager
}

output "data_lb_domain_name" {
  description = "Internal DNS name for the InfluxDB Data Load Balancer"
  value       = module.influxdb_data_lb.load_balancer_domain_name
}

output "meta_lb_domain_name" {
  description = "Internal DNS name for the InfluxDB Meta Load Balancer"
  value       = module.influxdb_meta_lb.load_balancer_domain_name
}

output "kapacitor_lb_domain_name" {
  description = "Internal DNS name for the Kapacitor Load Balancer"
  value       = module.kapacitor_lb.load_balancer_domain_name
}
