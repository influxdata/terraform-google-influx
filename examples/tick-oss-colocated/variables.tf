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
  description = "The name of the cluster (e.g. tick-oss-example). This variable is used to namespace all resources created by this module. It will also be used to name the instance group."
}

variable "image" {
  description = "The source image used to create the boot disk for an InfluxDB node."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "machine_type" {
  description = "The machine type of the Compute Instance to run for each node in the cluster (e.g. n1-standard-1)."
  default     = "n1-standard-1"
}
