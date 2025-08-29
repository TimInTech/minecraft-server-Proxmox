<p align="center">
  <img src="assets/banner.png" alt="Minecraft Server on Proxmox" />
</p>

<p align="center">
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/TimInTech/minecraft-server-Proxmox?style=flat&color=yellow"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/fork"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/TimInTech/minecraft-server-Proxmox?style=flat&color=blue"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/TimInTech/minecraft-server-Proxmox?style=flat"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/TimInTech/minecraft-server-Proxmox?include_prereleases&style=flat"></a>
</p>

# Minecraft Server on Proxmox

Run a Minecraft server on your Proxmox host in minutes. Supports Java and Bedrock on both Virtual Machines (VM) and Containers (LXC/CT).

## Table of Contents

- [Features](#features)
- [Quickstart](#quickstart)
  - [Proxmox Provisioning](#proxmox-provisioning)
  - [VM (DHCP)](#vm-dhcp)
  - [VM (Static IP)](#vm-static-ip)
  - [LXC/CT](#lxct)
  - [Bedrock](#bedrock)
- [Backups](#backups)
- [Auto-Update](#auto-update)
- [Configuration](#configuration)
- [Admin/Commands](#admincommands)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [References](#references)

## 🧩 Features

- VM/CT provisioning with clear steps for Proxmox
- Java and Bedrock installers
- Auto-update for Java via `update.sh`
- Backups with systemd timers or cron
- Sensible defaults: EULA, `screen`, memory flags
- Optional `systemd` service for auto-start

> [!TIP]
> Default ports: Java 25565/TCP, Bedrock 19132/UDP. Open these on your firewall/router.

## 🏗️ Architecture Overview

<p align="center">
  <img src="assets/diagram.png" alt="Architecture overview diagram" />
  <br />
  <i>High-level layout: Proxmox → VM/CT → Minecraft (Java/Bedrock) with backup/update hooks.</i>
  </p>

## 🚀 Quickstart

Requirements: Proxmox host, Ubuntu 24.04 LTS (recommended) or Debian 11/12 guest.

### VM (DHCP)

1) Create a VM (2–4 vCPU, 4–8 GB RAM, 20+ GB disk).
2) SSH into the VM and run:

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
```

Access console:

```bash
screen -r minecraft
```

> [!TIP]
> On Debian 11/12, the installer falls back to OpenJDK 17 if Java 21 isn’t available.

### VM (Static IP)

If you prefer static networking (Ubuntu netplan example):

```bash
sudo tee /etc/netplan/01-mc.yaml >/dev/null <<'YAML'
network:
  version: 2
  ethernets:
    ens18:
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
YAML
sudo netplan apply
```

Then install as in DHCP.

> [!WARNING]
> Use the correct interface name (e.g., `ens18`, `eth0`) and network details for your environment.

### LXC/CT

Create a container (Ubuntu 24.04 template recommended). Enable Nesting if needed. Inside the container:

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```

Access console:

```bash
screen -r minecraft
```

### Bedrock

VM or LXC/CT:

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
```

Access console:

```bash
screen -r bedrock
```

## 🧰 Proxmox Provisioning

Run these from a Proxmox node shell as `root`.

### VM (Cloud-Init Ubuntu)

DHCP example:

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/proxmox_vm_provision.sh
chmod +x proxmox_vm_provision.sh
./proxmox_vm_provision.sh \
  --vmid 19265 \
  --name mc-vm \
  --cores 4 \
  --memory 8192 \
  --disk 32 \
  --bridge vmbr0 \
  --storage local-lvm \
  --ssh-key /root/.ssh/id_rsa.pub \
  --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh"
```

Static IP example:

```bash
./proxmox_vm_provision.sh \
  --vmid 19266 \
  --name mc-vm-static \
  --cores 4 \
  --memory 8192 \
  --disk 32 \
  --bridge vmbr0 \
  --storage local-lvm \
  --ssh-key /root/.ssh/id_rsa.pub \
  --ip 192.168.1.50/24 \
  --gw 192.168.1.1 \
  --dns 1.1.1.1 \
  --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh"
```

Notes:

- The script auto-downloads an Ubuntu cloud image (default `noble`).
- It creates a reusable template if missing, then clones the VM.
- `--post-install` injects a cloud-init snippet to install and start Minecraft.
- Use `--snippets-store` if your snippets storage is not `local`.

### Container (LXC Ubuntu)

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/proxmox_ct_provision.sh
chmod +x proxmox_ct_provision.sh
./proxmox_ct_provision.sh \
  --ctid 12650 \
  --hostname mc-ct \
  --cores 4 \
  --memory 8192 \
  --disk 16 \
  --bridge vmbr0 \
  --storage local-lvm \
  --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh"
```

Notes:

- Pulls the Ubuntu 24.04 standard template if missing.
- Creates an unprivileged container with `nesting=1,keyctl=1` and DHCP.
- If `--post-install` is set, it installs dependencies and sets up Minecraft inside the CT.

## 🗃️ Backups

Back up worlds and server files before updates. Choose systemd or cron.

### Option A: systemd (Java/Bedrock)

Configuration file (used by the service):

```bash
sudo tee /etc/mc_backup.conf >/dev/null <<'EOF'
# Directories
MC_SRC_DIR=/opt/minecraft
MC_BEDROCK_DIR=/opt/minecraft-bedrock
BACKUP_DIR=/var/backups/minecraft
# Retention (days) for optional cleanup logic (manual step)
RETAIN_DAYS=7
EOF
```

Backup service and timer:

```bash
sudo tee /etc/systemd/system/mc-backup.service >/dev/null <<'EOF'
[Unit]
Description=Minecraft backup (tar)

[Service]
Type=oneshot
EnvironmentFile=/etc/mc_backup.conf
ExecStart=/bin/mkdir -p "${BACKUP_DIR}"
ExecStart=/bin/bash -c 'tar -czf "${BACKUP_DIR}/java-$(date +%%F).tar.gz" "${MC_SRC_DIR}"'
ExecStart=/bin/bash -c '[ -d "${MC_BEDROCK_DIR}" ] && tar -czf "${BACKUP_DIR}/bedrock-$(date +%%F).tar.gz" "${MC_BEDROCK_DIR}" || true'
EOF

sudo tee /etc/systemd/system/mc-backup.timer >/dev/null <<'EOF'
[Unit]
Description=Nightly Minecraft backup

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mc-backup.timer
```

Run on demand:

```bash
sudo systemctl start mc-backup.service
```

### Option B: cron

Nightly backups (note escaped `%` in cron):

```bash
crontab -e
30 3 * * * tar -czf /var/backups/minecraft/mc-$(date +\%F).tar.gz /opt/minecraft
```

Bedrock example:

```bash
crontab -e
45 3 * * * tar -czf /var/backups/minecraft/bedrock-$(date +\%F).tar.gz /opt/minecraft-bedrock
```

## ♻️ Auto-Update

Java edition ships with `/opt/minecraft/update.sh`:

```bash
cd /opt/minecraft
./update.sh
```

Weekly cron:

```bash
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```

> [!NOTE]
> Bedrock requires a manual download from Mojang. See `bedrock_helper.sh` for a reminder message.

## ⚙️ Configuration

### `/etc/mc_backup.conf`

- `MC_SRC_DIR`: Java server path (default `/opt/minecraft`)
- `MC_BEDROCK_DIR`: Bedrock server path (default `/opt/minecraft-bedrock`)
- `BACKUP_DIR`: Backup target directory (default `/var/backups/minecraft`)
- `RETAIN_DAYS`: Days to keep backups (manual cleanup policy)

### JVM memory (Java)

Edit `/opt/minecraft/start.sh`:

```bash
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
```

Small: `-Xms1G -Xmx2G`, Medium: `-Xms2G -Xmx4G`.

### Firewall

```bash
sudo ufw allow 25565/tcp    # Java
sudo ufw allow 19132/udp    # Bedrock
sudo ufw enable
```

### Optional: systemd service (Java)

Use `minecraft.service`:

```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable --now minecraft
```

## 🕹️ Admin/Commands

See [SERVER_COMMANDS.md](SERVER_COMMANDS.md) for operator setup, `screen` usage, and common commands.

## 🔧 Troubleshooting

- Java 21 unavailable on Debian 11 → falls back to OpenJDK 17.
- Missing `start.sh` → recreate as shown and `chmod +x start.sh`.
- Permission issues → ensure ownership of `/opt/minecraft*` or use `sudo`.

## 🤝 Contributing

- [Open an issue](../../issues)
- Submit a Pull Request

## 📚 References

- PaperMC: https://papermc.io/
- Mojang Bedrock Downloads: https://www.minecraft.net/en-us/download/server/bedrock
- Proxmox Docs: https://pve.proxmox.com/wiki/Main_Page
