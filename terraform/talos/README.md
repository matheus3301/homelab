# Talos Kubernetes Cluster - Terraform Configuration

This Terraform configuration manages a Talos OS Kubernetes cluster using the Siderolabs Talos provider.

## Overview

This stack handles:
- Generating cluster secrets and PKI certificates
- Creating machine configurations for control plane and worker nodes
- Applying configurations to running Talos nodes
- Bootstrapping the Kubernetes cluster
- Generating kubeconfig and talosconfig files

## Prerequisites

1. **VMs Running in Maintenance Mode**: Talos VMs must be created (use `../proxmox/`) and booted with Talos ISO
2. **Network Connectivity**: Ensure you can reach the Talos nodes from where you run Terraform
3. **Terraform**: Version 1.0 or later
4. **talosctl CLI**: Install from https://github.com/siderolabs/talos/releases

## Usage

### 1. Configure Variables

Copy the example file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your node IPs and configuration:

```hcl
cluster_endpoint = "https://192.168.0.15:6443"  # Control plane endpoint

controlplane_nodes = {
  cp1 = {
    ip           = "192.168.0.15"
    hostname     = "talos-cp-1"
    install_disk = "/dev/sda"
  }
}
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan and Apply

```bash
terraform plan
terraform apply
```

This will:
1. Generate cluster secrets
2. Create machine configurations
3. Apply configurations to nodes (nodes will reboot and install)
4. Bootstrap the Kubernetes cluster
5. Generate credentials

### 4. Export Credentials

**Option A: Using the setup script (recommended)**

```bash
./setup-kubeconfig.sh
```

This script will:
- Backup existing kubeconfig and talosconfig files
- Export both configurations to the correct locations
- Set proper file permissions
- Test the connections automatically

**Option B: Manual export**

```bash
# Export talosconfig
terraform output -raw talosconfig > ~/.talos/config

# Export kubeconfig
terraform output -raw kubeconfig > ~/.kube/config
```

### 5. Verify Cluster

```bash
# Check Talos nodes
talosctl health --nodes 192.168.0.15

# Check Kubernetes
kubectl get nodes
```

## Configuration Options

### Control Plane Nodes

Define control plane nodes in `controlplane_nodes` variable. For HA, use 3 or 5 nodes:

```hcl
controlplane_nodes = {
  cp1 = { ip = "192.168.0.15", hostname = "talos-cp-1", install_disk = "/dev/sda" }
  cp2 = { ip = "192.168.0.16", hostname = "talos-cp-2", install_disk = "/dev/sda" }
  cp3 = { ip = "192.168.0.17", hostname = "talos-cp-3", install_disk = "/dev/sda" }
}
```

### Worker Nodes

Define worker nodes in `worker_nodes` variable:

```hcl
worker_nodes = {
  worker1 = { ip = "192.168.0.20", hostname = "talos-worker-1", install_disk = "/dev/sda" }
  worker2 = { ip = "192.168.0.21", hostname = "talos-worker-2", install_disk = "/dev/sda" }
}
```

### Custom Image Schematic

The configuration uses a custom Talos image with the `qemu-guest-agent` extension. The schematic ID is:

```
ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515
```

To create a different schematic, visit: https://factory.talos.dev/

## Workflow with Proxmox Stack

1. **Create VMs**: Use `../proxmox/` to create VMs with Talos ISO
2. **Boot VMs**: VMs boot into Talos maintenance mode
3. **Apply Config**: Use this stack to configure and bootstrap the cluster
4. **Manage Cluster**: Use `kubectl` and `talosctl` for day-to-day operations

## Important Notes

- **Destructive Operations**: `terraform destroy` will remove cluster configuration but not delete VMs
- **State Management**: Keep `terraform.tfstate` safe - it contains cluster secrets
- **Node Reboot**: Applying configuration causes nodes to reboot and install Talos to disk
- **Bootstrap Once**: The cluster bootstrap happens only once on the first control plane node

## Outputs

- `talosconfig`: Talos client configuration for `talosctl`
- `kubeconfig`: Kubernetes configuration for `kubectl`
- `cluster_endpoint`: Cluster API endpoint URL
- `controlplane_ips`: List of control plane node IPs
- `worker_ips`: List of worker node IPs

## Rollback Configurations

If you need to restore previous kubeconfig or talosconfig files:

```bash
./rollback-kubeconfig.sh
```

This interactive script will:
- List all available backups with timestamps
- Allow you to select which backup to restore
- Backup the current config before rollback
- Test connections after restoration

Backups are automatically created by `setup-kubeconfig.sh` and named with timestamps:
- `~/.kube/config.backup.YYYYMMDD_HHMMSS`
- `~/.talos/config.backup.YYYYMMDD_HHMMSS`

## Troubleshooting

### Configuration Not Applying

Check node connectivity:
```bash
talosctl -n <node-ip> disks --insecure
```

### Bootstrap Fails

Ensure the first control plane node is healthy:
```bash
talosctl -n <first-cp-ip> health --insecure
```

### Kubeconfig Not Generated

Check that etcd is healthy after bootstrap:
```bash
talosctl -n <first-cp-ip> service etcd status
```

## References

- [Talos Documentation](https://www.talos.dev/latest/)
- [Talos Terraform Provider](https://registry.terraform.io/providers/siderolabs/talos/latest/docs)
- [Siderolabs Terraform Examples](https://github.com/siderolabs/contrib/tree/main/examples/terraform)
