variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "homelab"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL (e.g., https://192.168.1.100:6443)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "v1.34.1"
}

variable "talos_version" {
  description = "Talos OS version"
  type        = string
  default     = "v1.11.5"
}

variable "image_schematic" {
  description = "Talos image schematic ID (for custom extensions like qemu-guest-agent)"
  type        = string
  default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "controlplane_nodes" {
  description = "Map of control plane nodes with their configuration"
  type = map(object({
    ip           = string
    hostname     = string
    install_disk = string
  }))
  default = {}
}

variable "worker_nodes" {
  description = "Map of worker nodes with their configuration"
  type = map(object({
    ip           = string
    hostname     = string
    install_disk = string
  }))
  default = {}
}

variable "allow_scheduling_on_control_planes" {
  description = "Allow workloads to run on control plane nodes"
  type        = bool
  default     = true
}
