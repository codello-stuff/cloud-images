#!/usr/bin/env sh
set -eu

# This script creates and mounts the base filesystem of VyOS so that we can
# install additional software (such as the boot loader). The VyOS filesystem
# works like this:
# - A readonly squashfs file system forms the immutable base of the system. The
#   image resides on the main partition.
# - A read-write filesystem is overlayed on top of the squashfs system to allow
#   changes. The overlay is mounted at / so that the actual partition's file
#   system is hidden.
# - The actual partition's file system is mounted at /boot inside the overlay
#   (e.g. to be able to install the boot loader).
# - /dev, /proc, and /sys are mounted into the overlay so that chroot works.

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

# The following system directories are required for chroot to work. Without
# these there are a lot of strange errors.
mount --bind /dev "$OVERLAY_MOUNT_POINT"/dev
mount --bind /proc "$OVERLAY_MOUNT_POINT"/proc
mount --bind /sys "$OVERLAY_MOUNT_POINT"/sys
mount --bind "$DISK_MOUNT_POINT" "$OVERLAY_MOUNT_POINT"/boot
