# TICK Instance Group

This folder contains a [Terraform](https://www.terraform.io/) module to deploy a [Regional Managed Instance Group](https://cloud.google.com/compute/docs/instance-groups/#managed_instance_groups) 
in [GCP](https://cloud.google.com/). The module is used to create Managed Instance Groups for InfluxDB, Kapacitor and Chronograf.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "influxdb_data_cluster" {
  # TODO: replace <VERSION> with the latest version from the releases page: https://github.com/gruntwork-io/terraform-google-influx/releases
  source = "github.com/gruntwork-io/terraform-google-influx//modules/managed-instance-group?ref=<VERSION>"

  # Specify the ID of the custom image. You should build this using the install-xxx -scripts in the modules -folder.
  image = "influxdb-ubuntu-xxxxxx"
  
  # Configure and start InfluxDB during boot. 
  startup_script = <<-EOF
              #!/bin/bash
              sudo systemctl start influxdb
              EOF
  
  # ... See variables.tf for the other parameters you must define for the module
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of the `managed-instance-group` module. The double slash (`//`) is 
  intentional and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `master` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.

* `image`: Use this parameter to specify the ID of a custom [Machine Image](https://cloud.google.com/compute/docs/images) 
to deploy on each server in the instance group. You should use the `install-xxx` -scripts in [modules folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules)
to install required files and binaries.
  
* `startup_script`: Use this parameter to specify a [Startup Script](https://cloud.google.com/compute/docs/startupscript) 
that each server will run during boot. This is where you can use the `run-xxx` scripts in the [modules folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules). 

You can find the other parameters in [variables.tf](https://github.com/gruntwork-io/terraform-google-influx/blob/master/modules/tick-instance-group/variables.tf).

Check out the [examples folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples) for fully-working sample code.
