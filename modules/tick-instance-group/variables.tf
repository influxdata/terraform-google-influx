# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "All resources will be launched in this region."
  type        = string
}

variable "project" {
  description = "ID of the GCP Project where all resources will be launched."
  type        = string
}

variable "name" {
  description = "The name of the instance group (e.g. influxdb-prod-meta). This variable is used to namespace all resources created by this module. It will also be used to name the instance group."
  type        = string
}

variable "size" {
  description = "The number of nodes to have in the instance group."
  type        = number
}

variable "network_tag" {
  description = "The network tag name used to tag the instances"
  type        = string
}

variable "image" {
  description = "The source image used to create the boot disk for an InfluxDB node."
  type        = string
}

variable "startup_script" {
  description = "A Startup Script to execute when the server first boots. We recommend passing in a bash script that executes the run-influxdb script, which should have been installed in the InfluxDB Google Image by the install-influxdb module."
  type        = string
}

variable "machine_type" {
  description = "The type of compute instances to run for each node in the cluster (e.g. 'n1-standard-1')."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "network" {
  description = "The name or self link of the VPC network in which to deploy the InfluxDB cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self link of the VPC Subnetwork where all resources should be created."
  type        = string
  default     = ""
}

variable "network_project" {
  description = "The name of the GCP Project where the network is located. Useful when using networks shared between projects. If empty, var.project will be used."
  type        = string
  default     = ""
}

variable "image_project" {
  description = "ID of the GCP Project where the image is located. Useful when using a separate project for custom images. If empty, var.project will be used."
  type        = string
  default     = ""
}

variable "target_pools" {
  description = "The target load balancing pools to assign this group to."
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Size of root volume, in GB."
  type        = number
  default     = 50
}

variable "persistent_volumes" {
  description = "List of persistent volumes to be attached to the instance."
  type = list(object({
    device_name = string
    size        = number
    auto_delete = bool
  }))
  default = []
}

variable "service_account_email" {
  description = "The email of a service account for the instance template. If none is provided, the default google cloud provider project service account is used."
  type        = string
  default     = ""
}

variable "service_account_scopes" {
  description = "A list of service account scopes that will be added to the Compute Instance Template in addition to the scopes automatically added by this module."
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "If true, each of the Compute Instances will receive a public IP address and be reachable from the Public Internet (if Firewall rules permit). If false, the Compute Instances will have private IP addresses only. In production, this should be set to false."
  type        = bool
  default     = false
}

variable "custom_tags" {
  description = "A list of custom tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module."
  type        = list(string)
  default     = []
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the instances. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

