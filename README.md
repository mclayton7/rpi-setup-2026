# Raspberry Pi Ansible Configuration

Automated configuration for 6 Raspberry Pis using Ansible, including tmux setup and colored bash prompts.

## Prerequisites

- Ansible 2.9 or later installed on your control machine
- SSH access to all Raspberry Pi hosts
- Passwordless sudo configured on Raspberry Pis (or provide sudo password when running playbook)
- Target OS: Ubuntu 24.04 LTS or 26.04 LTS

> The `docker` role installs from the official `docker-ce` apt repository and
> asserts the host is Ubuntu 24.04 or newer. The other roles are
> distribution-agnostic.

## Installation & Setup

### 1. Update Inventory

Edit `inventory/hosts.yml` with your Raspberry Pi IP addresses or hostnames:

```yaml
pi1:
  ansible_host: 192.168.1.101  # Replace with your Pi's IP
  ansible_user: pi
```

### 2. Configure SSH Access

Ensure you can SSH to your Raspberry Pis:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@192.168.1.101
```

### 3. Verify Connectivity

Test Ansible connectivity:

```bash
ansible all -i inventory/hosts.yml -m ping
```

## Running the Playbook

### Basic Usage

```bash
ansible-playbook playbooks/site.yml
```

### With Sudo Password

If passwordless sudo isn't configured:

```bash
ansible-playbook playbooks/site.yml -K
```

### For Specific Hosts

```bash
ansible-playbook playbooks/site.yml -l pi1,pi2
```

### Verbose Output

```bash
ansible-playbook playbooks/site.yml -v
```

## What Gets Configured

### tmux
- **Installation**: Installs tmux package via apt
- **Configuration**: Deploys default `.tmux.conf` with:
  - Prefix key: Ctrl+A (instead of default Ctrl+B)
  - 256-color support
  - Mouse enabled
  - Vi keybindings in copy mode
  - Status bar with hostname and time
  - History limit: 10,000 lines

### Bash Prompt Colors
Deploys `/etc/profile.d/colored_prompt.sh` with:
- **Username**: Green
- **Hostname**: Blue
- **Working Directory**: Yellow
- **Prompt Character**: White (user) or Red (root)
- **ls command**: Color enabled automatically

### Base Packages
Installs via apt:
- **skopeo**: container image inspection and copy tool
- **htop**: interactive process viewer
- **iproute2**: provides the `ss` socket statistics tool
- **jq**: JSON filtering for `docker inspect` output
- **ncdu**: disk-usage TUI for tracking `/var/lib/docker` growth
- **pigz**: parallel gzip, used automatically by `docker save`/`load`/`commit`

### Docker
Installs Docker Engine from the official `docker-ce` apt repository:
- Adds Docker's GPG key to `/etc/apt/keyrings/docker.asc`
- Registers `https://download.docker.com/linux/ubuntu` for the host's
  release codename (`ansible_distribution_release`)
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`,
  `docker-buildx-plugin`, and `docker-compose-plugin`
- Enables and starts the `docker` service
- Adds the deploy user to the `docker` group (re-login required before
  docker works without sudo)

### Container Tools
Installs pinned GitHub release binaries into `/usr/local/bin` (not packaged
in apt):
- **lazydocker**: full-screen TUI for containers, images, volumes, and logs
- **dtop**: terminal dashboard for Docker monitoring across hosts

Versions are pinned in `roles/container-tools/defaults/main.yml`. The role is
idempotent and replaces the binary only on a version change. Supports
`x86_64` and `aarch64` hosts.

### k3s
Installs a **single-node k3s server on each host** via the official
`get.k3s.io` installer:
- Pinned version in `roles/k3s/defaults/main.yml`; the installer re-runs only
  on a version change
- Started with `--disable traefik`, so ports **80/443 stay free** for
  `docker compose` apps
- `--write-kubeconfig-mode 0644` so the deploy user can run `kubectl` without
  sudo (kubeconfig is at `/etc/rancher/k3s/k3s.yaml`)
- Enables and starts the `k3s` systemd service

k3s runs its own embedded containerd, independent of Docker — `docker` and
`docker compose` are unaffected. Each host is its own standalone cluster.

## Customization

### Modify tmux Configuration

Edit `roles/tmux/files/.tmux.conf` to customize tmux settings.

### Modify Bash Prompt

Edit `roles/bash-prompt/files/bash_prompt.sh` to change colors or prompt format.

### Add More Hosts

Add entries to `inventory/hosts.yml` following the same format:

```yaml
pi7:
  ansible_host: 192.168.1.107
  ansible_user: pi
```

## Directory Structure

```
.
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── hosts.yml              # Inventory file
├── roles/
│   ├── tmux/
│   │   ├── tasks/
│   │   │   └── main.yml       # Install & configure tmux
│   │   └── files/
│   │       └── .tmux.conf     # tmux configuration
│   ├── bash-prompt/
│   │   ├── tasks/
│   │   │   └── main.yml       # Configure bash prompt
│   │   └── files/
│   │       └── bash_prompt.sh # Prompt color script
│   ├── packages/
│   │   └── tasks/
│   │       └── main.yml       # Install skopeo, htop, iproute2, jq, ncdu, pigz
│   ├── docker/
│   │   ├── tasks/
│   │   │   └── main.yml       # Install Docker from docker-ce repo
│   │   └── handlers/
│   │       └── main.yml       # docker group re-login notice
│   ├── container-tools/
│   │   ├── tasks/
│   │   │   └── main.yml       # Install lazydocker & dtop binaries
│   │   └── defaults/
│   │       └── main.yml       # Pinned lazydocker/dtop versions
│   └── k3s/
│       ├── tasks/
│       │   └── main.yml       # Install single-node k3s server
│       └── defaults/
│           └── main.yml       # Pinned k3s version, kubeconfig mode
└── playbooks/
    └── site.yml               # Main playbook

```

## Troubleshooting

### "Permission denied (publickey)"
- Ensure SSH key is copied: `ssh-copy-id -i ~/.ssh/id_rsa.pub pi@<pi-ip>`
- Or configure SSH password authentication

### "Module not found"
- Update Raspberry Pi: `sudo apt-get update && sudo apt-get upgrade`
- Ensure Python3 is installed

### Tmux not starting by default
- Tmux is installed but not automatically started. To use it, run `tmux` manually
- Or modify your shell profile to launch tmux automatically

## Notes

- Uses `become: True` with sudo for privilege escalation
- Requires elevated privileges to write to `/etc/profile.d/`
- Changes are applied to all hosts unless you use `-l` to limit execution

## License

Free to use and modify for your infrastructure.
