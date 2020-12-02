#!/usr/bin/env sh

set -eu

version=$(cat "$SQUASH_MOUNT_POINT/opt/vyatta/etc/version" | awk '{print $2}' | tr + -)
dest="$PERSISTENCE_MOUNT_POINT"/boot/"$version"/"$version".squashfs

# Since we do not run in a chroot all absolute symlinks
mksquashfs "$OVERLAY_MOUNT_POINT" "$dest" -progress -comp gzip -Xcompression-level 9 -e "$OVERLAY_MOUNT_POINT"/boot
mksquashfs "$SQUASH_MOUNT_POINT"/boot "$dest" -keep-as-directory -progress -comp gzip -Xcompression-level 9
