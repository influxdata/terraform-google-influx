terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A GCE MANAGED INSTANCE GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_region_instance_group_manager" "default" {
  name = var.name

  base_instance_name = "${var.name}-instance"
  instance_template  = google_compute_instance_template.default.self_link
  region             = var.region
  target_size        = var.size
  target_pools       = var.target_pools
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE INSTANCE TEMPLATE FOR THE CLUSTER INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_instance_template" "default" {
  name_prefix = "${var.name}-it"
  description = "This template is used to create server instances for ${var.name}."

  // Add the shared tag name, and append any additional tags
  tags = concat([var.network_tag], var.custom_tags)

  labels = var.custom_labels

  instance_description = "${var.name} instance"
  machine_type         = var.machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata_startup_script = var.startup_script

  // Create a new boot disk from a pre-created image
  disk {
    source_image = data.google_compute_image.default.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.root_volume_size
    disk_type    = "pd-ssd"
  }

  // Add persistent volumes
  dynamic "disk" {
    for_each = var.persistent_volumes
    iterator = volume
    content {
      device_name  = volume.value.device_name
      auto_delete  = volume.value.auto_delete
      disk_size_gb = volume.value.size
      boot         = false
      disk_type    = "pd-ssd"
      mode         = "READ_WRITE"
    }
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.network_project != "" ? var.network_project : var.project

    // Create access config dynamically - if public ip requested, we just need the empty ´access_config´ block
    dynamic "access_config" {
      for_each = var.assign_public_ip ? ["public_ip"] : []
      content {
      }
    }
  }

  service_account {
    email = var.service_account_email != "" ? var.service_account_email : "default"

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

# ---------------------------------------------------------------------------------------------------------------------
# GET THE PRE-BUILT MACHINE IMAGE
# ---------------------------------------------------------------------------------------------------------------------

data "google_compute_image" "default" {
  name    = var.image
  project = var.image_project != "" ? var.image_project : var.project
}

