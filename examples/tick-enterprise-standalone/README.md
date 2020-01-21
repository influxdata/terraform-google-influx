# TICK Enterprise Example

This folder shows an example of Terraform code that uses various modules to deploy an enterprise [TICK](https://www.influxdata.com/time-series-platform/) cluster in GCP.

You will need to create a [custom image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) for each of the TICK components, which you can do using the [machine image examples](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images). 

## Quick start

To deploy TICK Enterprise:

1. `git clone` this repo to your computer.
1. Build the custom machine images with Packer. Make sure to note down the IDs of the images.
   1. [InfluxDB Enterprise](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/influxdb-enterprise)
   1. [Chronograf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/chronograf)
   1. [Kapacitor](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/kapacitor)
   1. [Telegraf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/telegraf)
1. Install [Terraform](https://www.terraform.io/).
1. Open the `variables.tf`, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default. Put the custom image IDs into the respective variables.
1. Run `terraform init`
1. Run `terraform apply`

## Connecting to the cluster

As the example deploys internal load balancers that cannot be reached from the internet, we have made testing easier by assigning public IP addresses to the compute instances. 

You can get the instance public IP address using one of the following methods:

1. Login to [GCP Console](https://console.cloud.google.com/), go to the VM instances page and locate the instances' public IP addresses
2. Run the following commands in the root folder of this repo:
  * `IGM=$(terraform output influxdb_instance_group_manager | tr -d '\n')`
  * `INSTANCE_URI=$(gcloud compute instance-groups managed list-instances $IGM --limit=1 --uri)`
  * `gcloud compute instances describe $INSTANCE_URI --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`

Check out [How do you connect to the InfluxDB cluster](https://github.com/gruntwork-io/terraform-aws-influx/tree/master/modules/influxdb-cluster#how-do-you-connect-to-the-influxdb-cluster) documentation for further details.

To connect to Chronograf, use the steps described above, replacing `influxdb_instance_group_manager` with `chronograf_instance_group_manager`.