[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_influx)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-influx.svg?label=latest)](https://github.com/gruntwork-io/terraform-google-influx/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)
# TICK Stack GCP Module

This repo contains the **official** module for deploying the [TICK Stack](https://www.influxdata.com/time-series-platform/) on [GCP](https://cloud.google.com/gcp/) using [Terraform](https://www.terraform.io/) and [Packer](https://www.packer.io/).

The TICK Stack is a loosely coupled yet tightly integrated set of open source projects designed to handle massive amounts of time-stamped information to support your metrics analysis needs. 

Collectively, [Telegraf](https://github.com/influxdata/telegraf), [InfluxDB](https://github.com/influxdata/influxdb), [Chronograf](https://github.com/influxdata/chronograf) and [Kapacitor](https://github.com/influxdata/kapacitor) are known as the TICK Stack.

![TICK multi-cluster architecture](https://github.com/gruntwork-io/terraform-google-influx/blob/master/_docs/tick-multi-cluster-architecture.png?raw=true)

## Quick start

If you want to quickly spin up an InfluxDB OSS server, you can run the simple example that is in the root of this repo. Check out [influxdb-oss example documentation](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-oss) for instructions.

## What's in this repo

This repo has the following folder structure:

* [root](https://github.com/gruntwork-io/terraform-google-influx): The root folder contains an example of how to deploy InfluxDB OSS. See 
  [influxdb-oss](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples/influxdb-oss) for the documentation.
* [modules](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules): This folder contains the main implementation code for this Module, broken down into multiple standalone submodules.
* [examples](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples): This folder contains examples of how to use the submodules.
* [test](https://github.com/gruntwork-io/terraform-google-influx/tree/master/test): Automated tests for the submodules and examples.

## How to use this repo

The general idea is to use the modules to setup different components of the TICK Stack:

* ### Telegraf

    1. Use the scripts in the [install-telegraf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-telegraf) modules to create a [machine image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) with Telegraf installed.
    
    1. Configure each application server to execute the [run-telegraf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-telegraf) script during boot.

* ### InfluxDB

    1. Use the scripts in the [install-influxdb](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-influxdb) modules to create a [machine image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) with InfluxDB Enterprise installed.
    
    1. Deploy the server across one or more [Instance Groups](https://cloud.google.com/compute/docs/instance-groups/) using the [influxdb-cluster
module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/influxdb-cluster).
    
    1. Configure each server in the Instance Groups to execute the [run-influxdb](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-influxdb) script during boot.

    1. Deploy a load balancer in front of the data node Instance Group.
    
* ### Chronograf

    1. Use the scripts in the [install-chronograf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-chronograf) modules to create a machine image with Chronograf installed.
    
    1. Deploy the image in a single instance group using the [chronograf-server
module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/chronograf-server).
    
    1. Configure the server to execute the [run-chronograf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-chronograf) script during boot.

    1. Deploy a load balancer in front of the instance group.
    
* ### Kapacitor

    1. Use the scripts in the [install-kapacitor](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-kapacitor) modules to create a machine image with Kapacitor installed.
    
    1. Deploy the image in a single instance group using the [kapacitor-server module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/kapacitor-server).

    1. Configure the server to execute the [run-kapacitor](modules/run-kapacitor) script during boot.
    
1. Deploy a load balancer in front of the instance group.
  

See the [examples folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples) for working
sample code.

## What's a Module?

A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such 
as a database or server cluster. Each Module is written using a combination of [Terraform](https://www.terraform.io/) 
and scripts (mostly bash) and include automated tests, documentation, and examples. It is maintained both by the open 
source community and companies that provide commercial support. 

Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse 
existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself, 
you can leverage the work of the Module community to pick up infrastructure improvements through
a version number bump.

## Who maintains this Module?

This Module is maintained by [Gruntwork](http://www.gruntwork.io/). If you're looking for help or commercial support, send an email to [modules@gruntwork.io](mailto:modules@gruntwork.io?Subject=InfluxDB%20for%20GCP%20Module). Gruntwork can help with:

* Setup, customization, and support for this Module.
* Modules for other types of infrastructure, such as VPCs, GKE clusters, databases, and continuous integration.
* Modules that meet compliance requirements, such as HIPAA.
* Consulting & Training on GCP, AWS, Terraform, and DevOps.

## How do I contribute to this Module?

Contributions are very welcome! Check out the [Contribution Guidelines](CONTRIBUTING.md) for instructions.

## How is this Module versioned?

This Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release, 
along with the changelog, in the [Releases Page](https://github.com/gruntwork-io/terraform-google-influx/releases). 

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR, MINOR, and PATCH versions on each release to indicate any incompatibilities. 

## License

This code is released under the Apache 2.0 License. Please see 
[LICENSE](https://github.com/gruntwork-io/terraform-google-influx/blob/master/LICENSE) and 
[NOTICE](https://github.com/gruntwork-io/terraform-google-influx/blob/master/NOTICE) for more details.

Copyright &copy; 2019 Gruntwork, Inc.

