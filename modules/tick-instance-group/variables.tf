# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "All resources will be launched in this region."
}

variable "project" {
  description = "ID of the GCP Project where all resources will be launched."
}

variable "name" {
  description = "The name of the instance group (e.g. influxdb-prod-meta). This variable is used to namespace all resources created by this module. It will also be used to name the instance group."
}

variable "size" {
  description = "The number of nodes to have in the instance group."
}

variable "network_tag" {
  description = "The network tag name used to tag the instances"
}

variable "data_volume_size" {
  description = "Size of data volume, in GB."
}

variable "data_volume_device_name" {
  description = "Device name for the data volume. The device will be available in '/dev/disk/by-id/google-[data_volume_device_name]"
}

variable "image" {
  description = "The source image used to create the boot disk for an InfluxDB node."
}

variable "startup_script" {
  description = "A Startup Script to execute when the server first boots. We recommend passing in a bash script that executes the run-influxdb script, which should have been installed in the InfluxDB Google Image by the install-influxdb module."
}

variable "machine_type" {
  description = "The type of compute instances to run for each node in the cluster (e.g. 'n1-standard-1')."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "network" {
  description = "The name or self link of the VPC network in which to deploy the InfluxDB cluster"
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self link of the VPC Subnetwork where all resources should be created."
  default     = ""
}

variable "network_project" {
  description = "The name of the GCP Project where the network is located. Useful when using networks shared between projects. If empty, var.project will be used."
  default     = ""
}

variable "image_project" {
  description = "ID of the GCP Project where the image is located. Useful when using a separate project for custom images. If empty, var.project will be used."
  default     = ""
}

variable "target_pools" {
  description = "The target load balancing pools to assign this group to."
  type        = "list"
  default     = []
}

variable "root_volume_size" {
  description = "Size of root volume, in GB."
  default     = 50
}

variable "data_volume_auto_delete" {
  description = "Whether or not the data volume should be auto-deleted."
  default     = false
}

variable "service_account_email" {
  default     = ""
  description = "The email of a service account for the instance template. If none is provided, the default google cloud provider project service account is used."
}

variable "service_account_scopes" {
  description = "A list of service account scopes that will be added to the Compute Instance Template in addition to the scopes automatically added by this module."
  type        = "list"
  default     = []
}

variable "assign_public_ip" {
  description = "If true, each of the Compute Instances will receive a public IP address and be reachable from the Public Internet (if Firewall rules permit). If false, the Compute Instances will have private IP addresses only. In production, this should be set to false."
  default     = false
}

variable "custom_tags" {
  description = "A list of custom tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module."
  type        = "list"
  default     = []
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the instances. The key is the label name and the value is the label value."
  type        = "map"
  default     = {}
}
