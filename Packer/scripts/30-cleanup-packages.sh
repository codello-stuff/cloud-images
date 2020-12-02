#!/usr/bin/env sh

set -eu

chroot "$OVERLAY_MOUNT_POINT" apt-get clean -y
rm -rf "$OVERLAY_MOUNT_POINT"/var/lib/apt/lists/
rm -rf "$OVERLAY_MOUNT_POINT"/etc/apt/sources.list.d/debian.list
# Restore the original resolv.conf
cp /tmp/resolv.conf.bak "$OVERLAY_MOUNT_POINT"/etc/resolv.conf
