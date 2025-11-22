#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

KUBECONFIG_PATH="${HOME}/.kube/config"
TALOSCONFIG_PATH="${HOME}/.talos/config"

echo -e "${BLUE}=== Kubernetes and Talos Configuration Rollback ===${NC}\n"

# Function to list backups for a given path
list_backups() {
    local config_path=$1
    local config_name=$2

    echo -e "${YELLOW}Available ${config_name} backups:${NC}"

    local backups=($(ls -t "${config_path}.backup."* 2>/dev/null || true))

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}No backups found for ${config_name}${NC}"
        return 1
    fi

    local i=1
    for backup in "${backups[@]}"; do
        local timestamp=$(basename "$backup" | sed "s/.*\.backup\.//")
        local size=$(du -h "$backup" | cut -f1)
        echo -e "  ${GREEN}[$i]${NC} $(basename $backup) (${size}, $(date -r "$backup" "+%Y-%m-%d %H:%M:%S"))"
        ((i++))
    done

    return 0
}

# Function to rollback a specific config
rollback_config() {
    local config_path=$1
    local config_name=$2

    echo -e "\n${YELLOW}--- Rolling back ${config_name} ---${NC}\n"

    local backups=($(ls -t "${config_path}.backup."* 2>/dev/null || true))

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}No backups found for ${config_name}${NC}"
        return 1
    fi

    list_backups "$config_path" "$config_name"

    echo -e "\n${BLUE}Enter backup number to restore (or 's' to skip):${NC} "
    read -r selection

    if [ "$selection" = "s" ] || [ "$selection" = "S" ]; then
        echo -e "${YELLOW}Skipping ${config_name}${NC}"
        return 0
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
        echo -e "${RED}Invalid selection${NC}"
        return 1
    fi

    local selected_backup="${backups[$((selection-1))]}"

    # Backup current config before rollback
    if [ -f "$config_path" ]; then
        local rollback_backup="${config_path}.before_rollback.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up current config to: $(basename $rollback_backup)${NC}"
        cp "$config_path" "$rollback_backup"
    fi

    # Restore backup
    echo -e "${GREEN}Restoring backup: $(basename $selected_backup)${NC}"
    cp "$selected_backup" "$config_path"
    chmod 600 "$config_path"

    echo -e "${GREEN}✓ ${config_name} restored successfully!${NC}"
    return 0
}

# Check if any backups exist
kubeconfig_has_backups=false
talosconfig_has_backups=false

if ls "${KUBECONFIG_PATH}.backup."* 1> /dev/null 2>&1; then
    kubeconfig_has_backups=true
fi

if ls "${TALOSCONFIG_PATH}.backup."* 1> /dev/null 2>&1; then
    talosconfig_has_backups=true
fi

if [ "$kubeconfig_has_backups" = false ] && [ "$talosconfig_has_backups" = false ]; then
    echo -e "${RED}No backup files found!${NC}"
    echo -e "Backup files are created by ${GREEN}./setup-kubeconfig.sh${NC}"
    exit 1
fi

# Rollback kubeconfig
if [ "$kubeconfig_has_backups" = true ]; then
    rollback_config "$KUBECONFIG_PATH" "kubeconfig"
else
    echo -e "${YELLOW}No kubeconfig backups found${NC}"
fi

echo ""

# Rollback talosconfig
if [ "$talosconfig_has_backups" = true ]; then
    rollback_config "$TALOSCONFIG_PATH" "talosconfig"
else
    echo -e "${YELLOW}No talosconfig backups found${NC}"
fi

echo -e "\n${GREEN}=== Rollback complete! ===${NC}"

# Test connections
echo -e "\n${YELLOW}Testing connections...${NC}"

if command -v kubectl &> /dev/null && [ -f "$KUBECONFIG_PATH" ]; then
    echo -e "\n${YELLOW}Kubernetes nodes:${NC}"
    kubectl get nodes 2>/dev/null || echo -e "${RED}Could not connect to Kubernetes cluster${NC}"
fi

if command -v talosctl &> /dev/null && [ -f "$TALOSCONFIG_PATH" ]; then
    echo -e "\n${YELLOW}Talos nodes:${NC}"
    talosctl get members 2>/dev/null || echo -e "${RED}Could not connect to Talos cluster${NC}"
fi
