#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

KUBECONFIG_PATH="${HOME}/.kube/config"
TALOSCONFIG_PATH="${HOME}/.talos/config"

echo -e "${GREEN}Setting up Talos and Kubernetes configurations...${NC}"

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo -e "${RED}Error: Please run this script from the terraform/talos directory${NC}"
    exit 1
fi

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}Error: No terraform state found. Run 'terraform apply' first.${NC}"
    exit 1
fi

# Backup existing kubeconfig if it exists
if [ -f "$KUBECONFIG_PATH" ]; then
    BACKUP_PATH="${KUBECONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing kubeconfig to: ${BACKUP_PATH}${NC}"
    cp "$KUBECONFIG_PATH" "$BACKUP_PATH"
fi

# Backup existing talosconfig if it exists
if [ -f "$TALOSCONFIG_PATH" ]; then
    BACKUP_PATH="${TALOSCONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing talosconfig to: ${BACKUP_PATH}${NC}"
    cp "$TALOSCONFIG_PATH" "$BACKUP_PATH"
fi

# Create directories if they don't exist
mkdir -p "$(dirname "$KUBECONFIG_PATH")"
mkdir -p "$(dirname "$TALOSCONFIG_PATH")"

# Export kubeconfig
echo -e "${GREEN}Exporting kubeconfig to ${KUBECONFIG_PATH}${NC}"
terraform output -raw kubeconfig > "$KUBECONFIG_PATH"

# Export talosconfig
echo -e "${GREEN}Exporting talosconfig to ${TALOSCONFIG_PATH}${NC}"
terraform output -raw talosconfig > "$TALOSCONFIG_PATH"

# Set proper permissions
chmod 600 "$KUBECONFIG_PATH"
chmod 600 "$TALOSCONFIG_PATH"

echo -e "${GREEN}✓ Configuration files exported successfully!${NC}"
echo ""
echo -e "Kubeconfig:  ${KUBECONFIG_PATH}"
echo -e "Talosconfig: ${TALOSCONFIG_PATH}"
echo ""
echo -e "${GREEN}Testing connection...${NC}"

# Test kubectl connection
if command -v kubectl &> /dev/null; then
    echo -e "\n${YELLOW}kubectl version:${NC}"
    kubectl version --short 2>/dev/null || kubectl version
    echo -e "\n${YELLOW}Cluster nodes:${NC}"
    kubectl get nodes
else
    echo -e "${YELLOW}kubectl not found in PATH. Install it to test Kubernetes connection.${NC}"
fi

# Test talosctl connection
if command -v talosctl &> /dev/null; then
    echo -e "\n${YELLOW}Talos node health:${NC}"
    # Get control plane IPs from Terraform output
    CONTROLPLANE_IPS=$(terraform output -json controlplane_ips | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
    if [ -n "$CONTROLPLANE_IPS" ]; then
        talosctl health --nodes "$CONTROLPLANE_IPS"
    else
        echo -e "${RED}Could not retrieve control plane IPs from Terraform${NC}"
    fi
else
    echo -e "${YELLOW}talosctl not found in PATH. Install it to test Talos connection.${NC}"
fi

echo -e "\n${GREEN}Setup complete!${NC}"
