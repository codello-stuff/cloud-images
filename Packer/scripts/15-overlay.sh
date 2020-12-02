#!/usr/bin/env sh

set -eu

apt-get install -y fuse-overlayfs

tmp_mount_point=/mnt/tmp
mkdir -p "$tmp_mount_point"
mount -t tmpfs none "$tmp_mount_point"
upperdir="$tmp_mount_point"/rw
workdir="$tmp_mount_point"/work

mkdir -p "$upperdir" "$workdir" "$OVERLAY_MOUNT_POINT"
fuse-overlayfs -o lowerdir="$SQUASH_MOUNT_POINT" \
               -o upperdir="$upperdir" \
               -o workdir="$workdir" \
               "$OVERLAY_MOUNT_POINT"

mount --bind /dev "$OVERLAY_MOUNT_POINT"/dev
mount --bind /proc "$OVERLAY_MOUNT_POINT"/proc
mount --bind /sys "$OVERLAY_MOUNT_POINT"/sys
mount --bind "$PERSISTENCE_MOUNT_POINT" "$OVERLAY_MOUNT_POINT"/boot
