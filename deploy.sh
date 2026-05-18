#!/bin/bash
# Raspberry Pi Ansible Deployment Helper

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
INVENTORY="$PROJECT_DIR/inventory/hosts.yml"
PLAYBOOK="$PROJECT_DIR/playbooks/site.yml"

echo "=== Raspberry Pi Ansible Configuration Deployment ==="
echo ""

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "ERROR: ansible-playbook not found. Please install Ansible first."
    echo "  macOS: brew install ansible"
    echo "  Linux: sudo apt-get install ansible"
    exit 1
fi

echo "✓ Ansible found: $(ansible-playbook --version | head -1)"
echo ""

# Show current inventory
echo "=== Current Inventory ==="
echo ""
cat "$INVENTORY"
echo ""

# Ask if user wants to update inventory
read -p "Do you need to update inventory with your actual Pi IPs? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening $INVENTORY for editing..."
    ${EDITOR:-nano} "$INVENTORY"
    echo "✓ Inventory updated"
    echo ""
fi

# Verify connectivity
echo "=== Verifying Connectivity ==="
echo ""
read -p "Test connectivity to all Pis? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ansible all -i "$INVENTORY" -m ping 2>/dev/null; then
        echo "✓ All Pis are reachable"
    else
        echo "⚠ Warning: Some Pis are unreachable"
        read -p "Continue deployment anyway? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deployment cancelled."
            exit 1
        fi
    fi
    echo ""
fi

# Syntax check
echo "=== Validating Playbook ==="
if ansible-playbook --syntax-check "$PLAYBOOK" > /dev/null 2>&1; then
    echo "✓ Playbook syntax is valid"
else
    echo "✗ Playbook has syntax errors"
    exit 1
fi
echo ""

# Deploy
echo "=== Ready to Deploy ==="
echo ""
echo "This will apply the following to all hosts:"
echo "  1. Grant passwordless sudo to the ansible user"
echo "  2. Install tmux with default configuration"
echo "  3. Configure colored bash prompt"
echo "  4. Install base packages (skopeo, htop, ss/iproute2, jq, ncdu, pigz, nmap)"
echo "  5. Install Docker from the docker-ce apt repository"
echo "  6. Install container tools (lazydocker, dtop)"
echo "  7. Install single-node k3s (Traefik disabled)"
echo ""

read -p "Deploy now? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# The Ubuntu cloud-init 'ubuntu' user has passwordless sudo by default, and the
# 'sudo' role makes it explicit/idempotent, so no -K prompt is needed. If a Pi
# has been hardened to require a sudo password, run manually with: -K
echo "Running playbook..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. SSH into a Pi: ssh pi@<pi-ip>"
echo "  2. Test tmux: tmux"
echo "  3. Check prompt colors are working"
echo ""
echo "For troubleshooting, see: $PROJECT_DIR/DEPLOYMENT.md"
