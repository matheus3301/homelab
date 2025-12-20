locals {
  first_controlplane_ip = values(var.controlplane_nodes)[0].ip
  cluster_endpoint      = "https://${local.first_controlplane_ip}:6443"
}

# Generate Talos machine secrets
resource "talos_machine_secrets" "cluster" {
  talos_version = var.talos_version
}

# Generate Talos client configuration
data "talos_client_configuration" "cluster" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints            = [for node in var.controlplane_nodes : node.ip]
}

# Data source for machine configuration
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
  talos_version    = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.image_schematic}:${var.talos_version}"
        }
        kubelet = {
          image = "ghcr.io/siderolabs/kubelet:${var.kubernetes_version}"
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
          hostDNS = {
            enabled              = true
            forwardKubeDNSToHost = true
          }
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = var.allow_scheduling_on_control_planes
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
  talos_version    = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.image_schematic}:${var.talos_version}"
        }
        kubelet = {
          image = "ghcr.io/siderolabs/kubelet:${var.kubernetes_version}"
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
          hostDNS = {
            enabled              = true
            forwardKubeDNSToHost = true
          }
        }
      }
    })
  ]
}

# Apply machine configuration to control plane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.controlplane_nodes

  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip
  endpoint                    = each.value.ip

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
          interfaces = [
            {
              interface = "eth0"
              addresses = ["${each.value.ip}/24"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
            }
          ]
          nameservers = var.nameservers
        }
        install = {
          disk = each.value.install_disk
        }
      }
    })
  ]
}

# Apply machine configuration to worker nodes
resource "talos_machine_configuration_apply" "worker" {
  for_each = var.worker_nodes

  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip
  endpoint                    = each.value.ip

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
          interfaces = [
            {
              interface = "eth0"
              addresses = ["${each.value.ip}/24"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
            }
          ]
          nameservers = var.nameservers
        }
        install = {
          disk = each.value.install_disk
        }
      }
    })
  ]
}

# Bootstrap the Talos cluster (only on the first control plane node)
resource "talos_machine_bootstrap" "cluster" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]

  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = values(var.controlplane_nodes)[0].ip
  endpoint             = values(var.controlplane_nodes)[0].ip
}

# Generate kubeconfig
resource "talos_cluster_kubeconfig" "cluster" {
  depends_on = [
    talos_machine_bootstrap.cluster
  ]

  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = values(var.controlplane_nodes)[0].ip
}
