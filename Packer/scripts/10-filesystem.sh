#!/usr/bin/env sh

set -eu

apt-get install -y squashfuse squashfs-tools

mkdir -p "$SQUASH_MOUNT_POINT"
squashfuse "$ISO_MOUNT_POINT/live/filesystem.squashfs" "$SQUASH_MOUNT_POINT"

version=$(cat "$SQUASH_MOUNT_POINT/opt/vyatta/etc/version" | awk '{print $2}' | tr + -)
dest="$PERSISTENCE_MOUNT_POINT/boot/$version/"
mkdir -p "$dest"
find "$SQUASH_MOUNT_POINT/boot" -maxdepth 1 \( -type f -o -type l \) -print -exec cp -dp {} "$dest" \;
