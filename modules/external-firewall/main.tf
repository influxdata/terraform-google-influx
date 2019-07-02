terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR EXTERNAL TRAFFIC
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "external" {
  project = var.project
  name    = "${var.name_prefix}-fw-ext"

  network = var.network

  target_tags = var.target_tags

  source_ranges = var.allow_access_from_cidr_blocks

  allow {
    protocol = var.protocol
    ports    = var.ports
  }
}

