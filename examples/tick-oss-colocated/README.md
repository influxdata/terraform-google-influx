# TICK OSS Example

This folder shows an example of Terraform code that uses various modules to deploy an OSS [TICK](https://www.influxdata.com/time-series-platform/) cluster in GCP.

You will need to create a [custom image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) with all TICK components installed, which you can do using the [tick-oss-all-in-one example](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/machine-images/tick-oss-all-in-one). 

## Quick start

To deploy TICK OSS:

1. `git clone` this repo to your computer.
2. Build the custom machine image with Packer. Make sure to note down the ID of the image.
3. Install [Terraform](https://www.terraform.io/).
4. Open the `variables.tf`, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default. Put the custom image IDs into the respective variables.
5. Run `terraform init`
6. Run `terraform apply`

## Connecting to the cluster

TODO:  Use the network LB with TF12

As the example deploys an internal load balancer that cannot be reached from outside the created network, we have made testing easier by assigning a public IP address to the InfluxDB compute instance. 

You can get the public IP address using one of the following methods:

1. Login to [GCP Console](https://console.cloud.google.com/), go to the VM instances page and locate the instance and its public IP address
2. Run the following commands in the root folder of this repo:
   - `IGM=$(terraform output influxdb_instance_group_manager | tr -d '\n')`
   - `INSTANCE_URI=$(gcloud compute instance-groups managed list-instances $IGM --limit=1 --uri)`
   - `gcloud compute instances describe $INSTANCE_URI --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`

Check out [How do you connect to the InfluxDB cluster](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/influxdb-cluster#how-do-you-connect-to-the-influxdb-cluster) documentation for further details.