# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LOAD BALANCER FORWARDING RULE
# In GCP, Google has already created the load balancer itself so there is no new load balancer resource to create. However,
# to leverage this load balancer, we must create a Forwarding Rule specially for our Compute Instances. By creating a
# Forwarding Rule, we automatically create an external (public-facing) Load Balancer in GCP.
# ---------------------------------------------------------------------------------------------------------------------

# A Forwarding Rule receives inbound requests and forwards them to the specified Target Pool
resource "google_compute_forwarding_rule" "influxdb" {
  name                  = "${var.cluster_name}-fr"
  description           = "Forwarding rule for ${var.cluster_name}"
  ip_address            = "${var.ip_address}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "${var.load_balancing_scheme}"
  network               = "${var.network}"
  subnetwork            = "${var.subnetwork}"
  port_range            = "8086"

  backend_service = "${var.load_balancing_scheme == "INTERNAL" ? join("", google_compute_region_backend_service.influxdb.*.self_link) : ""}"
  target          = ""
}

# The Load Balancer (Forwarding rule) will only forward requests to Compute Instances in the associated Target Pool.
# Note that this Target Pool is populated by modifying the Instance Group containing the Vault nodes to add its member
# Instances to this Target Pool.
resource "google_compute_target_pool" "vault" {
  name             = "${var.cluster_name}-tp"
  description      = "Desc"
  session_affinity = "NONE"
  health_checks    = ["${google_compute_health_check.influxdb.name}"]
}

# Add a Health Check so that the Load Balancer will only route to healthy Compute Instances. Note that this Health
# Check has no effect on whether GCE will attempt to reboot the Compute Instance.
resource "google_compute_health_check" "influxdb" {
  name                = "${var.cluster_name}-hc"
  description         = "Health check for ${var.cluster_name}"
  check_interval_sec  = "${var.health_check_interval_sec}"
  timeout_sec         = "${var.health_check_timeout_sec}"
  healthy_threshold   = "${var.health_check_healthy_threshold}"
  unhealthy_threshold = "${var.health_check_unhealthy_threshold}"

  tcp_health_check {
    port = "8086"
  }
}

# The Regional Backend Service pointing to the instance group.
resource "google_compute_region_backend_service" "influxdb" {
  count       = "${var.load_balancing_scheme == "INTERNAL"}"
  name        = "${var.cluster_name}-be"
  description = "Regional backend service for ${var.cluster_name} cluster."

  region           = "${var.region}"
  protocol         = "TCP"
  session_affinity = "NONE"

  backend {
    group = "${var.instance_group}"
  }

  health_checks = ["${google_compute_health_check.influxdb.self_link}"]
}

# Firewall for the nodes in the cluster.
resource "google_compute_firewall" "default" {
  name        = "${var.cluster_name}-fw"
  description = "Firewall for the ${var.cluster_name} nodes."
  network     = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["${var.firewall_allowed_ports}"]
  }

  target_tags = ["${var.firewall_target_tags}"]
}
