# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR SERVICE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "internal" {
  project = "${var.project}"
  name    = "${var.name_prefix}-fw-int"

  network = "${var.network}"

  target_service_accounts = ["${var.target_service_accounts}"]
  source_service_accounts = ["${var.source_service_accounts}"]

  allow {
    protocol = "${var.protocol}"

    ports = [
      "${var.ports}",
    ]
  }
}
