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

module "tick_oss" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = "${var.project}"
  region  = "${var.region}"

  size = 1

  data_volume_size        = 10
  root_volume_size        = 20
  data_volume_device_name = "influxdb"
  network_tag             = "${var.name}"
  name                    = "${var.name}"
  machine_type            = "${var.machine_type}"
  image                   = "${var.image}"
  startup_script          = "${data.template_file.startup_script.rendered}"

  network = "default"

  // For the example, we want to delete the data volume on 'terraform destroy'
  data_volume_auto_delete = "true"

  // To make testing easier, we're assigning public IPs to the node
  assign_public_ip = "true"

  // Use the custom InfluxDB SA
  service_account_email = "${module.service_account.email}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SERVICE ACCOUNT FOR THE CLUSTER INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

module "service_account" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-service-account?ref=v0.0.1"
  source = "../../modules/tick-service-account"

  project      = "${var.project}"
  name         = "${var.name}-sa"
  display_name = "Service Account for TICK OSS Cluster ${var.name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EXTERNAL FIREWALL RULES FOR THE CLUSTER
# To make testing easier, we're allowing access from all IP addresses
# ---------------------------------------------------------------------------------------------------------------------

module "external_firewall" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/external-firewall?ref=v0.0.1"
  source = "../../modules/external-firewall"

  name_prefix = "${var.name}"
  network     = "default"
  project     = "${var.project}"
  target_tags = ["${var.name}"]

  allow_access_from_cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE STARTUP SCRIPT THAT WILL RUN ON EACH NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script" {
  template = "${file("${path.module}/startup-script.sh")}"

  vars {
    disk_device_name   = "influxdb"
    disk_mount_point   = "/influxdb"
    disk_owner         = "influxdb"
    influxdb_url       = "http://localhost:8086"
    telegraf_database  = "telegraf"
    chronograf_host    = "0.0.0.0"
    chronograf_port    = "8888"
    kapacitor_hostname = "localhost"
  }
}
