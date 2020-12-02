variable "hcloud_token" {
  type        = string
  description = "The Hetzner Cloud token used to authenticate against the Hetzner API."
}

variable "version" {
  type        = string
  description = "The version string for the ISO to use as a base image. Ignored if latest is set to true. Required if latest is set to false."
  default     = null
}

variable "latest" {
  type        = bool
  description = "Whether to use the latest ISO build as a base image."
  default     = true
}

source "hcloud" "vyos" {
  token = var.hcloud_token

  location     = "nbg1"
  server_type  = "cx11"
  server_name  = "packer-vyos"
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

locals {
  files_path = "/tmp/vyos-files"
}

build {
  sources = ["source.hcloud.vyos"]
  provisioner "file" {
    source      = "files"
    destination = local.files_path
  }
  provisioner "shell" {
    environment_vars = [
      "ISO_URL=https://downloads.vyos.io/rolling/current/amd64/vyos-${var.latest ? "rolling-latest" : var.version + "-amd64"}.iso",
      "FILES_PATH=${local.files_path}",
      "DEVICE=/dev/sda",
      "ISO_MOUNT_POINT=/mnt/iso",
      "BOOT_MOUNT_POINT=/mnt/boot",
      "PERSISTENCE_MOUNT_POINT=/mnt/disk",
      "SQUASH_MOUNT_POINT=/dev/squash",
      "OVERLAY_MOUNT_POINT=/mnt/vyos",
      
      # This avoids some annoying warnings when the local language is not
      # english.
      "LC_ALL=en_US.UTF-8"
    ]
    scripts = [
      "scripts/01-iso.sh",
      "scripts/02-partition.sh",
      "scripts/10-filesystem.sh",
      "scripts/15-overlay.sh",
      "scripts/20-config.sh",
      "scripts/21-grub.sh",
      "scripts/22-prepare-packages.sh",
      "scripts/23-cloud-init.sh",
      "scripts/24-qemu-guest-agent.sh",
      "scripts/30-cleanup-packages.sh",
      "scripts/31-cleanup.sh",
      "scripts/99-squash.sh"
    ]
  }
}