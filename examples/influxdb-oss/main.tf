# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN OSS INFLUXDB CLUSTER
# As it is the OSS version, it will be a single-node cluster
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  version = "~> 2.7.0"
  region  = "${var.region}"
  project = "${var.project}"
}

provider "google-beta" {
  version = "~> 2.7.0"
  region  = "${var.region}"
  project = "${var.project}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INFLUXDB OSS CLUSTER
# As we're running the OSS version, this is a single-node cluster
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_oss" {
  source = "../../modules/influxdb-cluster"

  project = "${var.project}"
  region  = "${var.region}"

  data_volume_size = 50
  cluster_tag_name = "${var.cluster_name}"
  cluster_name     = "${var.cluster_name}"
  machine_type     = "${var.machine_type}"
  image            = "${var.image}"
  startup_script   = "${data.template_file.startup_script.rendered}"
  cluster_size     = "1"
  network          = "${module.vpc_network.network}"
  subnetwork       = "${module.vpc_network.public_subnetwork}"

  // For the example, we want to delete the data volume on 'terraform destroy'
  data_volume_auto_delete = "true"

  // For the sake of testing we're assigning public IPs to the node
  allow_public_access = "true"

  // Use the custom InfluxDB SA
  service_account_email = "${module.service_account.email}"

  // We're tagging the instances with the 'public' tag. See the Access Tier documentation for details:
  // https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  // NOTE: This is *NOT* recommended for production, as it makes the InfluxDB instances accessible from
  // the public internet. For a production setup, we recommend using ´private_persistence´ or ´private´ network tag.
  custom_tags = ["${module.vpc_network.public}"]
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
# NOTE: The internal load balancer is not accessible from the public internet
# ---------------------------------------------------------------------------------------------------------------------

module "load_balancer" {
  source = "git::https://github.com/gruntwork-io/terraform-google-load-balancer.git//modules/internal-load-balancer?ref=v0.1.2"

  project = "${var.project}"

  backends = [
    {
      description = "Backend for InfluxDB OSS CLuster ${var.cluster_name}"
      group       = "${module.influxdb_oss.instance_group}"
    },
  ]

  name = "${var.cluster_name}-lb"

  # List of ports the load balancer will load balance
  ports             = ["8086"]
  region            = "${var.region}"
  health_check_port = "8086"

  network    = "${module.vpc_network.network}"
  subnetwork = "${module.vpc_network.public_subnetwork}"

  session_affinity = "NONE"
  service_label    = "ilb"

  target_tags = ["${var.cluster_name}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE STARTUP SCRIPT THAT WILL RUN ON EACH NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script" {
  template = "${file("${path.module}/startup-script.sh")}"

  vars {
    disk_mount_point = "/influxdb"
    disk_owner       = "influxdb"
  }
}
