#!/usr/bin/env sh

set -eu

ISO_PATH=/tmp/vyos.iso

# Download & verify ISO
curl -fsSLo "$ISO_PATH" "$ISO_URL"
curl -fsSL "$ISO_URL.sha256" | awk -v r="$ISO_PATH" '{$2=r}1' | sha256sum --check - --strict --quiet

# Mount the ISO
mkdir -p "$ISO_MOUNT_POINT"
mount -t iso9660 -o ro "$ISO_PATH" "$ISO_MOUNT_POINT"

# Verify ISO contents
cat "$ISO_MOUNT_POINT"/md5sum.txt | awk -v r=/mnt/iso '/^#/{print;next}{sub(/^./,r,$2)}1' | md5sum --check - --strict --quiet
