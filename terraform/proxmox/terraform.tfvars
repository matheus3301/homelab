proxmox_api_url = "https://192.168.0.100:8006/api2/json"
target_node      = "javazap"

talos_node_count     = 3

talos_cpu_cores      = 2
talos_cpu_sockets    = 1
talos_memory         = 4096
talos_disk_size      = "20G"
talos_storage        = "local-lvm"
talos_iso            = "local:iso/talos-1.11.5.iso"
talos_network_bridge = "vmbr0"

# TrueNAS Configuration
truenas_cpu_cores      = 2
truenas_memory         = 8192
truenas_boot_disk_size = "16G"
truenas_storage        = "local-lvm"
truenas_iso            = "local:iso/TrueNAS-SCALE-25.10.0.1.iso"
truenas_network_bridge = "vmbr0"
truenas_nvme_pcie_id   = "0000:02:00.0"  # Get with: lspci -nn | grep -i nvme