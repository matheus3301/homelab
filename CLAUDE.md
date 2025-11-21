# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository manages a homelab infrastructure using Proxmox VE, with the goal of running a Kubernetes cluster on Talos OS-based VMs. All infrastructure is provisioned and managed using Terraform with the Telmate/proxmox provider.

## Architecture

- **Hypervisor**: Proxmox VE running on physical hardware (accessible at http://192.168.1.100:8006)
- **Target OS for VMs**: Talos OS (immutable Linux distribution designed for Kubernetes)
- **Orchestration**: Kubernetes cluster running across Talos OS VMs
- **Infrastructure as Code**: Terraform using the Telmate/proxmox provider (v3.0.2-rc05)

## Terraform Structure

The Terraform configuration is organized under `terraform/proxmox/`:
- `provider.tf` - Defines the Telmate/proxmox provider configuration
- `main.tf` - Primary infrastructure definitions (currently minimal)

## Common Commands

### Terraform Operations

```bash
# Navigate to Terraform directory
cd terraform/proxmox

# Initialize Terraform (download providers)
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Format Terraform files
terraform fmt

# Show current state
terraform show
```

### Proxmox Authentication

The provider expects authentication via environment variables:
```bash
export PM_USER="user@pam"
export PM_PASS="your-password"
```

Alternatively, these can be set in `provider.tf` (not recommended for sensitive data).

## Provider Reference

Using the Telmate/proxmox provider: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs

Key resources for this homelab setup:
- `proxmox_vm_qemu` - For creating Talos OS VMs
- `proxmox_lxc` - For LXC containers (if needed)
- `proxmox_pool` - For organizing resources

## Talos OS Considerations

When creating Talos OS VMs with Terraform:
- Talos requires a cloud-init or ISO-based installation approach
- VMs should be configured with appropriate CPU, memory, and disk resources for K8s workloads
- Network configuration should support cluster communication
- Consider using Proxmox templates for Talos OS images
