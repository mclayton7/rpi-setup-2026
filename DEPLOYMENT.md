# Deployment Guide

## Step 1: Update Inventory with Your Raspberry Pi IPs

Replace the template IPs in `inventory/hosts.yml` with your actual Raspberry Pi addresses. Edit the file and update each `ansible_host` value:

```yaml
all:
  children:
    raspberry_pis:
      hosts:
        pi1:
          ansible_host: YOUR_PI1_IP_HERE    # e.g., 192.168.1.10 or pi1.local
          ansible_user: pi
        pi2:
          ansible_host: YOUR_PI2_IP_HERE
          ansible_user: pi
        # ... repeat for pi3-pi6
```

**Finding your Pi IPs:**
- Login to Pi: `ssh pi@<pi-ip>`
- Run: `hostname -I` to see the IP address
- Or check your router's connected devices list

## Step 2: Configure SSH Access

### Option A: Copy SSH Key (Recommended - Passwordless)

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@192.168.1.10
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@192.168.1.11
# ... repeat for all 6 Pis
```

Then test: `ssh pi@192.168.1.10 echo "Connected!"`

### Option B: Use SSH Password Auth

Skip the ssh-copy-id step and use `-K` flag when running playbook:
```bash
ansible-playbook playbooks/site.yml -K
```

## Step 3: Verify Connectivity

Test that Ansible can reach all your Pis:

```bash
ansible all -i inventory/hosts.yml -m ping
```

Expected output:
```
pi1 | SUCCESS => {
    "ping": "pong"
}
pi2 | SUCCESS => {
    "ping": "pong"
}
# ... all pis should respond with SUCCESS
```

## Step 4: Run the Playbook

### Standard deployment (with passwordless SSH):
```bash
ansible-playbook playbooks/site.yml
```

### With sudo password prompt:
```bash
ansible-playbook playbooks/site.yml -K
```

### Verbose output (for troubleshooting):
```bash
ansible-playbook playbooks/site.yml -v
```

### Dry-run (see what would happen, no changes):
```bash
ansible-playbook playbooks/site.yml --check
```

## Step 5: Verify Deployment

After the playbook completes successfully:

1. **Test tmux on a Pi:**
   ```bash
   ssh pi@192.168.1.10
   tmux -V          # Should show tmux version
   cat ~/.tmux.conf # Should show your config
   tmux             # Start tmux session
   ```

2. **Test colored prompt:**
   ```bash
   ssh pi@192.168.1.10  # Prompt should be colored
   # Username in green, hostname in blue, path in yellow
   ```

## Troubleshooting

### "Permission denied (publickey)" or "Connection refused"
- Verify Pi IP is correct and reachable: `ping 192.168.1.10`
- Check SSH is enabled on Pi: `sudo raspi-config` → Interface Options → SSH
- Copy SSH key: `ssh-copy-id -i ~/.ssh/id_rsa.pub pi@192.168.1.10`

### "Failed to connect via SSH"
- Use verbose mode: `ansible-playbook playbooks/site.yml -v`
- Check network connectivity: `ping <pi-ip>`
- Verify username is correct (default: `pi`)

### Playbook fails on tmux installation
- Update packages: `ssh pi@192.168.1.10 'sudo apt-get update'`
- Try playbook again: `ansible-playbook playbooks/site.yml`

### Prompt colors not showing
- Log in fresh: `logout` then `ssh pi@192.168.1.10`
- Verify file exists: `cat /etc/profile.d/colored_prompt.sh`
- Try: `source /etc/profile.d/colored_prompt.sh && bash`

## Quick Start Script

```bash
#!/bin/bash
# Update these with your actual Pi IPs
PIPS=("192.168.1.10" "192.168.1.11" "192.168.1.12" "192.168.1.13" "192.168.1.14" "192.168.1.15")

# Copy SSH keys
for pi in "${PIPS[@]}"; do
  echo "Setting up SSH key for $pi..."
  ssh-copy-id -i ~/.ssh/id_rsa.pub pi@$pi
done

# Update inventory file
echo "Update inventory/hosts.yml with the IPs above"

# Test connectivity
echo "Testing connectivity..."
ansible all -i inventory/hosts.yml -m ping

# Deploy
echo "Deploying configuration..."
ansible-playbook playbooks/site.yml
```

Save as `deploy.sh`, make executable (`chmod +x deploy.sh`), update the IPs, and run: `./deploy.sh`
