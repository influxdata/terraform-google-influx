terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR SERVICE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "internal" {
  project = var.project
  name    = "${var.name_prefix}-fw-int"

  network = var.network

  target_service_accounts = var.target_service_accounts
  source_service_accounts = var.source_service_accounts

  allow {
    protocol = var.protocol

    ports = var.ports
  }
}

