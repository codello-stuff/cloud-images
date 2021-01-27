#!/usr/bin/env sh
set -eu

# In order to leverage Hetzner's User-Data feature we need to install
# cloud-init. VyOS provides a custom implementation that can configure a VyOS
# system correctly (using the VyOS config file).

# In addition to the default cloud-init capabilities we perform some
# modifications to support vbash scripts.

chroot "$OVERLAY_MOUNT_POINT" apt-get -t current install -y cloud-init cloud-utils

mkdir -p "$OVERLAY_MOUNT_POINT/etc/systemd/system/cloud-final.service.d"
tee "$OVERLAY_MOUNT_POINT/etc/systemd/system/cloud-final.service.d/override.conf" <<-EOF > /dev/null
[Unit]
After=vyos.target

[Service]
ExecStartPre=sh -c 'until test -f /tmp/vyos-config-status; do sleep 1; done'
EOF
chmod 644 "$OVERLAY_MOUNT_POINT/etc/systemd/system/cloud-final.service.d/override.conf"

mkdir -p "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
chmod 755 "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d
tee "$OVERLAY_MOUNT_POINT"/etc/cloud/cloud.cfg.d/90_custom.cfg <<-EOF > /dev/null
cloud_config_modules:
  - vyos
  - write_files
  - runcmd
  - vyos_userdata

cloud_final_modules:
  - scripts_user
EOF
chroot "$OVERLAY_MOUNT_POINT" dpkg-reconfigure -f noninteractive cloud-init
