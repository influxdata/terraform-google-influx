output "load_balancer_ip" {
  description = "IP Address for the load balancer."
  value       = "${google_compute_forwarding_rule.influxdb.ip_address}"
}

output "forwarding_rule_id" {
  description = "ID of the InfluxDB forwarding rule"
  value       = "${google_compute_forwarding_rule.influxdb.id}"
}

output "forwarding_rule" {
  description = "Self link to InfluxDB forwarding rule"
  value       = "${google_compute_forwarding_rule.influxdb.self_link}"
}

output "health_check_id" {
  description = "ID of the InfluxDB health check"
  value       = "${google_compute_health_check.influxdb.id}"
}

output "health_check" {
  description = "Self link to InfluxDB health check"
  value       = "${google_compute_health_check.influxdb.self_link}"
}

output "firewall_rule_id" {
  description = "ID of the InfluxDB firewall rule."
  value       = "${google_compute_firewall.default.id}"
}

output "firewall_rule" {
  description = "Self link of the InfluxDB firewall"
  value       = "${google_compute_firewall.default.self_link}"
}
