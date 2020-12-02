#!/usr/bin/env sh

set -eu

# We will create three partitions:
# - An empty BIOS partition (otherwise GRUB complains)
# - An EFI partition
# - A Linux Filesystem partition
# Currently Hetzner Cloud only uses BIOS boots so the EFI partition is pretty
# useless.
sgdisk --zap-all \
       --set-alignment=1 \
       --new=1:34:2047 \
       --typecode=1:EF02 \
       --change-name=1:"BIOS boot partition" \
       --new=2:2048:+256M \
       --typecode=2:EF00 \
       --change-name=2:"EFI System" \
       --largest-new=3 \
       --typecode=3:8300 \
       --change-name=3:"Linux filesystem" \
       "$DEVICE"

efi_partition=$(fdisk -l -oDevice "$DEVICE" | grep '^/dev' | sed -n 2p)
data_partition=$(fdisk -l -oDevice "$DEVICE" | grep '^/dev' | sed -n 3p)

mkfs.vfat -n EFI -F 32 -s 1 "$efi_partition"
mkfs.ext4 -FL persistence "$data_partition"

mkdir -p "$DISK_MOUNT_POINT" "$EFI_MOUNT_POINT"
mount -t vfat "$efi_partition" "$EFI_MOUNT_POINT"
mount -t ext4 "$data_partition" "$DISK_MOUNT_POINT"
