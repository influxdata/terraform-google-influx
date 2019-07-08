# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ------------------------------------------------------------------------------

# TF_VAR_license_key
# TF_VAR_shared_secret

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

variable "name_prefix" {
  description = "This variable is used to namespace all resources created by this module."
  type        = string
}

variable "influxdb_image" {
  description = "The source image used to create the boot disk for an InfluxDB nodes."
  type        = string
}

variable "kapacitor_image" {
  description = "The source image used to create the boot disk for an Kapacitor nodes."
  type        = string
}

variable "telegraf_image" {
  description = "The source image used to create the boot disk for an Telegraf nodes."
  type        = string
}

variable "chronograf_image" {
  description = "The source image used to create the boot disk for an Chronograf nodes."
  type        = string
}

variable "license_key" {
  description = "The key of your InfluxDB Enterprise license. This should not be set in plain-text and can be passed in as an env var or from a secrets management tool."
  type        = string
}

variable "shared_secret" {
  description = "A long pass phrase that will be used to sign tokens for intra-cluster communication on data nodes. This should not be set in plain-text and can be passed in as an env var or from a secrets management tool."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "machine_type" {
  description = "The machine type of the Compute Instance to run for each node in the solution (e.g. n1-standard-1)."
  type        = string
  default     = "n1-standard-1"
}

