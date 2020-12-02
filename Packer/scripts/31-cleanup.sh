#!/usr/bin/env sh

set -eu

fstrim "$OVERLAY_MOUNT_POINT"/boot
fstrim "$DISK_MOUNT_POINT"

umount "$OVERLAY_MOUNT_POINT"/boot
umount "$OVERLAY_MOUNT_POINT"/sys
umount "$OVERLAY_MOUNT_POINT"/proc
umount "$OVERLAY_MOUNT_POINT"/dev

umount "$OVERLAY_MOUNT_POINT" && rmdir "$OVERLAY_MOUNT_POINT"
umount "$SQUASH_MOUNT_POINT" && rmdir "$SQUASH_MOUNT_POINT"
umount "$DISK_MOUNT_POINT" && rmdir "$DISK_MOUNT_POINT"
umount "$EFI_MOUNT_POINT" && rmdir "$EFI_MOUNT_POINT"
umount "$ISO_MOUNT_POINT" && rmdir "$ISO_MOUNT_POINT"
