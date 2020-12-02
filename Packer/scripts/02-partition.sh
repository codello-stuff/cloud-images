#!/usr/bin/env sh

set -eu

sgdisk -Z -a1 -n1:34:2047 -t1:EF02 -n2:2048:+256M -t2:EF00 -n3:0:0:+100% -t3:8300 "$DEVICE"
boot_partition=$(fdisk -l -oDevice "$DEVICE" | grep '^/dev' | sed -n 2p)
data_partition=$(fdisk -l -oDevice "$DEVICE" | grep '^/dev' | sed -n 3p)

mkfs.vfat -n EFI -F 32 -s 1 "$boot_partition"
mkfs.ext4 -FL persistence "$data_partition"

mkdir -p "$BOOT_MOUNT_POINT" "$PERSISTENCE_MOUNT_POINT"
mount -t vfat "$boot_partition" "$BOOT_MOUNT_POINT"
mount -t ext4 "$data_partition" "$PERSISTENCE_MOUNT_POINT"
