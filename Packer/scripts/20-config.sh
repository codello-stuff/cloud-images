#!/usr/bin/env sh

set -eu

# Install english language
chroot "$OVERLAY_MOUNT_POINT" sed -i '/^# en_US.UTF-8 UTF-8$/s/^# //' /etc/locale.gen
chroot "$OVERLAY_MOUNT_POINT" locale-gen

touch "$OVERLAY_MOUNT_POINT"/opt/vyatta/etc/config/.vyatta_config

mv "$FILES_PATH"/config.boot "$OVERLAY_MOUNT_POINT"/opt/vyatta/etc/config/config.boot
chmod 755 "$OVERLAY_MOUNT_POINT"/opt/vyatta/etc/config/config.boot

mv "$FILES_PATH"/persistence.conf "$DISK_MOUNT_POINT"/persistence.conf
chmod 644 "$DISK_MOUNT_POINT"/persistence.conf
