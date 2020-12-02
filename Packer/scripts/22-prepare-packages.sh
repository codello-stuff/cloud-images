#!/usr/bin/env sh

set -eu

# Configure the nameservers of the rescue system temporarily
cp "$OVERLAY_MOUNT_POINT"/etc/resolv.conf /tmp/resolv.conf.bak
cp /etc/resolv.conf "$OVERLAY_MOUNT_POINT"/etc/resolv.conf
mv "$FILES_PATH"/debian.list "$OVERLAY_MOUNT_POINT"/etc/apt/sources.list.d/debian.list

chroot "$OVERLAY_MOUNT_POINT" apt-get update -y
