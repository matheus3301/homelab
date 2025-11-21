variable "proxmox_api_url" {
  description = "The URL of the Proxmox API"
  type        = string
}

variable "target_node" {
  description = "The name of the Proxmox node where VMs will be created"
  type        = string
}

variable "talos_node_count" {
  description = "Number of Talos OS nodes to create"
  type        = number
}

variable "talos_cpu_cores" {
  description = "Number of CPU cores per Talos node"
  type        = number
}

variable "talos_cpu_sockets" {
  description = "Number of CPU sockets per Talos node"
  type        = number
}

variable "talos_memory" {
  description = "Amount of memory in MB per Talos node"
  type        = number
}

variable "talos_disk_size" {
  description = "Disk size for Talos nodes (e.g., '32G')"
  type        = string
}

variable "talos_storage" {
  description = "Proxmox storage pool for Talos node disks"
  type        = string
}

variable "talos_iso" {
  description = "Path to Talos OS ISO in Proxmox storage"
  type        = string
}

variable "talos_network_bridge" {
  description = "Network bridge for Talos nodes"
  type        = string
}
