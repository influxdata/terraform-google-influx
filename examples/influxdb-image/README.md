# InfluxDB Image

This folder shows an example of how to use the [install-influxdb](../../modules/install-influxdb) modules with [Packer](https://www.packer.io/) to create a [custom image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) for [Compute Engine](https://cloud.google.com/compute/) that have [InfluxDB Enterprise](https://www.influxdata.com/time-series-platform/influxdb/), and its dependencies installed on top of Ubuntu 18.04

## Quick start

To build the InfluxDB Image:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your GCP credentials:
   1. Set `GOOGLE_CREDENTIALS` environment variable to local path of your Google Cloud Platform account credentials in JSON format.
   1. Set `GOOGLE_CLOUD_PROJECT_ID` environment variable to your GCP Project ID.
1. Update the `variables` section of the `influxdb.json` Packer template to specify the GCP region and zone, and InfluxDB version you wish to use.
1. To build an Ubuntu image for InfluxDB Enterprise: `packer build -only=influxdb-gcp-ubuntu influxdb.json`.

When the build finishes, it will output the ID of the new image. To see how to deploy the image, check out the [influxdb-oss](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-oss) and [influxdb-enterprise](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-enterprise) examples.

## Creating your own Packer template for production usage

When creating your own Packer template for production usage, you can copy the example in this folder more or less exactly, except for one change: we recommend replacing the `file` provisioner with a call to `git clone` in a `shell` provisioner. Instead of:

```json
{
  "provisioners": [{
    "type": "file",
    "source": "{{template_dir}}/../../../terraform-google-influx",
    "destination": "/tmp"
  },{
    "type": "shell",
    "inline": [
      "/tmp/terraform-google-influx/modules/install-influxdb/install-influxdb --version {{user `influxdb_version`}}"
    ],
    "pause_before": "30s"
  }]
}
```

Your code should look more like this:

```json
{
  "provisioners": [{
    "type": "shell",
    "inline": [
      "git clone --branch <MODULE_VERSION> https://github.com/gruntwork-io/terraform-google-influx.git /tmp/terraform-google-influx",
      "/tmp/terraform-google-influx/modules/install-influxdb/install-influxdb --version {{user `influxdb_version`}}"
    ],
    "pause_before": "30s"
  }]
}
```

You should replace `<MODULE_VERSION>` in the code above with the version of this module that you want to use (see the [Releases Page](https://github.com/gruntwork-io/terraform-google-influx/releases) for all available versions). That's because for production usage, you should always use a fixed, known version of this Module, downloaded from the official Git repo via `git clone`. On the other hand, when you're just experimenting with the Module, it's OK to use a local checkout of the Module, uploaded from your own computer via the `file` provisioner.

## Local testing

The Packer template in this example folder can build not only AMIs, but also Docker images for local testing. This is convenient for testing out the various scripts in the `modules` folder without having to wait for an AMI to build and a bunch of EC2 Instances to boot up.
