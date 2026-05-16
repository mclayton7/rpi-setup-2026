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
echo "This will apply the following to all Raspberry Pis:"
echo "  1. Install tmux with default configuration"
echo "  2. Configure colored bash prompt"
echo ""

read -p "Deploy now? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Check for sudo password
read -p "Do your Pis require a sudo password? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running playbook (will prompt for sudo password)..."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
else
    echo "Running playbook..."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
fi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. SSH into a Pi: ssh pi@<pi-ip>"
echo "  2. Test tmux: tmux"
echo "  3. Check prompt colors are working"
echo ""
echo "For troubleshooting, see: $PROJECT_DIR/DEPLOYMENT.md"
