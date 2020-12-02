#!/usr/bin/env sh

set -eu

apt-get install -y squashfuse fuse-overlayfs

mkdir -p "$SQUASH_MOUNT_POINT"
squashfuse "$ISO_MOUNT_POINT/live/filesystem.squashfs" "$SQUASH_MOUNT_POINT"

version=$(cat "$SQUASH_MOUNT_POINT/opt/vyatta/etc/version" | awk '{print $2}' | tr + -)
dest="$DISK_MOUNT_POINT/boot/$version/"

mkdir -p "$dest" "$dest/grub" "$dest/rw" "$dest/work" "$OVERLAY_MOUNT_POINT"

find "$SQUASH_MOUNT_POINT/boot" -maxdepth 1 \( -type f -o -type l \) -print -exec cp -dp {} "$dest" \;
cp "$ISO_MOUNT_POINT/live/filesystem.squashfs" "$dest/$version.squashfs"

fuse-overlayfs -o lowerdir="$SQUASH_MOUNT_POINT" \
               -o upperdir="$dest/rw" \
               -o workdir="$dest/work" \
               "$OVERLAY_MOUNT_POINT"

mount --bind /dev "$OVERLAY_MOUNT_POINT"/dev
mount --bind /proc "$OVERLAY_MOUNT_POINT"/proc
mount --bind /sys "$OVERLAY_MOUNT_POINT"/sys
mount --bind "$DISK_MOUNT_POINT" "$OVERLAY_MOUNT_POINT"/boot
