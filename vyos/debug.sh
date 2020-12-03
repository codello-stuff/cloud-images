#!/bin/bash

VERSION=1.3-rolling-202011291251

apt-get install -y squashfuse fuse-overlayfs

mkdir /mnt/disk /mnt/squash /mnt/tmp /mnt/vyos
mount /dev/sda3 /mnt/disk
mount -t tmpfs none /mnt/tmp
mkdir /mnt/tmp/rw /mnt/tmp/work

squashfuse /mnt/disk/boot/$VERSION/$VERSION.squashfs /mnt/squash
fuse-overlayfs -o lowerdir=/mnt/squash -o upperdir=/mnt/tmp/rw -o workdir=/mnt/tmp/work /mnt/vyos
mount --bind /dev /mnt/vyos/dev
mount --bind /proc /mnt/vyos/proc
mount --bind /sys /mnt/vyos/sys
mount --bind /mnt/disk /mnt/vyos/boot
