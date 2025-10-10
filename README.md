# Minecraft Server on Proxmox – Version 2.0 (updated 2025-10-07)

<img title="" src="assets/banner.png" alt="Banner" width="326" data-align="center">

<p align="center">
  <em>Minecraft Server on Proxmox</em>
</p>

<p align="center">
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/TimInTech/minecraft-server-Proxmox?style=flat&color=yellow"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/fork"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/TimInTech/minecraft-server-Proxmox?style=flat&color=blue"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/TimInTech/minecraft-server-Proxmox?style=flat"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/TimInTech/minecraft-server-Proxmox?include_prereleases&style=flat"></a>
  <a href="https://buymeacoffee.com/timintech"><img alt="Buy Me A Coffee" src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buymeacoffee&logoColor=000&labelColor=grey&style=flat"></a>
</p>

---

## Introduction

This repository lets you deploy a high-performance Minecraft server (Java & Bedrock) on your Proxmox host in minutes.  
Designed for both VMs and LXC containers, it provides easy CLI-first installation, automated backups, and update scripts.  
Perfect for self-hosters, gaming communities, and homelab enthusiasts!

> Note for this workspace: Simulation only
> We do not execute or install anything here. When asked to "run", we only show and explain commands. See SIMULATION.md for the simulated flow of each script.

Quick Links:
- [Server Commands](SERVER_COMMANDS.md)
- [Simulation Guide](SIMULATION.md)
- [Bedrock Networking](docs/BEDROCK_NETWORKING.md)
- [Copilot Workflow](.github/copilot-instructions.md)
- Issues — Open an issue


## ✅ Requirements
- Proxmox VE: 7.4+ / 8.x / 9.x
- Guest OS: Debian 11/12/13 or Ubuntu 24.04
- CPU/RAM: ≥2 vCPU, ≥–4 GB RAM (Java), ≥–2 GB (Bedrock)
- Storage: ≥10 GB SSD
- Network: Bridged NIC (vmbr0), ports 25565/TCP and 19132/UDP
- Java 21 required; if OpenJDK 21 is missing, fallback to Amazon Corretto 21 (APT signed-by keyring).

 


![Proxmox](https://img.shields.io/badge/Proxmox-VE-EE7F2D?logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-11%20%2F%2012%20%2F%2013-A81D33?logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Java](https://img.shields.io/badge/OpenJDK-17%20%2F%2021-007396?logo=java&logoColor=white)
![Minecraft](https://img.shields.io/badge/Minecraft-Java%20%2F%20Bedrock-62B47A?logo=minecraft&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-%E2%9C%94-4EAA25?logo=gnubash&logoColor=white)
![Systemd](https://img.shields.io/badge/systemd-%E2%9C%94-FFDD00?logo=linux&logoColor=black)
![Screen](https://img.shields.io/badge/screen-%E2%9C%94-0077C2?logo=gnu&logoColor=white)


## 📊 Status



Stable. VM and LXC tested. Bedrock updates remain manual.

## Quickstart

### VM (DHCP)

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
```

Open console:

```bash
sudo -u minecraft screen -r minecraft
```

> Debian 11/12/13: Ensure `/run/screen` exists with `root:utmp` and mode `0775`.
>
> To persist across reboots:
>
> ```bash
> sudo install -d -m 0775 -o root -g utmp /run/screen
> printf 'd /run/screen 0775 root utmp -\n' | sudo tee /etc/tmpfiles.d/screen.conf
> sudo systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf
> ```

### Recommended (Java): systemd instead of screen

```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service && sudo systemctl daemon-reload && sudo systemctl enable --now minecraft
```

### VM (Static IP)

```bash
sudo tee /etc/netplan/01-mc.yaml >/dev/null <<'YAML'
network:
  version: 2
  ethernets:
    ens18:
      addresses: [192.168.1.50/24]
      routes: [{ to: default, via: 192.168.1.1 }]
      nameservers: { addresses: [1.1.1.1,8.8.8.8] }
YAML
sudo netplan apply
```

> Adjust nameservers to your local resolver (Pi-hole/Unbound).

Then run the installer as above.

### LXC/CT

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```

Open console:

```bash
sudo -u minecraft screen -r minecraft
```

### Bedrock

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
```

Open console:

```bash
sudo -u minecraft screen -r bedrock
```


## 🗃 Backups

### Option A: systemd

```bash
sudo tee /etc/mc_backup.conf >/dev/null <<'EOF'
MC_SRC_DIR=/opt/minecraft
MC_BEDROCK_DIR=/opt/minecraft-bedrock
BACKUP_DIR=/var/backups/minecraft
RETAIN_DAYS=7
EOF

sudo tee /etc/systemd/system/mc-backup.service >/dev/null <<'EOF'
[Unit]
Description=Minecraft backup (tar)
[Service]
Type=oneshot
EnvironmentFile=/etc/mc_backup.conf
ExecStart=/bin/mkdir -p "${BACKUP_DIR}"
ExecStart=/bin/bash -c 'tar -czf "${BACKUP_DIR}/java-$(date +%%F).tar.gz" "${MC_SRC_DIR}"'
ExecStart=/bin/bash -c '[ -d "${MC_BEDROCK_DIR}" ] && tar -czf "${BACKUP_DIR}/bedrock-$(date +%%F).tar.gz" "${MC_BEDROCK_DIR}" || true'
ExecStartPost=/bin/bash -c 'find "${BACKUP_DIR}" -type f -name "*.tar.gz" -mtime +"${RETAIN_DAYS:-7}" -delete'
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

On-demand:

```bash
sudo systemctl start mc-backup.service
```

### Option B: cron

```bash
crontab -e
30 3 * * * tar -czf /var/backups/minecraft/mc-$(date +\%F).tar.gz /opt/minecraft
45 3 * * * tar -czf /var/backups/minecraft/bedrock-$(date +\%F).tar.gz /opt/minecraft-bedrock
```


## ♻ Auto-Update


```bash
cd /opt/minecraft
./update.sh
```


```bash
cd /opt/minecraft && ./update.sh
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```

> Bedrock requires manual download from Mojang (`setup_bedrock.sh` enforces checksum; see below).

Bedrock security: `setup_bedrock.sh` enforces SHA256 by default. Set `REQUIRED_BEDROCK_SHA256` before running; or override with `REQUIRE_BEDROCK_SHA=0`.

## Configuration

### JVM memory (Java)

Autosized by installer: `Xms ≈ RAM/4`, `Xmx ≈ RAM/2` with floors `256M/448M`.
Edit `/opt/minecraft/start.sh` to override:

```bash
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
```


## Integrity & Firewall

Integrity

- PaperMC downloads: verify SHA256 and ensure file size is greater than 5 MB before replacing `server.jar`.
- Bedrock: integrity is enforced by default. Keep `REQUIRE_BEDROCK_SHA=1` and set `REQUIRED_BEDROCK_SHA256` to a known value before running `setup_bedrock.sh`.

Firewall

```bash
sudo apt-get install -y ufw
sudo ufw allow 25565/tcp    # Java
sudo ufw allow 19132/udp    # Bedrock
sudo ufw enable

# IPv6 (optional)
sudo ufw allow 25565/tcp comment "Minecraft Java v6"
sudo ufw allow 19132/udp comment "Minecraft Bedrock v6"
```


## 🕹 Admin/Commands

See [SERVER_COMMANDS.md](SERVER_COMMANDS.md).

## Troubleshooting

- Screen fails to attach: ensure `/run/screen` exists with `root:utmp` and mode `0775` (see Quickstart snippet).
- Connection issues: verify firewall rules for TCP 25565 (Java) and UDP 19132 (Bedrock); check container networking.
- Java memory errors: lower `-Xms`/`-Xmx` in `/opt/minecraft/start.sh` or increase RAM.

## Contributing

See [.github/copilot-instructions.md](.github/copilot-instructions.md).

## License

[MIT](LICENSE)


## ☕ Support / Donate

If you find these tools useful and want to support development:


[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/timintech)
