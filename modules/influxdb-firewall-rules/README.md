# InfluxDB Firewall Rules Module

This folder contains a [Terraform](https://www.terraform.io/) module that defines the [firewall rules](https://cloud.google.com/vpc/docs/firewalls) 
used to control both internal and external traffic that is allowed to go in and out of the InfluxDB instance groups. 

## Quick Start

* See the [tick-enterprise-standalone example](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/tick-enterprise-standalone) for working sample code.
* Check out [variables.tf](https://github.com/gruntwork-io/terraform-google-influx/blob/master/modules/influxdb-firewall-rules/variables.tf) for all parameters you can set for this module.
