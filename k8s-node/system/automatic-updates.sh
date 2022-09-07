#!/usr/bin/env sh

set -e

DESTINATION=/etc/dnf/automatic.conf

sudo yum install -y dnf-automatic
sudo mv /tmp/dnf-automatic.conf "$DESTINATION"
sudo chown root:root "$DESTINATION"
sudo chmod 644 "$DESTINATION"
sudo systemctl enable --now dnf-automatic.timer
