# Chronograf Install Script

[Chronograf](https://www.influxdata.com/time-series-platform/chronograf/) is a complete web-based interface for the entire InfluxData platform.
This folder contains a script for installing Chronograf and its dependencies.

This script has been tested on the following operating systems:

* Ubuntu 18.04

There is a good chance it will work on other flavors of Debian, CentOS, and RHEL as well.

## Quick start

This module depends on [bash-commons](https://github.com/gruntwork-io/bash-commons), so you must install that project
first as documented in its README.

The easiest way to use this module is with the [Gruntwork Installer](https://github.com/gruntwork-io/gruntwork-installer):

```bash
gruntwork-install \
  --module-name "install-chronograf" \
  --repo "https://github.com/gruntwork-io/terraform-google-influx" \
  --tag "<VERSION>"
```

Checkout the [releases](https://github.com/gruntwork-io/terraform-google-influx/releases) to find the latest version.

The `install-chronograf` script will install the Chronograf binary as well as its dependencies.

We recommend running the `install-chronograf` script as part of a [Packer](https://www.packer.io/) template to 
create a Chronograf [custom image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) for [Compute Engine](https://cloud.google.com/compute/).
You can then deploy the image across an instance group (see the 
[examples folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples) for fully-working sample code).

## Command line Arguments

Run `install-chronograf --help` to see all available arguments.

```
Usage: install-chronograf [options]

This script can be used to install Chronograf and its dependencies. This script has been tested with Ubuntu 18.04.

Options:

  --version       The version of Chronograf to install. Default: 1.7.8.
  --config-file   Path to a custom configuration file. Default: /tmp/config/chronograf.conf

Example:

  install-chronograf \
    --version 1.7.8 \
    --config-file /tmp/config/chronograf.conf
```

## How it works

The `install-chronograf` script does the following:

1. Installs the Chronograf binary
1. Replaces the default Chronograf config file with your custom config file.
