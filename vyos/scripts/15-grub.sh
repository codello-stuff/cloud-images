#!/usr/bin/env sh
set -eu

# This script install the GRUB bootloader for VyOS. The boot loader is installed
# into /boot and /boot/efi respectively. GRUB is configured to only show a
# single boot option.

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

version=$(cat "$SQUASH_MOUNT_POINT/opt/vyatta/etc/version" | awk '{print $2}' | tr + -)
tee "$DISK_MOUNT_POINT/boot/grub/grub.cfg" <<-EOF > /dev/null
set default=0
set timeout=5
serial --unit=0
terminal_output --append serial
terminal_input serial console
insmod efi_gop
insmod efi_uga

menuentry "VyOS $version" {
	linux /boot/$version/vmlinuz boot=live rootdelay=5 noautologin net.ifnames=0 biosdevname=0 vyos-union=/boot/$version console=ttyS0 console=tty0
	initrd /boot/$version/initrd.img
}
EOF
chmod 644 "$DISK_MOUNT_POINT"/boot/grub/grub.cfg

umount "$OVERLAY_MOUNT_POINT"/boot/efi
rmdir "$OVERLAY_MOUNT_POINT"/boot/efi
