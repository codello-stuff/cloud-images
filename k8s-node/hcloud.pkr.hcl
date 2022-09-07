variable "hcloud_token" {
  type = string
  sensitive = true
}

source "hcloud" "centos-k8s" {
  token = var.hcloud_token
  image = "centos-8"
  location = "nbg1"
  server_type = "cx11"
  server_name = "centos8-kubernetes"

  snapshot_name = "Kubernetes on CentOS 8"
  snapshot_labels = {
    os = "centos"
    os-version = "8"
    kubernetes = ""
    kubernetes-version = var.k8s_version
    build = formatdate("YYYY-MM-DD", timestamp())
  }
  ssh_username = "root"
}
