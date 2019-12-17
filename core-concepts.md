# TICK Stack Core Concepts

## What is TICK Stack?

The TICK Stack is a loosely coupled yet tightly integrated set of open source projects designed to handle massive amounts of time-stamped information to support your metrics analysis needs.

Collectively, [Telegraf](https://github.com/influxdata/telegraf), [InfluxDB](https://github.com/influxdata/influxdb), [Chronograf](https://github.com/influxdata/chronograf) and [Kapacitor](https://github.com/influxdata/kapacitor) are known as the TICK Stack.

## Using this repository

* ### Telegraf

    1. Use the scripts in the [install-telegraf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-telegraf) modules to create a [machine image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) with Telegraf installed.

    1. Configure each application server to execute the [run-telegraf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-telegraf) script during boot.

* ### InfluxDB

    1. Use the scripts in the [install-influxdb](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-influxdb) modules to create a [machine image](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images) with InfluxDB Enterprise installed.

    1. Deploy the server across one or more [Instance Groups](https://cloud.google.com/compute/docs/instance-groups/) using the [tick-instance-group
module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/tick-instance-group).

    1. Configure each server in the Instance Groups to execute the [run-influxdb](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-influxdb) script during boot.

    1. Deploy a load balancer in front of the data node Instance Group.

* ### Chronograf

    1. Use the scripts in the [install-chronograf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-chronograf) modules to create a machine image with Chronograf installed.
1. Deploy the image in a single instance group using the [tick-instance-group
    module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/tick-instance-group).
1. Configure the server to execute the [run-chronograf](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/run-chronograf) script during boot.
1. Deploy a load balancer in front of the instance group.
    
* ### Kapacitor

    1. Use the scripts in the [install-kapacitor](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/install-kapacitor) modules to create a machine image with Kapacitor installed.
1. Deploy the image in a single instance group using the [tick-instance-group
    module](https://github.com/gruntwork-io/terraform-google-influx/tree/master/modules/tick-instance-group).
1. Configure the server to execute the [run-kapacitor](modules/run-kapacitor) script during boot.
    1. Deploy a load balancer in front of the instance group.


See the [examples folder](https://github.com/gruntwork-io/terraform-google-influx/tree/master/examples) for working sample code.
