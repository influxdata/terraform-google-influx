# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "ID of the GCP Project where all resources will be created."
}

variable "name_prefix" {
  description = "This variable is used to namespace all resources created by this module."
}

variable "network" {
  description = "The name or self_link of the network to attach this firewall to."
}

variable "source_service_accounts" {
  description = "The firewall will apply only to traffic originating from an instance with a service account in this list."
  type        = "list"
}

variable "target_service_accounts" {
  description = "A list of service accounts indicating sets of instances to apply the rule to."
  type        = "list"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "ports" {
  description = "An optional list of ports or port ranges to which this rule applies. If not specified, this rule applies to connections through any port."
  type        = "list"
  default     = []
}

variable "protocol" {
  description = "The IP protocol to which this rule applies."
  default     = "tcp"
}
