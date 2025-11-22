output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.cluster.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes cluster configuration"
  value       = talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the Talos cluster"
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "Cluster endpoint URL"
  value       = var.cluster_endpoint
}

output "controlplane_ips" {
  description = "Control plane node IP addresses"
  value       = [for node in var.controlplane_nodes : node.ip]
}

output "worker_ips" {
  description = "Worker node IP addresses"
  value       = [for node in var.worker_nodes : node.ip]
}
