#!/usr/bin/env sh

set -eu

fstrim "$OVERLAY_MOUNT_POINT"/boot
fstrim "$PERSISTENCE_MOUNT_POINT"

umount "$OVERLAY_MOUNT_POINT"/dev
umount "$OVERLAY_MOUNT_POINT"/proc
umount "$OVERLAY_MOUNT_POINT"/sys
