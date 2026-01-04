# Misc Ubuntu VM - General purpose VM for automations, Claude Code, etc.

resource "proxmox_vm_qemu" "misc" {
  name        = "misc"
  target_node = var.target_node

  # VM specs
  cpu {
    cores   = var.misc_cpu_cores
    sockets = 1
    type    = "host"
  }
  memory = var.misc_memory

  # SCSI controller
  scsihw = "virtio-scsi-single"

  # Disk configuration
  disks {
    ide {
      ide2 {
        cdrom {
          iso = var.misc_iso
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = var.misc_disk_size
          storage = var.misc_storage
        }
      }
    }
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = var.misc_network_bridge
  }

  # Boot from disk first, then ISO
  boot = "order=scsi0;ide2"

  # Enable QEMU guest agent (install it after Ubuntu setup)
  agent = 1

  # Start VM on boot
  onboot = true
}
