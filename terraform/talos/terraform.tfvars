cluster_name     = "javazap"

kubernetes_version = "v1.34.1"
talos_version      = "v1.11.5"

# Image schematic with qemu-guest-agent extension
image_schematic = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"

controlplane_nodes = {
  cp1 = {
    ip           = "192.168.0.18"
    hostname     = "talos-cp-1"
    install_disk = "/dev/sda"
  }
}

worker_nodes = {
  worker1 = {
    ip           = "192.168.0.16"
    hostname     = "talos-worker-1"
    install_disk = "/dev/sda"
  }

  worker2 = {
    ip           = "192.168.0.17"
    hostname     = "talos-worker-2"
    install_disk = "/dev/sda"
  }
}

allow_scheduling_on_control_planes = true
