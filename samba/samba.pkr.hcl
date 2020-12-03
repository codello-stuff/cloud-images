variable "hcloud_token" {
  type        = string
  descriptipn = "The token used to authenticate to the Hetzner Cloud API"
}

variable "samba_version" {
  type = string
  default = "4.13.0"
}

source "hcloud" "centos-samba" {
  token = var.hcloud_token
  image = "centos-8"
  location = "nbg1"
  server_type = "cx11"
  server_name = "centos8-samba-${var.samba_version}"
  ssh_username = "root"

  snapshot_name = "Samba DC"
  snapshot_labels = {
    os = "centos"
    os_version = "8"
    samba_version = var.samba_version
  }
}

# TODO: Probably enable automatic updates???
build {
  sources = ["source.hcloud.centos-samba"]
  provisioner "shell" {
    script = "dependencies-${var.samba_version}.sh"
  }
  provisioner "shell" {
    inline = [
      "yum install -y langpacks-en langpacks-de glibc-all-langpacks",
      "yum clean all"
    ]
  }
  provisioner "shell" {
    inline = [
      "curl -fSL https://download.samba.org/pub/samba/stable/samba-${var.samba_version}.tar.gz | tar -xz",
      "cd samba-${var.samba_version}",
      "./configure -j2 --enable-fhs --prefix=/usr --sysconfdir=/etc --localstatedir=/var",
      "make -j2",
      "make install",
      "cd ..",
      "rm -rf samba-${var.samba_version}"
    ]
  }
  provisioner "file" {
    source = "samba.service"
    destination = "/etc/systemd/system/samba.service"
  }
  provisioner "shell" {
    inline = [
      "systemctl daemon-reload",
      "systemctl enable samba"
    ]
  }
}
