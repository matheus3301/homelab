output "talos_nodes" {
  description = "Information about all Talos nodes"
  value = {
    for idx, node in proxmox_vm_qemu.talos_node : node.name => {
      vmid                 = node.vmid
      name                 = node.name
      target_node          = node.target_node
      ipv4_address         = node.default_ipv4_address
      ipv6_address         = node.default_ipv6_address
      cpu_cores            = node.cpu[0].cores
      cpu_sockets          = node.cpu[0].sockets
      memory               = node.memory
      mac_address          = node.network[0].macaddr
    }
  }
}

output "talos_node_names" {
  description = "List of Talos node names"
  value       = [for node in proxmox_vm_qemu.talos_node : node.name]
}

output "talos_node_ips" {
  description = "List of Talos node IPv4 addresses"
  value       = [for node in proxmox_vm_qemu.talos_node : node.default_ipv4_address]
}

output "talos_node_ids" {
  description = "Map of node names to VM IDs"
  value       = { for node in proxmox_vm_qemu.talos_node : node.name => node.vmid }
}

output "truenas" {
  description = "TrueNAS VM information"
  value = {
    vmid = proxmox_vm_qemu.truenas.vmid
    name = proxmox_vm_qemu.truenas.name
  }
}
