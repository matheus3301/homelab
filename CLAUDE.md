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
├── 00-bootstrap/                 # One-time setup files (applied manually)
│   ├── 00-argocd-Namespace.yaml
│   ├── 01-argocd-Raw.yaml        # ArgoCD installation manifest
│   ├── 02-homelab-repo-Secret.yaml
│   ├── 03-core-AppProject.yaml   # ArgoCD Project for core infra
│   ├── 04-services-AppProject.yaml
│   ├── 05-apps-AppProject.yaml
│   ├── 06-11-*-ApplicationSet.yaml  # ApplicationSets for each layer
│   └── __setup-onepassword.sh
├── 01-core/                      # Core infrastructure (project: core)
│   ├── metallb/                  # Load balancer
│   ├── istio-system/             # Service mesh
│   ├── external-secrets/         # Secrets management
│   ├── kube-system/              # Cluster services
│   ├── tailscale/                # VPN/networking
│   └── global/                   # Cluster-wide resources
├── 02-services/                  # Shared services (project: services)
│   └── (databases, observability, etc.)
└── 03-apps/                      # User applications (project: apps)
    └── (your applications)
```

### ArgoCD Projects

Three ArgoCD Projects separate concerns and provide security boundaries:

- **core**: Full cluster access, can create any resource in any namespace
- **services**: Full cluster access for shared services
- **apps**: Restricted to `default` and `apps-*` namespaces, limited resource types

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

Place any Kubernetes manifest in the appropriate layer folder (`01-core/`, `02-services/`, or `03-apps/`) under a namespace subfolder and it will be auto-applied by ArgoCD. Use the naming pattern `{name}-{Kind}.yaml`.

- Core infrastructure: `kubernetes/01-core/{namespace}/`
- Shared services: `kubernetes/02-services/{namespace}/`
- Applications: `kubernetes/03-apps/{namespace}/`

### Bootstrap Commands

```bash
# Install everything (one-time, files are numbered for correct order)
kubectl apply -f kubernetes/00-bootstrap/ -n argocd

# Nuke everything (if needed)
./kubernetes/00-bootstrap/__nuke.sh
```

After bootstrap, ArgoCD auto-discovers and syncs all manifests in `kubernetes/01-core/`, `kubernetes/02-services/`, and `kubernetes/03-apps/`.

### External Secrets with 1Password

External Secrets uses 1Password SDK to fetch secrets from the `Kubernetes` vault.

```bash
# Setup 1Password service account (one-time, requires op CLI)
./kubernetes/00-bootstrap/__setup-onepassword.sh
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
