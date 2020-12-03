# TODO: Test write-files module to declaratively overwrite the complete configuration.

# Creates a cloud-init enabled base image for VyOS on Hetzner Cloud.
#
#         VyOS - Open source router and firewall platform:
#                         https://vyos.io
#
#                          Hetzner Cloud
#                   https://www.hetzner.com/cloud
#
# by @codello

# This Packer template creates a VyOS image on Hetzner Cloud. The resulting
# image is almost equivalent to a server you would get by manually installing
# from the official ISO source.
# The steps taken to automatically install VyOS are inspired by the official
# Ansible scripts: https://github.com/vyos/vyos-vm-images
# 
# There are however some modifications made:
# - Separate BIOS and EFI partitions are created. The official ISO creates a
#   single partition by default.
# - Only a single Grub configuration is created. Password reset is not enabled
#   by default.
# - Cloud-init is installed, enabled and configured to be used with Hetzner
#   Cloud. Instead of the official cloud-init distribution the vyos-specific one
#   is used: https://github.com/vyos/vyos-cloud-init
# - The QEMU Guest agent is installed.
# - A default configuration without any users is provided. The default vyos user
#   will be created by cloud-config using the provided SSH key.
#
# WARNING: Provisioning a VyOS server using username/password is not currently
#          supported. If you do not specify a SSH key or your own cloud-config
#          user configuration a default user 'vyos' with password 'vyos' will be
#          created. The password received via E-Mail will not be valid.

variable "hcloud_token" {
  type        = string
  description = "The Hetzner Cloud token used to authenticate against the Hetzner API."
}

variable "version" {
  type        = string
  description = "The version string for the ISO to use as a base image. Set to the special value \"latest\" to automatically choose the latest version."
  default     = "latest"
}

source "hcloud" "vyos" {
  token = var.hcloud_token

  location     = "nbg1"
  server_type  = "cx11"
  server_name  = "packer-vyos-{{ timestamp }}"
  ssh_username = "root"
  
  image  = "centos-8"
  rescue = "linux64"

  snapshot_name = "VyOS 1.3"
  snapshot_labels = {
    os = "vyos"
    os_version = "1.3"
    build = formatdate("YYYY-MM-DD", timestamp())
  }
}

build {
  sources = ["source.hcloud.vyos"]
  provisioner "shell" {
    environment_vars = [
      # The VyOS ISO image used to install VyOS.
      "ISO_URL=https://downloads.vyos.io/rolling/current/amd64/vyos-${var.version == "latest" ? "rolling-latest" : var.version + "-amd64"}.iso",
      # The device on which VyOS is installed.
      "DEVICE=/dev/sda",
      # The mount point of the ISO image.
      "ISO_MOUNT_POINT=/mnt/iso",
      # The mount point of the base file system. Note that this is not the
      # filesystem you are seeing when logging into a VyOS system.
      "DISK_MOUNT_POINT=/mnt/disk",
      # The mount point of the EFI partition.
      "EFI_MOUNT_POINT=/mnt/efi",
      # The mount point of the read-only VyOS filesystem.
      "SQUASH_MOUNT_POINT=/dev/squash",
      # The mount point of the read-write VyOS filesystem. This is the
      # filesystem you are seeing in a live VyOS system.
      "OVERLAY_MOUNT_POINT=/mnt/vyos",
      # The base language. Setting this as LC_ALL avoids some annoying warnings
      # when the local language is not english.
      "LC_ALL=en_US.UTF-8"
    ]
    # See the documentation on each of the scripts for details.
    scripts = [
      "scripts/01-iso.sh",
      "scripts/02-partition.sh",
      "scripts/10-filesystem.sh",
      "scripts/15-grub.sh",
      "scripts/20-config.sh",
      "scripts/22-prepare-packages.sh",
      "scripts/23-cloud-init.sh",
      "scripts/24-qemu-guest-agent.sh",
      "scripts/30-cleanup-packages.sh",
      "scripts/31-cleanup.sh"
    ]
  }
}
