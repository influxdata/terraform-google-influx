# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "Region to deploy the resources in."
}

variable "cluster_name" {
  description = "The name of the InfluxDB cluster (e.g. influxdb-stage). This variable is used to namespace all resources created by this module."
}

variable "instance_group" {
  description = "Self link to the instance group..."
}

variable "network" {
  description = "Self link of the VPC Network."
}

variable "subnetwork" {
  description = "Self link of the VPC Subnetwork."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "load_balancing_scheme" {
  description = "This signifies what the ForwardingRule will be used for and can only take the following values: INTERNAL, EXTERNAL."
  default     = "INTERNAL"
}

variable "ip_address" {
  description = "The static IP address to assign to the Forwarding Rule. If not set, an ephemeral IP address is used."
  default     = ""
}

# Health Check options

variable "health_check_interval_sec" {
  description = "The number of seconds between each Health Check attempt."
  default     = 10
}

variable "health_check_timeout_sec" {
  description = "The number of seconds to wait before the Health Check declares failure."
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive successes required to consider the Compute Instance healthy."
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive failures required to consider the Compute Instance unhealthy."
  default     = 2
}

# Firewall options

variable "firewall_allowed_ports" {
  description = "List of ports to which connections can be made. Each entry must be either an integer or a range."
  type        = "list"
  default     = []
}

variable "firewall_target_tags" {
  description = "A list of instance tags indicating sets of instances located in the network that may make network connections as specified in ´firewall_allowed_ports´"
  type        = "list"
  default     = []
}
