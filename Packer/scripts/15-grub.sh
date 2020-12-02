#!/usr/bin/env sh

set -eu

mkdir -p "$OVERLAY_MOUNT_POINT"/boot/efi
mount --bind "$EFI_MOUNT_POINT" "$OVERLAY_MOUNT_POINT"/boot/efi

chroot "$OVERLAY_MOUNT_POINT" grub-install --no-floppy \
                                           --target=i386-pc \
                                           --root-directory=/boot \
                                           "$DEVICE"
chroot "$OVERLAY_MOUNT_POINT" grub-install --no-floppy \
                                           --recheck \
                                           --target=x86_64-efi \
                                           --force-extra-removable \
                                           --root-directory=/boot \
                                           --efi-directory=/boot/efi \
                                           --bootloader-id='VyOS' \
                                           --no-uefi-secure-boot

export VERSION=$(cat "$SQUASH_MOUNT_POINT/opt/vyatta/etc/version" | awk '{print $2}' | tr + -)
cat "$FILES_PATH"/grub.cfg | envsubst > "$DISK_MOUNT_POINT"/boot/grub/grub.cfg
chmod 644 "$DISK_MOUNT_POINT"/boot/grub/grub.cfg

umount "$OVERLAY_MOUNT_POINT"/boot/efi
rmdir "$OVERLAY_MOUNT_POINT"/boot/efi
