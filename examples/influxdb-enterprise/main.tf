# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ENTERPRISE INFLUXDB CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  version = "~> 2.7.0"
  region  = var.region
  project = var.project
}

provider "google-beta" {
  version = "~> 2.7.0"
  region  = var.region
  project = var.project
}

terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE LOCALS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  data_cluster_name = "${var.cluster_name}-data"
  meta_cluster_name = "${var.cluster_name}-meta"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INFLUXDB DATA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_data" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.data_cluster_name
  name             = local.data_cluster_name
  machine_type     = var.machine_type
  image            = var.image
  startup_script   = data.template_file.startup_script_data.rendered
  size             = 2
  network          = "default"

  persistent_volumes = [
    {
      device_name = "influxdb"
      size        = 10
      // For the example, we want to delete the data volume on 'terraform destroy'
      auto_delete = true
    }
  ]

  // To make testing easier, we're assigning public IPs to the node
  assign_public_ip = true

  // Use the custom InfluxDB SA
  service_account_email = module.service_account.email
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE DATA STARTUP SCRIPT THAT WILL RUN ON EACH DATA NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_data" {
  template = file("${path.module}/startup-script-data.sh")

  vars = {
    meta_group_name  = local.meta_cluster_name
    region           = var.region
    license_key      = var.license_key
    shared_secret    = var.shared_secret
    disk_device_name = "influxdb"
    disk_mount_point = "/influxdb"
    disk_owner       = "influxdb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INFLUXDB DATA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_meta" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.meta_cluster_name
  name             = local.meta_cluster_name
  machine_type     = var.machine_type
  image            = var.image
  startup_script   = data.template_file.startup_script_meta.rendered
  size             = 3
  network          = "default"

  persistent_volumes = [
    {
      device_name = "influxdb"
      size        = 10
      // For the example, we want to delete the data volume on 'terraform destroy'
      auto_delete = true
    }
  ]

  // To make testing easier, we're assigning public IPs to the node
  assign_public_ip = true

  // Use the custom InfluxDB SA
  service_account_email = module.service_account.email
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE META STARTUP SCRIPT THAT WILL RUN ON EACH META NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_meta" {
  template = file("${path.module}/startup-script-meta.sh")

  vars = {
    meta_group_name  = local.meta_cluster_name
    region           = var.region
    license_key      = var.license_key
    shared_secret    = var.shared_secret
    disk_device_name = "influxdb"
    disk_mount_point = "/influxdb"
    disk_owner       = "influxdb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SERVICE ACCOUNT FOR THE CLUSTER AND ALLOW TRAFFIC WITHIN THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "service_account" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-service-account?ref=v0.0.1"
  source = "../../modules/tick-service-account"

  project      = var.project
  name         = "${var.cluster_name}-sa"
  display_name = "Service Account for InfluxDB OSS Cluster ${var.cluster_name}"
}

module "internal_firewall" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/service-account-firewall-rules?ref=v0.0.1"
  source = "../../modules/service-account-firewall-rules"

  project                 = var.project
  name_prefix             = var.cluster_name
  network                 = "default"
  source_service_accounts = [module.service_account.email]
  target_service_accounts = [module.service_account.email]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES FOR THE CLUSTER
# To make testing easier, we're allowing access from all IP addresses
# ---------------------------------------------------------------------------------------------------------------------

module "external_firewall" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/external-firewall?ref=v0.0.1"
  source = "../../modules/external-firewall"

  name_prefix = var.cluster_name
  network     = "default"
  project     = var.project
  target_tags = [module.influxdb_data.network_tag, module.influxdb_meta.network_tag]

  allow_access_from_cidr_blocks = ["0.0.0.0/0"]
}

