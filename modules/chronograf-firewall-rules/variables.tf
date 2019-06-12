# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "ID of the GCP Project where all resources will be launched."
}

variable "name_prefix" {
  description = "This variable is used to namespace all resources created by this module."
}

variable "target_tags" {
  description = "The target tags define the compute instances to which the rules apply."
  type        = "list"
}

variable "network" {
  description = "The name or self link of the VPC network in which to deploy the InfluxDB cluster"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "http_port" {
  description = "The HTTP API port the Chronograf server listens on for external communication."
  default     = "8888"
}

variable "allow_http_access_from_source_tags" {
  description = "If source tags are specified, the external firewall will apply only to traffic with source IP that belongs to a tag listed in source tags."
  type        = "list"
  default     = []
}

variable "allow_http_access_from_cidr_blocks" {
  description = "The list of CIDR-formatted IP address ranges from which access to InfluxDB will be allowed."
  type        = "list"
  default     = []
}
