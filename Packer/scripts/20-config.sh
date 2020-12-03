#!/usr/bin/env sh
set -eu

# This script performs the following configuration:
# - Language & locale settings
# - The default VyOS configuration
# - A boot persistence configuration

# Install english language
chroot "$OVERLAY_MOUNT_POINT" sed -i '/^# en_US.UTF-8 UTF-8$/s/^# //' /etc/locale.gen
chroot "$OVERLAY_MOUNT_POINT" locale-gen

tee "$DISK_MOUNT_POINT/persistence.conf" <<-EOF > /dev/null
/ union
EOF
chmod 644 "$DISK_MOUNT_POINT"/persistence.conf

touch "$OVERLAY_MOUNT_POINT"/opt/vyatta/etc/config/.vyatta_config

# The following configuration intentionally excludes the following items because
# they are set by cloud-init (even if the user did not supply any init-data).
# - system host-name
# - system users
# - interfaces ethernet eth0
# - service ssh
tee "$OVERLAY_MOUNT_POINT/opt/vyatta/etc/config/config.boot" <<-EOF > /dev/null
system {
	syslog {
		global {
			facility all {
				level notice
			}
			facility protocols {
				level debug
			}
		}
	}
	ntp {
		server "0.pool.ntp.org"
		server "1.pool.ntp.org"
		server "2.pool.ntp.org"
	}
}

interfaces {
	loopback lo {
	}
}
EOF
chmod 755 "$OVERLAY_MOUNT_POINT"/opt/vyatta/etc/config/config.boot
