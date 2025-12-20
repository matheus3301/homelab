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

# TrueNAS VM Variables
variable "truenas_cpu_cores" {
  description = "Number of CPU cores for TrueNAS VM"
  type        = number
  default     = 4
}

variable "truenas_memory" {
  description = "Amount of memory in MB for TrueNAS VM (minimum 8192 recommended)"
  type        = number
  default     = 16384
}

variable "truenas_boot_disk_size" {
  description = "Boot disk size for TrueNAS OS (e.g., '32G')"
  type        = string
  default     = "32G"
}

variable "truenas_storage" {
  description = "Proxmox storage pool for TrueNAS boot disk"
  type        = string
}

variable "truenas_iso" {
  description = "Path to TrueNAS ISO in Proxmox storage (e.g., 'local:iso/TrueNAS-SCALE-25.10.0.1.iso')"
  type        = string
}

variable "truenas_network_bridge" {
  description = "Network bridge for TrueNAS VM"
  type        = string
  default     = "vmbr0"
}

variable "truenas_nvme_pcie_id" {
  description = "PCIe address of NVMe drive for passthrough. Get with: lspci -nn | grep -i nvme"
  type        = string
}
