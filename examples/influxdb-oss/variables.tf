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
  description = "The name of the InfluxDB cluster/server (e.g. influxdb-oss-test). This variable is used to namespace all resources created by this module. It will also be used to name the instance group."
  type        = string
}

variable "image" {
  description = "The source image used to create the boot disk for an InfluxDB node."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "machine_type" {
  description = "The machine type of the Compute Instance to run for each node in the cluster (e.g. n1-standard-1)."
  type        = string
  default     = "n1-standard-1"
}

