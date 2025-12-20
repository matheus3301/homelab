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

## Kubernetes GitOps Structure

The `kubernetes/` folder contains all Kubernetes configurations managed via GitOps with ArgoCD.

### Folder Structure

```
kubernetes/
├── bootstrap/                    # One-time setup files (applied manually)
│   ├── argocd-install.yaml       # ArgoCD installation manifest
│   ├── bootstrap-app.yaml        # App-of-Apps that discovers all apps
│   └── repo-secret.yaml          # GitHub repo credentials (optional for public repos)
└── apps-config/                  # GitOps-managed applications (auto-discovered)
    ├── argocd/
    │   └── argocd-Application.yaml
    └── kube-system/
        └── metrics-server-Application.yaml
```

### Naming Convention

Files follow the pattern `{name}-{Kind}.yaml`:
- `metrics-server-Application.yaml` - ArgoCD Application for metrics-server
- `admin-Role.yaml` - Kubernetes Role named admin
- `dashboard-GrafanaDashboard.yaml` - Grafana dashboard CR

**IMPORTANT**: One YAML document per file. Never use `---` to combine multiple resources in a single file.

### Deploying Helm Charts

**IMPORTANT**: Always check the latest chart version and validate values before creating or updating an Application:

```bash
# Add the repo (if not already added)
helm repo add <repo-name> <repo-url>

# Update and check latest versions
helm repo update <repo-name>
helm search repo <repo-name>/<chart-name> --versions | head -10

# Check available values and their defaults
helm show values <repo-name>/<chart-name> --version <version>
```

Create an Application manifest with inline values:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://charts.example.com
    chart: my-chart
    targetRevision: 1.0.0
    helm:
      values: |
        key: value
  destination:
    server: https://kubernetes.default.svc
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Deploying Raw Manifests

Place any Kubernetes manifest in `apps-config/{namespace}/` and it will be auto-applied by ArgoCD. Use the naming pattern `{name}-{Kind}.yaml`.

### Bootstrap Commands

```bash
# Install everything (one-time, files are numbered for correct order)
kubectl apply -f kubernetes/bootstrap/ -n argocd

# Nuke everything (if needed)
./kubernetes/bootstrap/__nuke.sh
```

After bootstrap, ArgoCD auto-discovers and syncs all manifests in `kubernetes/apps-config/`.

### External Secrets with 1Password

External Secrets uses 1Password SDK to fetch secrets from the `Kubernetes` vault.

```bash
# Setup 1Password service account (one-time, requires op CLI)
./kubernetes/bootstrap/__setup-onepassword.sh
```

**Manual setup** (if script fails):
```bash
# Create service account
op service-account create "homelab-k8s" --vault Kubernetes:read_items

# Create k8s secret with the token
kubectl create namespace external-secrets
kubectl create secret generic onepassword-service-account \
  -n external-secrets \
  --from-literal=token='ops_xxxxx...'
```

**Using secrets** - create an ExternalSecret:
```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: my-secret
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: onepassword
  target:
    creationPolicy: Owner
  data:
    - secretKey: password
      remoteRef:
        key: my-item/password  # format: <item>/[section/]<field>
```
