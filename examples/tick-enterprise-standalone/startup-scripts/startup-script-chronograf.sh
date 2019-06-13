#!/usr/bin/env bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-chronograf script to configure and start InfluxDB. This script assumes it's running in a Compute Instance based on a
# Google Image built from the Packer template in examples/machine-images/chronograf/chronograf.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

function run {
  local -r host="$1"
  local -r port="$2"

  "/opt/chronograf/bin/run-chronograf" \
    --auto-fill "<__HOST__>=$host" \
    --auto-fill "<__PORT__>=$port"
}

run \
  "${host}" \
  "${port}"
