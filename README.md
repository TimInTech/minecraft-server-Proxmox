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

---

**Version 2.0 — 2025-09-02**

This repository also provides a Bash script to provision Ubuntu Cloud-Init VMs on Proxmox, optimized for Minecraft or similar services.

> [!IMPORTANT]  
> The provisioning script **must be executed as `root`** — without `sudo`. Either log in directly as `root` or use `su -` before running it.

---

## Table of Contents

- [Features](#features)
- [Quickstart](#quickstart)
  - [VM (DHCP)](#vm-dhcp)
  - [VM (Static IP)](#vm-static-ip)
  - [LXC/CT](#lxct)
  - [Bedrock](#bedrock)
- [Proxmox Provisioning](#proxmox-provisioning)
- [Backups](#backups)
- [Auto-Update](#auto-update)
- [Configuration](#configuration)
- [Admin/Commands](#admincommands)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [References](#references)

---

## 🧩 Features

- VM/CT provisioning with clear steps for Proxmox
- Java and Bedrock installers
- Auto-update for Java via `update.sh`
- Backups with systemd timers or cron
- Sensible defaults: EULA, `screen`, memory flags
- Optional `systemd` service for auto-start
- Proxmox Cloud-Init provisioning script with:
  - Automatic template creation from Ubuntu cloud image
  - Clone to new VM with configurable resources
  - Cloud-init user-data via snippets
  - `--ensure-snippets` option to auto-create a `dir` snippets storage
  - Supports DHCP and static IPs

> [!TIP]  
> Default ports: Java 25565/TCP, Bedrock 19132/UDP. Open these on your firewall/router.

---

## 🚀 Quickstart

Requirements: Proxmox host, Ubuntu 24.04 LTS (recommended) or Debian 11/12 guest.

### VM (DHCP)

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
````

Access console:

```bash
screen -r minecraft
```

### VM (Static IP)

Example netplan config:

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

### LXC/CT

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```

### Bedrock

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
```

---

## 🧰 Proxmox Provisioning

Script: `proxmox_vm_provision.sh` (run on the Proxmox node shell, as `root` only).

### DHCP Example

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
  --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh" \
  --ensure-snippets
```

### Static IP Example

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
  --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh" \
  --ensure-snippets
```

### Important Options

* `--ensure-snippets` → if snippets storage is missing, creates a new `dir` storage (safe default).
* `--snippets-path` → override path for snippets (default `/var/lib/vz/snippets`).
* `--post-install` → URL of a script executed in the VM after first boot.

### Security Notes

* No hardcoded passwords in the repo.
* Post-install scripts are downloaded from a given URL — **verify before use**.

---

## 🔧 Troubleshooting

* **“This script must be run as root”** → run with `su -` or log in as `root`.
* **“Storage does not support snippets”** → use `--ensure-snippets` or add a `dir` storage in `storage.cfg`.
* LVM storages (like `local-lvm`) don’t support snippets → fallback to `--ensure-snippets`.

---

## 🤝 Contributing

* [Open an issue](../../issues) (include Proxmox version and `pvesm/qm` output).
* Pull requests are welcome.

---

## 📚 References

* PaperMC: [https://papermc.io/](https://papermc.io/)
* Mojang Bedrock: [https://www.minecraft.net/en-us/download/server/bedrock](https://www.minecraft.net/en-us/download/server/bedrock)
* Proxmox Docs: [https://pve.proxmox.com/wiki/Main\_Page](https://pve.proxmox.com/wiki/Main_Page)
