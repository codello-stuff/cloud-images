#!/usr/bin/env sh
set -eu

# In order to be able to resolve names inside the VyOS chroot we need to provide
# a /etc/resolv.conf file. We use the host's resolv.conf.

# Configure the nameservers of the rescue system temporarily
cp "$OVERLAY_MOUNT_POINT"/etc/resolv.conf /tmp/resolv.conf.bak
cp /etc/resolv.conf "$OVERLAY_MOUNT_POINT"/etc/resolv.conf
tee "$OVERLAY_MOUNT_POINT/etc/apt/sources.list.d/debian.list" <<-EOF > /dev/null
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free
deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free
deb http://dev.packages.vyos.net/repositories/current current main
EOF

chroot "$OVERLAY_MOUNT_POINT" apt-get update -y
