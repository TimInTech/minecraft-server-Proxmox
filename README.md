<p align="center">


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

> **Notice**  
> The experimental Proxmox Cloud-Init provisioning scripts have been **temporarily removed**. Manual VM/CT setup remains fully supported.

---

## Table of Contents

- [Features](#features)
- [Quickstart](#quickstart)
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
- [License](#license)

---

## 🧩 Features

- Simple VM/CT install scripts for Proxmox guests  
- Java and Bedrock installers  
- Auto-update for Java via `update.sh`  
- Backups with systemd timers or cron  
- Sensible defaults: EULA, `screen`, JVM memory flags  
- Optional `systemd` service for auto-start  

> Default ports: Java **25565/TCP**, Bedrock **19132/UDP**.

---

## 🚀 Quickstart

Requirements: Proxmox host with an Ubuntu 24.04 LTS or Debian 11/12 guest.

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

Then run the installer as in DHCP.

### LXC/CT

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

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
```

Access console:

```bash
screen -r bedrock
```

---

## 🗃️ Backups

Back up worlds and server files before updates. Choose systemd or cron.

### Option A: systemd (Java/Bedrock)

Config:

```bash
sudo tee /etc/mc_backup.conf >/dev/null <<'EOF'
MC_SRC_DIR=/opt/minecraft
MC_BEDROCK_DIR=/opt/minecraft-bedrock
BACKUP_DIR=/var/backups/minecraft
RETAIN_DAYS=7
EOF
```

Service + timer:

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

```bash
crontab -e
30 3 * * * tar -czf /var/backups/minecraft/mc-$(date +\%F).tar.gz /opt/minecraft
45 3 * * * tar -czf /var/backups/minecraft/bedrock-$(date +\%F).tar.gz /opt/minecraft-bedrock
```

---

## ♻️ Auto-Update

Java edition ships with `/opt/minecraft/update.sh`:

```bash
cd /opt/minecraft
./update.sh
```

Cron example:

```bash
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```

> Bedrock requires a manual download from Mojang. See `bedrock_helper.sh` for a reminder message.

---

## ⚙️ Configuration

### `/etc/mc_backup.conf`

* `MC_SRC_DIR`: Java server path (default `/opt/minecraft`)
* `MC_BEDROCK_DIR`: Bedrock server path (default `/opt/minecraft-bedrock`)
* `BACKUP_DIR`: Backup target directory (default `/var/backups/minecraft`)
* `RETAIN_DAYS`: Days to keep backups (manual cleanup policy)

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

```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable --now minecraft
```

---

## 🕹️ Admin/Commands

See [SERVER\_COMMANDS.md](SERVER_COMMANDS.md) for operator setup, `screen` usage, and common commands.

---

## 🔧 Troubleshooting

* Java 21 unavailable on Debian 11 → falls back to OpenJDK 17.
* Missing `start.sh` → recreate as shown and `chmod +x start.sh`.
* Permission issues → ensure ownership of `/opt/minecraft*` or use `sudo`.

---

## 🤝 Contributing

* [Open an issue](../../issues)
* Submit a Pull Request

---

## 📚 References

* PaperMC: [https://papermc.io/](https://papermc.io/)
* Mojang Bedrock Downloads: [https://www.minecraft.net/en-us/download/server/bedrock](https://www.minecraft.net/en-us/download/server/bedrock)
* Proxmox Docs: [https://pve.proxmox.com/wiki/Main\_Page](https://pve.proxmox.com/wiki/Main_Page)

---

## License

[MIT](LICENSE)
