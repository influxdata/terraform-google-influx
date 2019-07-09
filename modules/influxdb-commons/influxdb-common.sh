#!/bin/bash

set -e

source "/opt/gruntwork/bash-commons/log.sh"

# Shorthand disk mount defaulting to ext4.
function mount_disk {
  local -r device_name="$1"
  local -r mount_point="$2"
  local -r owner="$3"

  # confirm fstab mounts are created before continuing
  mount -a

  # mount influxdb volume if it is not already mounted
  if [ ! -d "$mount_point" ]; then
    format_and_mount_disk "$device_name" "$mount_point" "$owner"
  fi
}

# Volume mount operations
function format_and_mount_disk() {
  local -r device_name="$1"
  local -r mount_dir="$2"
  local -r owner="$3"
  local -r filesystem="${4:-ext4}"

  # Validate the filesystem variable.
  # Currently supported: ext4 and xfs.
  if [[ ! ("${filesystem}" == "ext4" || "${filesystem}" == "xfs") ]]; then
    log_error "Error: unexpected filesystem: ${filesystem}. Expected ext4 or xfs."
    exit 1
  fi

  # Translate the disk's name to filesystem path.
  # If we map the disk with 'influxdb', it will be available in '/dev/disk/by-id/google-influxdb'
  # https://medium.com/@DazWilkin/compute-engine-identifying-your-devices-aeae6c01a4d7
  local -r disk_path="/dev/disk/by-id/google-${device_name}"

  # Create mount directory.
  mkdir -p "${mount_dir}"
  chmod 0755 "${mount_dir}"

  case "${filesystem}" in
    ext4)
      log_info "Format disk: mkfs.ext4 '${disk_path}'"
      mkfs.ext4 "${disk_path}"
    ;;
    xfs)
      # Formatting the disk with mkfs.xfs requires
      # the xfsprogs package to be installed.
      log_info "Format disk: mkfs.xfs '${disk_path}'"
      mkfs.xfs "${disk_path}"
    ;;
  esac

  # Try to mount disk after formatted it.
  log_info "Mount disk '${disk_path}'"
  mount -o discard,defaults -t "${filesystem}" "${disk_path}" "${mount_dir}"

  # Add an entry to /etc/fstab to mount the disk on restart.
  echo "${disk_path} ${mount_dir} ${filesystem} discard,defaults 0 2" \
    >> /etc/fstab

  log_info "Changing ownership of $mount_dir to $owner..."
  chown -R "$owner" "$mount_dir"
}

# Metadata operations
function get_metadata_value() {
  curl --retry 5 \
    -s \
    -f \
    -H "Metadata-Flavor: Google" \
    "http://metadata/computeMetadata/v1/$1"
}

# This method is used to retrieve the hostname of the instance
function get_node_hostname {
  get_metadata_value "instance/hostname"
}

# This method is used to retrieve the private ip of the instance
function get_node_private_ip {
  get_metadata_value "instance/network-interfaces/0/ip"
}

# This method is used to retrieve the private ip of the (alphabetically) first instance in an Instance Group
function gcp_first_instance_ip_in_managed_instance_group {
  local -r instance_group_name="$1"
  local -r region="$2"

  local response

  response=$(gcloud compute instance-groups managed list-instances "$instance_group_name" --region="$region" --sort-by=id --limit=1 --uri | tr -d '\n')
  response=$(gcloud compute instances describe "$response" --format="value(networkInterfaces[0].networkIP)" | tr -d '\n')

  echo -n "$response"
}

