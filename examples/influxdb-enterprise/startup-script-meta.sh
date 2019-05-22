#!/usr/bin/env bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-influxdb script to configure and start InfluxDB. This script assumes it's running in a Compute Instance based on a
# Google Image built from the Packer template in examples/influxdb-image/influxdb.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

source "/opt/influxdb-commons/influxdb-common.sh"

function mount_disk {
  local -r mount_point="$1"
  local -r owner="$2"

  # confirm fstab mounts are created before continuing
  mount -a

  # mount influxdb volume if it is not already mounted
  if [ ! -d "$mount_point" ]; then
    format_and_mount_disk "$mount_point" "$owner"
  fi
}

function run {
  local -r meta_group_name="$1"
  local -r region="$2"
  local -r license_key="$3"
  local -r shared_secret="$4"
  local -r disk_mount_point="$5"
  local -r disk_owner="$6"
  local -r hostname=$(get_node_hostname)
  local -r private_ip=$(get_node_private_ip)

  mount_disk "$disk_mount_point" "$disk_owner"

  local -r meta_dir="$disk_mount_point/var/lib/influxdb/meta"
  local -r data_dir="$disk_mount_point/var/lib/influxdb/data"
  local -r wal_dir="$disk_mount_point/var/lib/influxdb/wal"
  local -r hh_dir="$disk_mount_point/var/lib/influxdb/hh"

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
  "${disk_mount_point}" \
  "${disk_owner}"
