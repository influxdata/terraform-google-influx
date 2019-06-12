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

variable "api_port" {
  description = "The HTTP API port the Data nodes listen on for external communication."
  default     = "8086"
}

variable "raft_port" {
  description = "The Raft consensus protocol port on which Meta/Data nodes communicate with each other"
  default     = "8089"
}

variable "rest_port" {
  description = "The HTTP API port the Meta/Data nodes listen on for internal communication."
  default     = "8091"
}

variable "tcp_port" {
  description = "The port the Meta/Data nodes use for internal communication via a TCP protocol."
  default     = "8088"
}

variable "allow_api_access_from_source_tags" {
  description = "If source tags are specified, the external firewall will apply only to traffic with source IP that belongs to a tag listed in source tags."
  type        = "list"
  default     = []
}

variable "allow_api_access_from_cidr_blocks" {
  description = "The list of CIDR-formatted IP address ranges from which access to InfluxDB will be allowed."
  type        = "list"
  default     = []
}
