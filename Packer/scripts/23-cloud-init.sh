#!/usr/bin/env sh
set -eu

# In order to leverage Hetzner's User-Data feature we need to install
# cloud-init. VyOS provides a custom implementation that can configure a VyOS
# system correctly (using the VyOS config file).

chroot "$OVERLAY_MOUNT_POINT" apt-get -t current install -y cloud-init cloud-utils

mkdir -p "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
chmod 755 "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
tee "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d/90_dpkg.cfg <<-EOF > /dev/null
datasource_list: [Hetzner, None]
EOF
chroot "$OVERLAY_MOUNT_POINT" dpkg-reconfigure -f noninteractive cloud-init
