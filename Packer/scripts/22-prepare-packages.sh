#!/usr/bin/env sh
set -eu

# In order to be able to resolve names inside the VyOS chroot we need to provide
# a /etc/resolv.conf file. We use the host's resolv.conf.

# Configure the nameservers of the rescue system temporarily
cp "$OVERLAY_MOUNT_POINT"/etc/resolv.conf /tmp/resolv.conf.bak
cp /etc/resolv.conf "$OVERLAY_MOUNT_POINT"/etc/resolv.conf
mv "$FILES_PATH"/debian.list "$OVERLAY_MOUNT_POINT"/etc/apt/sources.list.d/debian.list

chroot "$OVERLAY_MOUNT_POINT" apt-get update -y
