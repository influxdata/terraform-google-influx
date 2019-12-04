<!--
:type: service
:name: TICK Stack
:description: Deploy the TICK stack (Telegraf, InfluxDB, Chronograf, Kapacitor) in GCP to gather and process time series data.
:icon: /_docs/tick-stack-gcp-icon.png
:category: Monitoring & alerting
:cloud: gcp
:tags: database, time-series
:license: open-source
:built-with: terraform, bash
-->
# TICK Stack GCP Module

[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_influx)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-influx.svg?label=latest)](https://github.com/gruntwork-io/terraform-google-influx/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)

This repo contains the **official** module for deploying the [TICK Stack](https://www.influxdata.com/time-series-platform/) on [GCP](https://cloud.google.com/gcp/) using [Terraform](https://www.terraform.io/) and [Packer](https://www.packer.io/).

## TICK Stack Architecture

![TICK multi-cluster architecture](https://github.com/gruntwork-io/terraform-google-influx/blob/master/_docs/tick-multi-cluster-architecture.png?raw=true)

## Features

- Deploy the TICK stack (Telegraf, InfluxDB, Chronograf, Kapacitor) to gather and process time series data.
- Supports both InfluxDB Enterprise and OSS
- Supports both InfluxDB Enterprise and OSS
- Supports colocated clusters and separate clusters

## What is TICK Stack?

The TICK Stack is a loosely coupled yet tightly integrated set of open source projects designed to handle massive amounts of time-stamped information to support your metrics analysis needs.

Collectively, [Telegraf](https://github.com/influxdata/telegraf), [InfluxDB](https://github.com/influxdata/influxdb), [Chronograf](https://github.com/influxdata/chronograf) and [Kapacitor](https://github.com/influxdata/kapacitor) are known as the TICK Stack.

## Learn

This repo is a part of [the Gruntwork Infrastructure as Code Library](https://gruntwork.io/infrastructure-as-code-library/), a collection of reusable, battle-tested, production ready infrastructure code. If you’ve never used the Infrastructure as Code Library before, make sure to read [How to use the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/)!

### Core concepts

- [What is TICK Stack](https://github.com/gruntwork-io/terraform-google-influx/blob/master/core-concepts.md#what-is-tick-stack)
- [Influxdata documentation](https://docs.influxdata.com/)
- [Using this repository](https://github.com/gruntwork-io/terraform-google-influx/blob/master/core-concepts.md#using-this-repository)

### Repo organisation

This repo has the following folder structure:

* [root](https://github.com/gruntwork-io/terraform-google-influx): The root folder contains an example of how to deploy InfluxDB OSS. See
  [influxdb-oss](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-oss) for the documentation.
* [modules](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules): This folder contains the main implementation code for this Module, broken down into multiple standalone submodules.
* [examples](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples): This folder contains examples of how to use the submodules.
* [test](https://github.com/gruntwork-io/terraform-google-influx/tree/master/test): Automated tests for the submodules and examples.

See [how to use this repository](https://github.com/gruntwork-io/terraform-google-influx/blob/master/core-concepts.md#using-this-repository) to configure and deploy TICK Stack.


## Deploy

### Non-production deployment (quick start for learning)

If you just want to try this repo out for experimenting and learning, check out the following resources:

- [examples folder](https://github.com/gruntwork-io/terraform-google-influx/blob/master/examples): The `examples` folder 
contains sample code optimized for learning, experimenting, and testing (but not production usage).

### Production deployment

If you want to deploy this repo in production, check out the following resources:

- [Influx Production Installation Guide](https://docs.influxdata.com/enterprise_influxdb/v1.7/install-and-deploy/production_installation/) 
- [Using this repository](https://github.com/gruntwork-io/terraform-google-influx/blob/master/core-concepts.md#using-this-repository)

## Manage

### Day-to-day operations

- [Configuring InfluxDB](https://docs.influxdata.com/influxdb/v1.7/administration/config/)
- [Upgrading InfluxDB](https://docs.influxdata.com/influxdb/v1.7/administration/upgrading/)
- [Enabling HTTPS](https://docs.influxdata.com/influxdb/v1.7/administration/https_setup/)
- [Logging in InfluxDB](https://docs.influxdata.com/influxdb/v1.7/administration/logs/)
- [Backing up and restoring](https://docs.influxdata.com/influxdb/v1.7/administration/backup_and_restore/)
- [Managing security](https://docs.influxdata.com/influxdb/v1.7/administration/security/)

## Support

If you need help with this repo or anything else related to infrastructure or DevOps, Gruntwork offers [Commercial Support](https://gruntwork.io/support/) via Slack, email, and phone/video. If you’re already a Gruntwork customer, hop on Slack and ask away! If not, [subscribe now](https://www.gruntwork.io/pricing/). If you’re not sure, feel free to email us at [support@gruntwork.io](mailto:support@gruntwork.io).

## Contributions

Contributions to this repo are very welcome and appreciated! If you find a bug or want to add a new feature or even contribute an entirely new module, we are very happy to accept pull requests, provide feedback, and run your changes through our automated test suite.

Please see [Contributing to the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#contributing-to-the-gruntwork-infrastructure-as-code-library) for instructions.

## License

Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-influx/blob/master/LICENSE.txt) for details on how the code in this repo is licensed.

Copyright &copy; 2019 Gruntwork, Inc.
