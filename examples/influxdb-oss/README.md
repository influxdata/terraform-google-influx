# InfluxDB OSS Example

This folder shows an example of Terraform code that uses the [influxdb-cluster](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/influxdb-cluster) module to deploy a [InfluxDB OSS](https://www.influxdata.com/products/influxdb-overview/) single node cluster in [GCP](https://cloud.google.com/). The cluster consists of a Managed Regional Instance Group with a single compute instance that runs InfluxDB.

This example also deploys an Internal TCP Load Balancer in front of the InfluxDB cluster. Note that as the load balancer is internal, it is not accessible from the public internet. 

You will need to create a [custom image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) for [Compute Engine](https://cloud.google.com/compute/) that has [InfluxDB OSS](https://www.influxdata.com/products/influxdb-overview/) installed, which you can do using the [influxdb-oss machine image example](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/influxdb-oss). 

To see an example of InfluxDB Enterprise deployed across separate clusters, see the [influxdb-enterprise
example](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-enterprise). For more info on how the InfluxDB cluster works, check out the [documentation at the root of the repository](https://github.com/gruntwork-io/terraform-google-influx).

## Quick start

To deploy InfluxDB OSS:

1. `git clone` this repo to your computer.
1. Build a custom InfluxDB OSS image. See the [influxdb-oss machine image example](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/influxdb-oss) documentation for instructions. Make sure to note down the ID of the image.
1. Install [Terraform](https://www.terraform.io/).
1. Open the `variables.tf`, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default. Put the custom image ID into the `image` variable.
1. Run `terraform init`
1. Run `terraform apply`

## Connecting to the cluster

As the example deploys an internal load balancer that cannot be reached from outside the created network, we have made testing easier by assigning a public IP address to the InfluxDB compute instance. 

You can get the public IP address using one of the following methods:

1. Login to [GCP Console](https://console.cloud.google.com/), go to the VM instances page and locate the instance and its public IP address
2. Run the following commands in the root folder of this repo:
  * `IGM=$(terraform output influxdb_instance_group_manager | tr -d '\n')`
  * `INSTANCE_URI=$(gcloud compute instance-groups managed list-instances $IGM --limit=1 --uri)`
  * `gcloud compute instances describe $INSTANCE_URI --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`

Check out [How do you connect to the InfluxDB cluster](https://github.com/gruntwork-io/terraform-aws-influx/tree/master/modules/influxdb-cluster#how-do-you-connect-to-the-influxdb-cluster) documentation for further details.
