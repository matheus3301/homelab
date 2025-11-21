proxmox_api_url = "https://192.168.0.100:8006/api2/json"
target_node      = "javazap"

talos_node_count     = 2
talos_cpu_cores      = 2
talos_cpu_sockets    = 1
talos_memory         = 4096
talos_disk_size      = "30G"
talos_storage        = "local-lvm"
talos_iso            = "local:iso/talos-1.11.5.iso"
talos_network_bridge = "vmbr0"