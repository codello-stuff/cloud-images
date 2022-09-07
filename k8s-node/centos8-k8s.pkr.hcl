variable "k8s_version" {
  type = string
  default = "1.19.6"
  description = "The Kubernetes version to install."
}

variable "crio_version" {
  type = string
  default = null
  description = "The cri-o version. Defaults to major.minor of the Kubernetes version."
}

variable "crictl_patch" {
  type = number
  default = 0
  description = "The patch version of crictl. major and minor defaults to the equivalent Kubernetes version."
}

variable "crictl_version" {
  type = string
  default = null
  description = "The cri-tools version. Defaults to Kubernetes major.minor and crictl_patch patch version."
}

locals {
  crio_version = "${var.crio_version != null ? var.crio_version : join(".", slice(split(".", var.k8s_version), 0, 2))}"
  crictl_version = "${var.crictl_version != null ? var.crictl_version : format("%s.%d", local.crio_version, var.crictl_patch)}"
}

build {
  sources = ["source.hcloud.centos-k8s"]
  provisioner "file" {
    source = "system/dnf-automatic.conf"
    destination = "/tmp/dnf-automatic.conf"
  }
  provisioner "shell" {
    scripts = [
      "system/init.sh",
      "system/automatic-updates.sh",
      "k8s/crio.sh",
      "k8s/crictl.sh",
      "k8s/install.sh",
      "k8s/cleanup.sh",
      "system/finalize.sh"
    ]
    environment_vars = [
      "K8S_VERSION=${var.k8s_version}",
      "CRIO_VERSION=${local.crio_version}",
      "CRICTL_VERSION=${local.crictl_version}"
    ]
  }
}
