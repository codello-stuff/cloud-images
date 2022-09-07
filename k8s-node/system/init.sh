#!/usr/bin/env sh

set -e

# Set the system language.
cat <<-EOF | sudo tee /etc/environment >/dev/null
	LANG=en_US.utf-8
	LC_ALL=en_US.utf-8
EOF

# Configure Sudo
cat <<-EOF | sudo tee /etc/sudoers.d/10-wheel >/dev/null
	%wheel ALL=(ALL) NOPASSWD:ALL
EOF
sudo chmod 440 /etc/sudoers.d/10-wheel

# Update existing packages
sudo yum update -y

# Swap is already off by default on Hetzner Cloud

# TODO: Install and setup firewall
#yum install -y firewalld
