# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULE FOR KAPACITOR
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "external" {
  project = "${var.project}"
  name    = "${var.name_prefix}-kapacitor-fw"

  network = "${var.network}"

  target_tags = ["${var.target_tags}"]

  source_tags   = ["${var.allow_http_access_from_source_tags}"]
  source_ranges = ["${var.allow_http_access_from_cidr_blocks}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.http_port}"]
  }
}
