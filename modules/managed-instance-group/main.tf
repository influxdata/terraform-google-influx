# ---------------------------------------------------------------------------------------------------------------------
# CREATE A GCE MANAGED INSTANCE GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_region_instance_group_manager" "default" {
  name = "${var.name}"

  base_instance_name = "${var.name}-instance"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  region             = "${var.region}"
  target_size        = "${var.size}"
  target_pools       = ["${var.target_pools}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE INSTANCE TEMPLATE FOR THE CLUSTER INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_instance_template" "default" {
  name_prefix = "${var.name}-it"
  description = "This template is used to create server instances for ${var.name}."

  // Add the shared tag name, and append any additional tags
  tags = ["${concat(list(var.network_tag), var.custom_tags)}"]

  labels = "${var.custom_labels}"

  instance_description = "${var.name} instance"
  machine_type         = "${var.machine_type}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata_startup_script = "${var.startup_script}"

  // Create a new boot disk from a pre-created image
  disk {
    source_image = "${data.google_compute_image.default.self_link}"
    auto_delete  = true
    boot         = true
    disk_size_gb = "${var.root_volume_size}"
    disk_type    = "pd-ssd"
  }

  // Use an persistent disk resource
  disk {
    device_name  = "${var.data_volume_device_name}"
    auto_delete  = "${var.data_volume_auto_delete}"
    boot         = false
    disk_size_gb = "${var.data_volume_size}"
    disk_type    = "pd-ssd"
    mode         = "READ_WRITE"
  }

  network_interface = ["${local.network_interface}"]

  service_account {
    email = "${var.service_account_email != "" ? var.service_account_email : "default"}"

    // NOTE: Access scopes are the legacy method of specifying permissions for your instance.
    // https://cloud.google.com/compute/docs/access/service-accounts#accesscopesiam
    // We're granting the instance the https://www.googleapis.com/auth/cloud-platform scope to allow full access to all
    // Google Cloud APIs, so that the IAM permissions of the instance are completely determined by the IAM roles
    // of the service account.
    // https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#best_practices
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# PREPARE LOCALS
#
# NOTE: Due to limitations in terraform and heavy use of nested sub-blocks in the resource,
# we have to construct some of the configuration values dynamically.
# ------------------------------------------------------------------------------

locals {
  # Terraform does not allow using lists of maps with conditionals, so we have to
  # trick terraform by creating a string conditional first.
  # See https://github.com/hashicorp/terraform/issues/12453
  network_interface_key = "${var.assign_public_ip == "true" ? "PUBLIC" : "PRIVATE"}"

  network_interface_def = {
    "PRIVATE" = [{
      network            = "${var.network}"
      subnetwork         = "${var.subnetwork}"
      subnetwork_project = "${var.network_project != "" ? var.network_project : var.project}"
    }]

    "PUBLIC" = [{
      network            = "${var.network}"
      subnetwork         = "${var.subnetwork}"
      subnetwork_project = "${var.network_project != "" ? var.network_project : var.project}"
      access_config      = [{}]
    }]
  }

  network_interface = "${local.network_interface_def[local.network_interface_key]}"
}

# ---------------------------------------------------------------------------------------------------------------------
# GET THE PRE-BUILT MACHINE IMAGE
# ---------------------------------------------------------------------------------------------------------------------

data "google_compute_image" "default" {
  name    = "${var.image}"
  project = "${var.image_project != "" ? var.image_project : var.project}"
}
