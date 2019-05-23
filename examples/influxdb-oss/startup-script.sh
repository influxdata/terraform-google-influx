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
  local -r disk_mount_point="$1"
  local -r disk_owner="$2"

  mount_disk "$disk_mount_point" "$disk_owner"

  local -r meta_dir="$disk_mount_point/var/lib/influxdb/meta"
  local -r data_dir="$disk_mount_point/var/lib/influxdb/data"
  local -r wal_dir="$disk_mount_point/var/lib/influxdb/wal"

  "/opt/influxdb/bin/run-influxdb-oss" \
    --auto-fill "<__META_DIR__>=$meta_dir" \
    --auto-fill "<__DATA_DIR__>=$data_dir" \
    --auto-fill "<__WAL_DIR__>=$wal_dir"
}

run \
  "${disk_mount_point}" \
  "${disk_owner}"
