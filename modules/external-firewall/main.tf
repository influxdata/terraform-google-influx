# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR EXTERNAL TRAFFIC
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "external" {
  project = "${var.project}"
  name    = "${var.name_prefix}-fw-ext"

  network = "${var.network}"

  target_tags = ["${var.target_tags}"]

  source_ranges = ["${var.allow_access_from_cidr_blocks}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.ports}"]
  }
}
