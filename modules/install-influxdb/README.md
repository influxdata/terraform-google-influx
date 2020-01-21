# InfluxDB Install Script

This folder contains a script for installing InfluxDB and its dependencies. Use this script to create an InfluxDB [Compute Image](https://cloud.google.com/compute/docs/images) that can be deployed in [GCP](https://cloud.google.com/gcp/) across an [Instance Group](https://cloud.google.com/compute/docs/instance-groups/) using the [tick-instance-group module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/tick-instance-group).

You can install either OSS or Enterprise version of InfluxDB using the `--distribution` argument. Allowed values are `oss` and `enterprise`.

This script has been tested on the following operating systems:

* Ubuntu 18.04

There is a good chance it will work on other flavors of Debian, CentOS, and RHEL as well.

## Quick start

This module depends on [bash-commons](https://github.com/gruntwork-io/bash-commons), so you must install that project first as documented in its README.

The easiest way to use this module is with the [Gruntwork Installer](https://github.com/gruntwork-io/gruntwork-installer):

```bash
gruntwork-install \
  --module-name "install-influxdb" \
  --repo "https://github.com/gruntwork-io/terraform-google-influx" \
  --tag "<VERSION>"
```

Checkout the [releases](https://github.com/gruntwork-io/terraform-google-influx/releases) to find the latest version.

Depending on `--distribution`, the `install-influxdb` script will install either the OSS binaries or both InfluxDB meta and data binaries, as well as their dependencies. The [run-influxdb](../run-influxdb) script determines whether to startup either as a standalone, meta or data node.

We recommend running the `install-influxdb` script as part of a [Packer](https://www.packer.io/) template to create an InfluxDB [Compute Image](https://cloud.google.com/compute/docs/images). You can then deploy the Image across an [Instance Group](https://cloud.google.com/compute/docs/instance-groups/) using the [tick-instance-group module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/tick-instance-group) (see the [examples folder](../../examples) for fully-working sample code).

## Command line Arguments

Run `install-influxdb --help` to see all available arguments.

```
Usage: install-influxdb [options]

This script can be used to install InfluxDB Enterprise and its dependencies. This script has been tested with Ubuntu 18.04.

Options:

  --distribution      The distribution of InfluxDB (oss/enterprise) to install. Default: oss."
  --version           The version of InfluxDB Enterprise to install. Default: 1.6.2.
  --oss-config-file   Path to a templated oss configuration file. Used for oss distribution. Default: /tmp/config/influxdb.conf
  --meta-config-file  Path to a templated meta node configuration file. Default: /tmp/config/influxdb-meta.conf
  --data-config-file  Path to a templated data node configuration file. Default: /tmp/config/influxdb.conf

Examples:

  install-influxdb \
    --distribution enterprise \
    --version 1.6.2 \
    --meta-config-file /tmp/config/influxdb-meta.conf \
    --data-config-file /tmp/config/influxdb.conf

  install-influxdb \
    --distribution oss \
    --version 1.6.2 \
    --oss-config-file /tmp/config/influxdb.conf
```

## How it works

The `install-influxdb` script does the following:

1. Installs the InfluxDB binaries
1. Replaces default config files with specified templated config files.
