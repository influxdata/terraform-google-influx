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
  description = "The name of the InfluxDB cluster (e.g. influxdb-oss-test). This variable is used to namespace all resources created by this module. It will also be used to name the instance group."
}

variable "data_volume_size" {
  description = "Size of data volume, in GB."
}

variable "network" {
  description = "The name or self link of the VPC network in which to deploy the InfluxDB cluster"
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

variable "allow_access_to_ports" {
  description = "List of ports to allow external access to in the firewall rules."
  type        = "list"
  default     = ["8086"]
}

variable "network_tag" {
  description = "The network tag to assign to the instance. If empty, var.name will be used."
  default     = ""
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

variable "instance_group_target_pools" {
  description = "To use a Load Balancer with the InfluxDB cluster, you must populate this value. Specifically, this is the list of Target Pool URLs to which new Compute Instances in the Instance Group created by this module will be added. Note that updating the Target Pools attribute does not affect existing Compute Instances."
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

variable "data_volume_device_name" {
  description = "The device name to use for the persistent volume."
  default     = "influxdb"
}

variable "service_account_email" {
  description = "The email of a service account for the instance template. If none is provided, the default google cloud provider project service account is used."
  default     = ""
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

variable "allow_access_from_cidr_blocks" {
  description = "The list of CIDR-formatted IP address ranges from which access to InfluxDB will be allowed."
  type        = "list"
  default     = []
}

variable "allow_access_from_source_tags" {
  description = "The list source."
  type        = "list"
  default     = []
}

variable "internal_firewall_allowed_ports" {
  description = "Allowed ports or port ranges in the internal firewall to allow nodes to communicate with each other"
  type        = "list"
  default     = ["8086", "8088", "8089", "8091"]
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
