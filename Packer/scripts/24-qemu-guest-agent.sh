#!/usr/bin/env sh
set -eu

# We want to install the QEMU guest agent if it is not already present.

chroot "$OVERLAY_MOUNT_POINT" apt-get -t current install -y qemu-guest-agent
