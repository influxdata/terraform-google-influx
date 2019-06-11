# Chronograf Run Script

This folder contains a script for configuring and initializing Chronograf on a [GCP Compute Engine](https://cloud.google.com/compute/) server. 
This script has been tested on the following operating systems:

* Ubuntu 18.04

There is a good chance it will work on other flavors of Debian, CentOS, and RHEL as well.

## Quick start

This script assumes you installed it, plus all of its dependencies (including Chronograf itself), using the 
[install-chronograf module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-chronograf). 

This will:

1. Fill out the templated configuration file with user supplied values. For example:

    ```conf
    ...
    HOST=<__HOST__>
    PORT=<__PORT__>
    ...
    ```

1. Start Chronograf on the machine.

We recommend using the `run-chronograf` command as part of the instance [Startup Script](https://cloud.google.com/compute/docs/startupscript), so that it executes when the Compute Instance is first booting.

See the [examples folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples) for 
fully-working sample code.

## Command line Arguments

Run `run-chronograf --help` to see all available arguments.

```
Usage: run-chronograf [options]

This script can be used to configure and initialize Chronograf. This script has been tested with Ubuntu 18.04.

Options:

  --auto-fill   Search the Chronograf config file for KEY and replace it with VALUE. May be repeated.

Example:

  run-chronograf --auto-fill '<__HOST__>=0.0.0.0' --auto-fill '<__PORT__>=8888'
```

## Debugging tips and tricks

Some tips and tricks for debugging issues with your Chronograf agent:

* Use `systemctl status chronograf` to see if systemd thinks the Chronograf process is running.
