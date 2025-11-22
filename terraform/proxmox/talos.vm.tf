resource "proxmox_vm_qemu" "talos_node" {
  count = var.talos_node_count

  name        = "talos-node-${count.index + 1}"
  target_node = var.target_node

  # VM specs
  cpu {
    cores   = var.talos_cpu_cores
    sockets = var.talos_cpu_sockets
  }
  memory = var.talos_memory

  # SCSI controller - VirtIO SCSI for best performance and compatibility
  scsihw = "virtio-scsi-single"

  # Disk configuration
  disks {
    ide {
      ide2 {
        cdrom {
          iso = var.talos_iso
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = var.talos_disk_size
          storage = var.talos_storage
        }
      }
    }
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = var.talos_network_bridge
  }

  # Boot configuration
  boot = "order=scsi0;ide2"

  # Agent disabled for Talos OS
  agent = 1

  # Start VM on creation
  onboot = true
}