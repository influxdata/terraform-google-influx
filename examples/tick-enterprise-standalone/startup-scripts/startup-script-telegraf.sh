#!/usr/bin/env bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-telegraf script to configure and start InfluxDB. This script assumes it's running in a Compute Instance based on a
# Google Image built from the Packer template in examples/machine-images/telegraf/telegraf.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

function run {
  local -r influxdb_url="$1"
  local -r database_name="$2"

  # Allow some time for InfluxDB to start so Telegraf can successfully connect and create the database
  # This is to avoid intermittent failures in the automated tests
  sleep 30

  "/opt/telegraf/bin/run-telegraf" \
    --auto-fill "<__INFLUXDB_URL__>=$influxdb_url" \
    --auto-fill "<__DATABASE_NAME__>=$database_name"
}

run \
  "${influxdb_url}" \
  "${database_name}"
