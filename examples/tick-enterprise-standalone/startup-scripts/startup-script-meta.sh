#!/usr/bin/env bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-influxdb script to configure and start InfluxDB. This script assumes it's running in a Compute Instance based on a
# Google Image built from the Packer template in examples/machine-images/influxdb-enterprise/influxdb-enterprise.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

source "/opt/influxdb-commons/influxdb-common.sh"

function run {
  local -r meta_group_name="$1"
  local -r region="$2"
  local -r license_key="$3"
  local -r shared_secret="$4"
  local -r disk_device_name="$5"
  local -r disk_mount_point="$6"
  local -r disk_owner="$7"
  local -r hostname=$(get_node_hostname)
  local -r private_ip=$(get_node_private_ip)

  mount_disk "$disk_device_name" "$disk_mount_point" "$disk_owner"

  local -r meta_dir="$disk_mount_point/var/lib/influxdb/meta"

  "/opt/influxdb/bin/run-influxdb-enterprise" \
    --hostname "$hostname" \
    --private-ip "$private_ip" \
    --node-type "meta" \
    --meta-group-name "$meta_group_name" \
    --region "$region" \
    --auto-fill "<__HOST_NAME__>=$hostname" \
    --auto-fill "<__LICENSE_KEY__>=$license_key" \
    --auto-fill "<__SHARED_SECRET__>=$shared_secret" \
    --auto-fill "<__META_DIR__>=$meta_dir"
}

run \
  "${meta_group_name}" \
  "${region}" \
  "${license_key}" \
  "${shared_secret}" \
  "${disk_device_name}" \
  "${disk_mount_point}" \
  "${disk_owner}"
