resource "proxmox_vm_qemu" "truenas" {
  name        = "truenas"
  target_node = var.target_node

  # TrueNAS Scale recommends: 8GB+ RAM, 2+ cores
  cpu {
    cores   = var.truenas_cpu_cores
    sockets = 1
    type    = "host"
  }
  memory = var.truenas_memory

  # SCSI controller
  scsihw = "virtio-scsi-single"

  # Disk configuration
  disks {
    ide {
      ide2 {
        cdrom {
          iso = var.truenas_iso
        }
      }
    }
    scsi {
      # Boot disk for TrueNAS OS
      scsi0 {
        disk {
          size    = var.truenas_boot_disk_size
          storage = var.truenas_storage
        }
      }
    }
  }

  # PCIe passthrough for NVMe drive (direct hardware access)
  pci {
    id     = "0"
    raw_id = var.truenas_nvme_pcie_id
    pcie   = true
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = var.truenas_network_bridge
  }

  # Boot from OS disk first, then CDROM for installation
  boot = "order=scsi0;ide2"

  # Disable QEMU agent during installation (enable after TrueNAS is set up)
  agent = 0

  # Start VM on host boot
  onboot = true

  # SeaBIOS for better noVNC compatibility
  bios = "seabios"

  # q35 machine type required for PCIe passthrough
  machine = "q35"

  # Display settings
  vga {
    type   = "std"
    memory = 16
  }
}
