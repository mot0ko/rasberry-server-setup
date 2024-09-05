#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <device_name> <mount_name>"
  exit 1
fi

DEVICE_NAME=$1
MOUNT_NAME=$2
MOUNT_POINT="/mnt/$MOUNT_NAME"

# Create a mount point if it does not exist
if [ ! -d "$MOUNT_POINT" ]; then
  mkdir -p "$MOUNT_POINT"
fi

# Check the filesystem type of the device
FS_TYPE=$(blkid -o value -s TYPE "$DEVICE_NAME")

if [ -z "$FS_TYPE" ]; then
  echo "Unable to determine the filesystem type of $DEVICE_NAME."
  exit 1
fi

# Backup /etc/fstab before making changes
cp /etc/fstab /etc/fstab.bak

# Add an entry to /etc/fstab
echo "$DEVICE_NAME $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab

# Mount the device to verify the fstab entry
mount -a

# Provide feedback to the user
echo "Device '$DEVICE_NAME' has been configured to auto-mount at '$MOUNT_POINT' on boot."
