# 🟩 Minecraft Server on Proxmox – Version 2.0 (updated 2025-10-07)

<img title="" src="assets/banner.png" alt="Banner" width="326" data-align="center">

<p align="center"><em>Minecraft Server on Proxmox</em></p>

<p align="center">
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/TimInTech/minecraft-server-Proxmox?style=flat&color=yellow"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/fork"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/TimInTech/minecraft-server-Proxmox?style=flat&color=blue"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/TimInTech/minecraft-server-Proxmox?style=flat"></a>
  <a href="https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/TimInTech/minecraft-server-Proxmox?include_prereleases&style=flat"></a>
  <a href="https://buymeacoffee.com/timintech"><img alt="Buy Me A Coffee" src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buymeacoffee&logoColor=000&labelColor=grey&style=flat"></a>
</p>

---

## 🔗 Quick Links
- 📜 **Server Commands**: [SERVER_COMMANDS.md](SERVER_COMMANDS.md)
- 🧪 **Simulation guide**: [SIMULATION.md](SIMULATION.md)
- 🌐 **Bedrock Networking**: [docs/BEDROCK_NETWORKING.md](docs/BEDROCK_NETWORKING.md)
- 🤖 **Copilot Workflow**: [.github/copilot-instructions.md](.github/copilot-instructions.md)
- 🐞 **Issues & Feedback**: [Open an issue](../../issues)

---

## ✅ Requirements
- Proxmox VE: 7.4+ / 8.x / 9.x
- Gast-OS: Debian 12/13 oder Ubuntu 24.04
- CPU/RAM: ≥2 vCPU, ≥2–4 GB RAM (Java), ≥1–2 GB (Bedrock)
- Storage: ≥10 GB SSD
- Netzwerk: Bridged NIC (vmbr0), Ports 25565/TCP, 19132/UDP

---

## 📝 Introduction
Dieses Repo stellt in Minuten einen performanten Minecraft-Server (Java & Bedrock) auf Proxmox bereit. VM und LXC werden unterstützt. CLI-First Setup, Update-Skript, Backup-Beispiele.

> Simulation only: Keine Ausführung hier. Siehe **SIMULATION.md**.

## 🧩 Technologies & Dependencies
![Proxmox](https://img.shields.io/badge/Proxmox-VE-EE7F2D?logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-11%20%2F%2012%20%2F%2013-A81D33?logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Java](https://img.shields.io/badge/OpenJDK-17%20%2F%2021-007396?logo=java&logoColor=white)
![Minecraft](https://img.shields.io/badge/Minecraft-Java%20%2F%20Bedrock-62B47A?logo=minecraft&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-%E2%9C%94-4EAA25?logo=gnubash&logoColor=white)
![Systemd](https://img.shields.io/badge/systemd-%E2%9C%94-FFDD00?logo=linux&logoColor=black)
![Screen](https://img.shields.io/badge/screen-%E2%9C%94-0077C2?logo=gnu&logoColor=white)

## 📊 Status
Stabil. LXC/VM getestet. Bedrock Update manuell.

## 🚀 Quickstart

### VM (DHCP)
```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
sudo -u minecraft screen -r minecraft
````

> Debian 12/13: `/run/screen` mit `root:utmp` und `0775` (siehe unten).

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

### LXC/CT

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
sudo -u minecraft screen -r minecraft
```

### Bedrock

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_bedrock.sh
chmod +x setup_bedrock.sh
./setup_bedrock.sh
sudo -u minecraft screen -r bedrock
```

## 🗃️ Backups

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

### Option B: cron

```bash
crontab -e
30 3 * * * tar -czf /var/backups/minecraft/mc-$(date +\%F).tar.gz /opt/minecraft
45 3 * * * tar -czf /var/backups/minecraft/bedrock-$(date +\%F).tar.gz /opt/minecraft-bedrock
```

## ♻️ Auto-Update

```bash
cd /opt/minecraft && ./update.sh
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```

> Bedrock erfordert manuellen Download. `setup_bedrock.sh` erzwingt SHA256 (siehe unten).

## ⚙️ Configuration

### JVM memory (Java)

Installer setzt `Xms ≈ RAM/4`, `Xmx ≈ RAM/2` mit Floors `256M/448M`. Override in `/opt/minecraft/start.sh`.

## 🧾 Integrity & Firewall

**Java (PaperMC):**

* Paper-Download mit **SHA256-Verifikation** im Installer/Updater.
* Mindestgröße `server.jar > 5 MB` als HTML-Fehlschutz.

**Bedrock:**

* Standard: `REQUIRE_BEDROCK_SHA=1`. Setze `REQUIRED_BEDROCK_SHA256=<sha>`. Override möglich mit `REQUIRE_BEDROCK_SHA=0`.

**screen Socket (Debian 12/13):**

```bash
sudo install -d -m 0775 -o root -g utmp /run/screen
printf 'd /run/screen 0775 root utmp -\n' | sudo tee /etc/tmpfiles.d/screen.conf
sudo systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf
```

**UFW:**

```bash
sudo apt-get install -y ufw
sudo ufw allow 25565/tcp
sudo ufw allow 19132/udp
sudo ufw enable
```

## 🕹️ Admin/Commands

Siehe **[SERVER_COMMANDS.md](SERVER_COMMANDS.md)**.

## 🔧 Troubleshooting

* Zu wenig RAM in LXC → `start.sh` Werte reduzieren.
* Kein `/run/screen` → Abschnitt „screen Socket“ ausführen.
* Bedrock-ZIP MIME-Type Fehler → Mojang-Seite erneut prüfen.

## 🤝 Contributing

PR-Vorlage nutzen. Keine Ausführung in diesem Workspace. Siehe **[.github/copilot-instructions.md](.github/copilot-instructions.md)**.

## 📚 References

* PaperMC: [https://papermc.io/](https://papermc.io/)
* Proxmox Wiki: [https://pve.proxmox.com/wiki/Main_Page](https://pve.proxmox.com/wiki/Main_Page)
* Mojang Bedrock Server: [https://www.minecraft.net/en-us/download/server/bedrock](https://www.minecraft.net/en-us/download/server/bedrock)

## License

[MIT](LICENSE)

> Proxmox Helper: `scripts/proxmox_create_ct_bedrock.sh` erstellt Debian-12/13-CT und installiert Bedrock.

