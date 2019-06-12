# ---------------------------------------------------------------------------------------------------------------------
# CREATE A GCE MANAGED INSTANCE GROUP TO RUN THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_oss" {
  source = "../managed-instance-group"

  name                    = "${var.name}"
  size                    = 1
  project                 = "${var.project}"
  region                  = "${var.region}"
  image                   = "${var.image}"
  machine_type            = "${var.machine_type}"
  data_volume_device_name = "${var.data_volume_device_name}"
  data_volume_size        = "${var.data_volume_size}"
  network_tag             = "${local.network_tag}"
  startup_script          = "${var.startup_script}"

  assign_public_ip        = "${var.assign_public_ip}"
  custom_labels           = "${var.custom_labels}"
  image_project           = "${var.image_project}"
  network                 = "${var.network}"
  network_project         = "${var.network_project}"
  subnetwork              = "${var.subnetwork}"
  custom_tags             = "${var.custom_tags}"
  root_volume_size        = "${var.root_volume_size}"
  data_volume_auto_delete = "${var.data_volume_auto_delete}"
  service_account_email   = "${var.service_account_email}"
  service_account_scopes  = "${var.service_account_scopes}"
  target_pools            = "${var.instance_group_target_pools}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "internal" {
  name        = "${var.name}-influxdb-internal"
  description = "Internal firewall for InfluxDB ${var.name}"

  network = "${var.network}"

  target_tags = ["${local.network_tag}"]
  source_tags = ["${local.network_tag}"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "external" {
  name        = "${var.name}-influxdb-external"
  description = "External firewall for InfluxDB Cluster ${var.name}"

  network = "${var.network}"

  target_tags = ["${local.network_tag}"]

  source_tags   = ["${var.allow_access_from_source_tags}"]
  source_ranges = ["${var.allow_access_from_cidr_blocks}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.allow_access_to_ports}"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE LOCALS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  network_tag = "${var.network_tag != "" ? var.network_tag : var.name}"
}
