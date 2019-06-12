# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR INFLUXDB
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "internal" {
  project = "${var.project}"
  name    = "${var.name_prefix}-influxdb-fw-int"

  network = "${var.network}"

  target_tags = ["${var.target_tags}"]
  source_tags = ["${var.target_tags}"]

  allow {
    protocol = "tcp"

    ports = [
      "${var.api_port}",
      "${var.raft_port}",
      "${var.rest_port}",
      "${var.tcp_port}",
    ]
  }
}

resource "google_compute_firewall" "external" {
  project = "${var.project}"
  name    = "${var.name_prefix}-influxdb-fw-ext"

  network = "${var.network}"

  target_tags = ["${var.target_tags}"]

  source_tags   = ["${var.allow_api_access_from_source_tags}"]
  source_ranges = ["${var.allow_api_access_from_cidr_blocks}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.api_port}"]
  }
}
