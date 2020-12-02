#!/usr/bin/env sh

set -eu

chroot "$OVERLAY_MOUNT_POINT" apt-get -t current install -y qemu-guest-agent
