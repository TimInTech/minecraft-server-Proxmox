# 🟩 Minecraft Server on Proxmox – Version 2.0 (updated 2025-09-02)

<p align="center">
  <img src="assets/banner.png" alt="Minecraft Server on Proxmox" />
</p>

<p align="center">
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/TimInTech/minecraft-server-Proxmox?style=flat&color=yellow"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/fork"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/TimInTech/minecraft-server-Proxmox?style=flat&color=blue"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/TimInTech/minecraft-server-Proxmox?style=flat"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/TimInTech/minecraft-server-Proxmox?include_prereleases&style=flat"></a>
</p>

---

## 📝 Introduction

This repository lets you deploy a high-performance Minecraft server (Java & Bedrock) on your Proxmox host in minutes.  
Designed for both VMs and LXC containers, it provides easy CLI-first installation, automated backups, and update scripts.  
Perfect for self-hosters, gaming communities, and homelab enthusiasts!

> Note for this workspace: Simulation only
> In this development environment we do not execute or install anything. When asked to "run", we only show and explain commands. See SIMULATION.md for the simulated flow of each script.

---

## 🧩 Technologies & Dependencies

![Proxmox](https://img.shields.io/badge/Proxmox-VE-EE7F2D?logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-11%20%2F%2012-A81D33?logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Java](https://img.shields.io/badge/OpenJDK-17%20%2F%2021-007396?logo=java&logoColor=white)
![Minecraft](https://img.shields.io/badge/Minecraft-Java%20%2F%20Bedrock-62B47A?logo=minecraft&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-%E2%9C%94-4EAA25?logo=gnubash&logoColor=white)
![Systemd](https://img.shields.io/badge/systemd-%E2%9C%94-FFDD00?logo=linux&logoColor=black)
![Screen](https://img.shields.io/badge/screen-%E2%9C%94-0077C2?logo=gnu&logoColor=white)

---

## 📊 Status

> ⚠ No build workflow present  
> For automated tests or deployment, please add `main.yml` to `.github/workflows/`.

---

## 🚀 Quickstart

### VM (DHCP)

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
```
Open console:
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
Then run the installer as above.

### LXC/CT

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```
Open console:
```bash
screen -r minecraft
```

### Bedrock

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
```
Open console:
```bash
screen -r bedrock
```

---

## 🗃️ Backups

Backup worlds and server files before updates! Choose systemd or cron.

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

---

## ♻️ Auto-Update

Java Edition:  
```bash
cd /opt/minecraft
./update.sh
```
Cron:
```bash
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```
> Bedrock requires manual download from Mojang (`bedrock_helper.sh` gives reminder message).

---

## ⚙️ Configuration

**/etc/mc_backup.conf**
* `MC_SRC_DIR`: Java server path (`/opt/minecraft`)
* `MC_BEDROCK_DIR`: Bedrock server path (`/opt/minecraft-bedrock`)
* `BACKUP_DIR`: Backup target (`/var/backups/minecraft`)
* `RETAIN_DAYS`: Retention days

**JVM memory (Java)**  
Edit `/opt/minecraft/start.sh`:
```bash
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
```
Small: `-Xms1G -Xmx2G`, Medium: `-Xms2G -Xmx4G`.

**Firewall**
```bash
sudo ufw allow 25565/tcp    # Java
sudo ufw allow 19132/udp    # Bedrock
sudo ufw enable
```

**Optional: systemd service (Java)**
```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable --now minecraft
```

---

## 🕹️ Admin/Commands

See [SERVER_COMMANDS.md](SERVER_COMMANDS.md) for operator setup, `screen` usage, and common commands.

---

## 🔧 Troubleshooting

* Java 21 unavailable on Debian 11 → falls back to OpenJDK 17.
* Missing `start.sh` → recreate as shown above and `chmod +x start.sh`.
* Permission issues → ensure ownership of `/opt/minecraft*` or use `sudo`.

---

## 🤝 Contributing

* [Open an issue](../../issues)
* Submit a Pull Request

---

## 📚 References

* PaperMC: [https://papermc.io/](https://papermc.io/)
* Mojang Bedrock Downloads: [https://www.minecraft.net/en-us/download/server/bedrock](https://www.minecraft.net/en-us/download/server/bedrock)
* Proxmox Docs: [https://pve.proxmox.com/wiki/Main_Page](https://pve.proxmox.com/wiki/Main_Page)

---

## License

[MIT](LICENSE)
