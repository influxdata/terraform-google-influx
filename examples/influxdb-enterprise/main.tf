# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ENTERPRISE INFLUXDB CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  region  = "${var.region}"
  project = "${var.project}"
}

provider "google-beta" {
  region  = "${var.region}"
  project = "${var.project}"
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
  source = "../../modules/influxdb-cluster"

  project = "${var.project}"
  region  = "${var.region}"

  data_volume_size = 50
  cluster_tag_name = "${local.data_cluster_name}"
  cluster_name     = "${local.data_cluster_name}"
  machine_type     = "${var.machine_type}"
  image            = "${var.image}"
  startup_script   = "${data.template_file.startup_script_data.rendered}"
  cluster_size     = "2"
  network          = "${module.vpc_network.network}"
  subnetwork       = "${module.vpc_network.public_subnetwork}"

  // To make testing easier, we're assigning public IPs to the node
  allow_public_access = "true"

  // Use the custom InfluxDB SA
  service_account_email = "${module.service_account.email}"

  // We're tagging the instances with the 'public' tag. See the Access Tier documentation for details:
  // https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  // NOTE: This is *NOT* recommended for production, as it makes the InfluxDB instances accessible from
  // the public internet. For production setup, we recommend using ´private_persistence´ or ´private´ network tag.
  custom_tags = ["${module.vpc_network.public}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE DATA STARTUP SCRIPT THAT WILL RUN ON EACH DATA NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_data" {
  template = "${file("${path.module}/startup-script-data.sh")}"

  vars {
    meta_group_name  = "${local.meta_cluster_name}"
    region           = "${var.region}"
    license_key      = "${var.license_key}"
    shared_secret    = "${var.shared_secret}"
    disk_mount_point = "/influxdb"
    disk_owner       = "influxdb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INFLUXDB DATA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_meta" {
  source = "../../modules/influxdb-cluster"

  project = "${var.project}"
  region  = "${var.region}"

  data_volume_size = 50
  cluster_tag_name = "${local.meta_cluster_name}"
  cluster_name     = "${local.meta_cluster_name}"
  machine_type     = "${var.machine_type}"
  image            = "${var.image}"
  startup_script   = "${data.template_file.startup_script_meta.rendered}"
  cluster_size     = "3"
  network          = "${module.vpc_network.network}"
  subnetwork       = "${module.vpc_network.public_subnetwork}"

  // To make testing easier, we're assigning public IPs to the node
  allow_public_access = "true"

  // Use the custom InfluxDB SA
  service_account_email = "${module.service_account.email}"

  // We're tagging the instances with the 'public' tag. See the Access Tier documentation for details:
  // https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  // NOTE: This is *NOT* recommended for production, as it makes the InfluxDB instances accessible from
  // the public internet. For production setup, we recommend using ´private_persistence´ or ´private´ network tag.
  // We're placing the meta nodes in the same network as the data nodes to ensure connectivity across nodes.
  custom_tags = ["${module.vpc_network.public}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE META STARTUP SCRIPT THAT WILL RUN ON EACH META NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_meta" {
  template = "${file("${path.module}/startup-script-meta.sh")}"

  vars {
    meta_group_name  = "${local.meta_cluster_name}"
    region           = "${var.region}"
    license_key      = "${var.license_key}"
    shared_secret    = "${var.shared_secret}"
    disk_mount_point = "/influxdb"
    disk_owner       = "influxdb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SERVICE ACCOUNT FOR THE CLUSTER INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

module "service_account" {
  source = "../../modules/influxdb-service-account"

  project      = "${var.project}"
  name         = "${var.cluster_name}-sa"
  display_name = "Service Account for InfluxDB OSS Cluster ${var.cluster_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NETWORK TO DEPLOY THE CLUSTER TO
# ---------------------------------------------------------------------------------------------------------------------

module "vpc_network" {
  source = "git::https://github.com/gruntwork-io/terraform-google-network.git//modules/vpc-network?ref=v0.1.1"

  name_prefix = "${var.cluster_name}"
  project     = "${var.project}"
  region      = "${var.region}"

  cidr_block           = "${var.vpc_cidr_block}"
  secondary_cidr_block = "${var.vpc_secondary_cidr_block}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE INTERNAL LOAD BALANCER
#
# NOTE: The internal load balancer is not accessible from the internet
# ---------------------------------------------------------------------------------------------------------------------

module "load_balancer" {
  source = "git::https://github.com/gruntwork-io/terraform-google-load-balancer.git//modules/internal-load-balancer?ref=internal_lb"

  project = "${var.project}"

  backends = [
    {
      description = "Backend for InfluxDB Data CLuster ${local.data_cluster_name}"
      group       = "${module.influxdb_data.instance_group}"
    },
  ]

  name = "${local.data_cluster_name}-lb"

  # List of ports the load balancer will load balance
  ports             = ["8086"]
  region            = "${var.region}"
  health_check_port = "8086"

  network    = "${module.vpc_network.network}"
  subnetwork = "${module.vpc_network.public_subnetwork}"

  session_affinity = "NONE"
  service_label    = "data"

  target_tags = ["${local.data_cluster_name}"]
}
