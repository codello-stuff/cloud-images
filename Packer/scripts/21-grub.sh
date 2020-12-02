#!/usr/bin/env sh

set -eu

mkdir -p "$OVERLAY_MOUNT_POINT"/boot/efi
mount --bind "$BOOT_MOUNT_POINT" "$OVERLAY_MOUNT_POINT"/boot/efi

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
export MAIN_VERSION=$(echo "$VERSION" | cut -d '-' -f 1)
cat "$FILES_PATH"/grub.cfg | envsubst > "$PERSISTENCE_MOUNT_POINT"/boot/grub/grub.cfg
chmod 644 "$PERSISTENCE_MOUNT_POINT"/boot/grub/grub.cfg

umount "$OVERLAY_MOUNT_POINT"/boot/efi
