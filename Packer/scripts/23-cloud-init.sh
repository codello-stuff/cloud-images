#!/usr/bin/env sh

set -eu

chroot "$OVERLAY_MOUNT_POINT" apt-get -t current install -y cloud-init cloud-utils

mkdir -p "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
chmod 755 "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
# TODO: Test whether this is needed or if cloud-init can successfully auto-detect the Hetzner environment
# Previous value: NoCloud,ConfigDrive,None
tee "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d/90_dpkg.cfg <<-EOF > /dev/null
datasource_list: [Hetzner, None]
EOF
chroot "$OVERLAY_MOUNT_POINT" dpkg-reconfigure -f noninteractive cloud-init
