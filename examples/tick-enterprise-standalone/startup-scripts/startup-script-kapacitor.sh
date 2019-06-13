#!/usr/bin/env bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-influxdb script to configure and start InfluxDB. This script assumes it's running in a Compute Instance based on a
# Google Image built from the Packer template in examples/machine-images/kapacitor/kapacitor.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

source "/opt/influxdb-commons/influxdb-common.sh"

function run {
  local -r influxdb_url="$1"
  local -r disk_device_name="$2"
  local -r disk_mount_point="$3"
  local -r disk_owner="$4"
  local -r hostname=$(get_node_hostname)

  mount_disk "$disk_device_name" "$disk_mount_point" "$disk_owner"

  "/opt/kapacitor/bin/run-kapacitor" \
    --auto-fill "<__HOST_NAME__>=$hostname" \
    --auto-fill "<__STORAGE_DIR__>=$disk_mount_point" \
    --auto-fill "<__INFLUXDB_URL__>=$influxdb_url"
}

run \
  "${influxdb_url}" \
  "${disk_device_name}" \
  "${disk_mount_point}" \
  "${disk_owner}"
