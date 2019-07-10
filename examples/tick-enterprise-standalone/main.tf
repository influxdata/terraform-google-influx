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
  data_cluster_name      = "${var.name_prefix}-data"
  meta_cluster_name      = "${var.name_prefix}-meta"
  kapacitor_server_name  = "${var.name_prefix}-kapacitor"
  chronograf_server_name = "${var.name_prefix}-chronograf"
  telegraf_server_name   = "${var.name_prefix}-telegraf"

  data_cluster_tag      = "${var.name_prefix}-data"
  meta_cluster_tag      = "${var.name_prefix}-meta"
  kapacitor_server_tag  = "${var.name_prefix}-kapacitor"
  chronograf_server_tag = "${var.name_prefix}-chronograf"
  telegraf_server_tag   = "${var.name_prefix}-telegraf"
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
  name         = "${var.name_prefix}-sa"
  display_name = "Service Account for TICK Enterprise ${var.name_prefix}"
}

module "internal_firewall" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/service-account-firewall-rules?ref=v0.0.1"
  source = "../../modules/service-account-firewall-rules"

  project                 = var.project
  name_prefix             = var.name_prefix
  network                 = "default"
  source_service_accounts = [module.service_account.email]
  target_service_accounts = [module.service_account.email]
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
  network_tag      = local.data_cluster_tag
  name             = local.data_cluster_name
  machine_type     = var.machine_type
  image            = var.influxdb_image
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
  template = file("${path.module}/startup-scripts/startup-script-data.sh")

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
# CREATE INTERNAL LOAD BALANCER FOR THE INFLUX DATA NODES
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_data_lb" {
  source = "github.com/gruntwork-io/terraform-google-load-balancer//modules/internal-load-balancer?ref=v0.2.1"

  name    = "${var.name_prefix}-data-lb"
  region  = var.region
  project = var.project

  backends = [
    {
      group = module.influxdb_data.instance_group
    },
  ]

  # This setting will enable internal DNS for the load balancer
  service_label = "data"

  network = "default"

  health_check_port = 8086
  target_tags       = [local.data_cluster_tag]
  source_tags       = [local.kapacitor_server_tag, local.telegraf_server_tag, local.chronograf_server_tag]
  ports             = ["8086"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE INFLUXDB META CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_meta" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.meta_cluster_tag
  name             = local.meta_cluster_name
  machine_type     = var.machine_type
  image            = var.influxdb_image
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
  template = file("${path.module}/startup-scripts/startup-script-meta.sh")

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
# CREATE INTERNAL LOAD BALANCER FOR THE INFLUX META NODES
# ---------------------------------------------------------------------------------------------------------------------

module "influxdb_meta_lb" {
  source = "github.com/gruntwork-io/terraform-google-load-balancer//modules/internal-load-balancer?ref=v0.2.1"

  name    = "${var.name_prefix}-meta-lb"
  region  = var.region
  project = var.project

  backends = [
    {
      group = module.influxdb_meta.instance_group
    },
  ]

  # This setting will enable internal DNS for the load balancer
  service_label = "meta"

  network = "default"

  health_check_port = 8091
  target_tags       = [local.meta_cluster_tag]
  source_tags       = [local.chronograf_server_tag]
  ports             = ["8091"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE KAPACITOR SERVER
# ---------------------------------------------------------------------------------------------------------------------

module "kapacitor" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.kapacitor_server_tag
  name             = local.kapacitor_server_name
  machine_type     = var.machine_type
  image            = var.kapacitor_image
  startup_script   = data.template_file.startup_script_kapacitor.rendered
  size             = 1
  network          = "default"

  persistent_volumes = [
    {
      device_name = "kapacitor"
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
# RENDER THE KAPACITOR STARTUP SCRIPT THAT WILL RUN ON EACH META NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_kapacitor" {
  template = file("${path.module}/startup-scripts/startup-script-kapacitor.sh")

  vars = {
    influxdb_url     = "http://${module.influxdb_data_lb.load_balancer_domain_name}:8086"
    disk_device_name = "kapacitor"
    disk_mount_point = "/kapacitor"
    disk_owner       = "kapacitor"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE INTERNAL LOAD BALANCER FOR KAPACITOR
# ---------------------------------------------------------------------------------------------------------------------

module "kapacitor_lb" {
  source = "github.com/gruntwork-io/terraform-google-load-balancer//modules/internal-load-balancer?ref=v0.2.1"

  name    = "${var.name_prefix}-kapacitor-lb"
  region  = var.region
  project = var.project

  backends = [
    {
      group = module.kapacitor.instance_group
    },
  ]

  # This setting will enable internal DNS for the load balancer
  service_label = "kapacitor"

  network = "default"

  health_check_port = 9092
  target_tags       = [local.kapacitor_server_tag]
  source_tags       = [local.kapacitor_server_tag, local.data_cluster_tag]
  ports             = ["9092"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CHRONOGRAF SERVER
# ---------------------------------------------------------------------------------------------------------------------

module "chronograf" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.chronograf_server_tag
  name             = local.chronograf_server_name
  machine_type     = var.machine_type
  image            = var.chronograf_image
  startup_script   = data.template_file.startup_script_chronograf.rendered
  size             = 1
  network          = "default"

  // To make testing easier, we're assigning public IPs to the node
  assign_public_ip = true

  // Use the custom InfluxDB SA
  service_account_email = module.service_account.email
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE CHRONOGRAF STARTUP SCRIPT THAT WILL RUN ON EACH META NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_chronograf" {
  template = file("${path.module}/startup-scripts/startup-script-chronograf.sh")

  vars = {
    host = "0.0.0.0"
    port = "8888"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE TELEGRAF SERVER
# ---------------------------------------------------------------------------------------------------------------------

module "telegraf" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-influx.git//modules/tick-instance-group?ref=v0.0.1"
  source = "../../modules/tick-instance-group"

  project = var.project
  region  = var.region

  root_volume_size = 10
  network_tag      = local.telegraf_server_tag
  name             = local.telegraf_server_name
  machine_type     = var.machine_type
  image            = var.telegraf_image
  startup_script   = data.template_file.startup_script_telegraf.rendered
  size             = 1
  network          = "default"

  // To make testing easier, we're assigning public IPs to the node
  assign_public_ip = true

  // Use the custom InfluxDB SA
  service_account_email = module.service_account.email
}

# ---------------------------------------------------------------------------------------------------------------------
# RENDER THE CHRONOGRAF STARTUP SCRIPT THAT WILL RUN ON EACH META NODE ON BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "startup_script_telegraf" {
  template = file("${path.module}/startup-scripts/startup-script-telegraf.sh")

  vars = {
    influxdb_url  = "http://${module.influxdb_data_lb.load_balancer_domain_name}:8086"
    database_name = "telegraf"
  }
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

  name_prefix = var.name_prefix
  network     = "default"
  project     = var.project
  target_tags = [local.data_cluster_tag, local.meta_cluster_tag, local.kapacitor_server_tag, local.chronograf_server_tag]

  allow_access_from_cidr_blocks = ["0.0.0.0/0"]
}

