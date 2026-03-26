# Minecraft Server on Proxmox – Version 3.0 (updated 2026-03-26)

![Banner](assets/banner.png)

*Minecraft Server on Proxmox*

[![GitHub Stars](https://img.shields.io/github/stars/TimInTech/minecraft-server-Proxmox?style=flat&color=yellow)](https://github.com/TimInTech/minecraft-server-Proxmox/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/TimInTech/minecraft-server-Proxmox?style=flat&color=blue)](https://github.com/TimInTech/minecraft-server-Proxmox/fork)
[![License](https://img.shields.io/github/license/TimInTech/minecraft-server-Proxmox?style=flat)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/TimInTech/minecraft-server-Proxmox?include_prereleases&style=flat)](https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buymeacoffee&logoColor=000&labelColor=grey&style=flat)](https://buymeacoffee.com/timintech)

---

## Quick Links

- Server Commands: [SERVER_COMMANDS.md](SERVER_COMMANDS.md)
- Simulation Guide: [SIMULATION.md](SIMULATION.md)
- Bedrock Networking: [docs/BEDROCK_NETWORKING.md](docs/BEDROCK_NETWORKING.md)
- Copilot Workflow: [.github/copilot-instructions.md](.github/copilot-instructions.md)
- Issues — <https://github.com/TimInTech/minecraft-server-Proxmox/issues>

---

## What's New in v3.0

### Breaking Changes & Critical Fixes

- **PaperMC API migrated to Fill v3** — The old `api.papermc.io/v2/` endpoint stopped receiving new builds on December 31, 2025 and will be fully disabled on July 1, 2026. All scripts (`setup_minecraft.sh`, `setup_minecraft_lxc.sh`, embedded `update.sh`) now use the new `fill.papermc.io/v3/` REST API. This resolves Issues [#66](https://github.com/TimInTech/minecraft-server-Proxmox/issues/66) and [#70](https://github.com/TimInTech/minecraft-server-Proxmox/issues/70).
- **User-Agent header required** — Fill v3 rejects or rate-limits requests without a proper `User-Agent`. All API calls now include `minecraft-server-Proxmox/<version>`.
- **Download URLs embedded in API response** — Downloads now come from `fill-data.papermc.io`. URLs are no longer manually constructed but read directly from the API response.
- **Stable channel filtering** — The new API returns builds across channels (alpha, beta, stable, recommended). Scripts now filter for `channel == "STABLE"` to avoid pulling experimental builds.

### Other Improvements

- **LXC script: `screen` support added** — `setup_minecraft_lxc.sh` now installs `screen`, creates the `/run/screen` socket directory, and starts the server inside a screen session (consistent with VM script and README instructions). Resolves Issue [#67](https://github.com/TimInTech/minecraft-server-Proxmox/issues/67).
- **Minecraft versioning note** — Starting in 2026, Mojang uses a new versioning scheme (`26.1` instead of `1.x.x`). The scripts handle this transparently since they always pull the latest version from the API.
- **Java badge corrected** — Java 21 is the minimum requirement (Java 17 is no longer sufficient for current PaperMC builds).
- **Bedrock regex updated** — The URL scraping pattern now also matches the new `26.x` versioning scheme used since February 2026.
- **File ownership fix** — `eula.txt` and other generated files are now created with correct ownership from the start.

---

## ✅ Requirements

- Proxmox VE: 7.4+ / 8.x / 9.x
- Guest OS: Debian 12/13 or Ubuntu 22.04 / 24.04
- CPU/RAM: ≥2 vCPU, ≥2–4 GB RAM (Java), ≥1–2 GB (Bedrock)
- Storage: ≥10 GB SSD
- Network: Bridged NIC (vmbr0), ports 25565/TCP and 19132/UDP

Java 21 is required. If OpenJDK 21 is missing in your repositories, the installers automatically fall back to Amazon Corretto 21 (APT with signed-by keyring).
**Note:** UFW must be installed before running any `ufw` commands. JVM memory is auto-sized by the installer (see below). Bedrock installer enforces SHA256 checksum by default.

---

## Introduction

This repository provisions a performant Minecraft server (Java & Bedrock) on Proxmox in minutes. VM and LXC are supported. CLI-first setup, updater, and backup examples are provided.

> Simulation only: Do not execute commands in this workspace. See SIMULATION.md.

## Technologies & Dependencies

[![Proxmox](https://img.shields.io/badge/Proxmox-VE-EE7F2D?logo=proxmox&logoColor=white)](https://pve.proxmox.com/)
[![Debian](https://img.shields.io/badge/Debian-12%20%2F%2013-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%2F%2024.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Java](https://img.shields.io/badge/OpenJDK-21-007396?logo=java&logoColor=white)](https://openjdk.org/)
[![Minecraft](https://img.shields.io/badge/Minecraft-Java%20%2F%20Bedrock-62B47A?logo=minecraft&logoColor=white)](https://www.minecraft.net/)
[![Bash](https://img.shields.io/badge/Bash-%E2%9C%94-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Systemd](https://img.shields.io/badge/systemd-%E2%9C%94-FFDD00?logo=linux&logoColor=black)](https://systemd.io/)
[![Screen](https://img.shields.io/badge/screen-%E2%9C%94-0077C2?logo=gnu&logoColor=white)](https://www.gnu.org/software/screen/)

## 📊 Status

Stable. VM and LXC tested. PaperMC API upgraded to Fill v3 (March 2026). Bedrock updates remain manual.

## Quickstart

### VM (DHCP)

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
sudo -u minecraft screen -r minecraft
```

> Debian 12/13: Ensure `/run/screen` exists with `root:utmp` and mode `0775` (see below).

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

### Option B: cron

```bash
crontab -e
30 3 * * * tar -czf /var/backups/minecraft/mc-$(date +\%F).tar.gz /opt/minecraft
45 3 * * * tar -czf /var/backups/minecraft/bedrock-$(date +\%F).tar.gz /opt/minecraft-bedrock
```

## ♻ Auto-Update

Java Edition: `update.sh` (created by `setup_minecraft.sh`) pulls the latest stable PaperMC build via Fill v3 API with SHA256 and size validation.

```bash
cd /opt/minecraft && ./update.sh
crontab -e
0 4 * * 0 /opt/minecraft/update.sh >> /var/log/minecraft-update.log 2>&1
```

> Bedrock requires a manual download. `setup_bedrock.sh` enforces SHA256 by default (see below).
> **Checksum enforcement:** Bedrock installer requires `REQUIRED_BEDROCK_SHA256` and validates the ZIP before extraction.

## Configuration

### JVM memory (Java)

The installer sets `Xms ≈ RAM/4` and `Xmx ≈ RAM/2` with floors `1024M/2048M` and an `Xmx` cap of `≤16G`. Override in `/opt/minecraft/start.sh`.

## Integrity & Firewall

**Java (PaperMC):**

- Paper download is verified via **SHA256** from the Fill v3 API response.
- Minimum size `server.jar > 5 MB` to avoid saving HTML error pages.
- Only **STABLE** channel builds are downloaded (alpha/beta/experimental excluded).

**Bedrock:**

- Default: `REQUIRE_BEDROCK_SHA=1`. Set `REQUIRED_BEDROCK_SHA256=<sha>`. Override with `REQUIRE_BEDROCK_SHA=0`.
- The installer validates MIME type via HTTP HEAD (application/zip|octet-stream), checks size, and tests the ZIP via `unzip -tq` before extracting.

**screen socket (Debian 12/13):**

```bash
sudo install -d -m 0775 -o root -g utmp /run/screen
printf 'd /run/screen 0775 root utmp -\n' | sudo tee /etc/tmpfiles.d/screen.conf
sudo systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf
```

> **LXC Note:** In unprivileged LXC containers, the `utmp` group may not exist. The scripts handle this gracefully by falling back to `root:root` with mode `0777` if needed.

**UFW:**

```bash
sudo apt-get install -y ufw
sudo ufw allow 25565/tcp
sudo ufw allow 19132/udp
sudo ufw enable
```

## PaperMC API Migration (v2 → Fill v3)

If you have an existing installation using the old `api.papermc.io/v2/` endpoint, re-run the setup script or manually update your `update.sh` in `/opt/minecraft/`. The key changes are:

| Aspect | Old (v2) | New (Fill v3) |
|---|---|---|
| Base URL | `api.papermc.io/v2/projects/paper` | `fill.papermc.io/v3/projects/paper` |
| Build selection | `jq '.builds \| last'` | `jq 'map(select(.channel=="STABLE")) \| .[0]'` |
| Download URL | Manually constructed | Embedded in `.downloads."server:default".url` |
| SHA256 | `.downloads.application.sha256` | `.downloads."server:default".checksums.sha256` |
| User-Agent | Not required | **Required** (rejected/rate-limited without) |
| Shutdown | July 1, 2026 | Active and supported |

## 🕹 Admin/Commands

See **[SERVER_COMMANDS.md](SERVER_COMMANDS.md)**.

## ☕ Support / Donate

If this project saves you time, consider supporting continued maintenance via [Buy Me A Coffee](https://buymeacoffee.com/timintech).

## Troubleshooting

- **PaperMC download fails with 404** → You are still using the old v2 API. Update your scripts to Fill v3 (re-run installer or see migration table above).
- **Not enough RAM in LXC** → Reduce values in `start.sh`.
- **Missing `/run/screen`** → Follow the "screen socket" section above.
- **`/run/screen` mode 777 in LXC** → In unprivileged containers, `utmp` may not exist. Use `chmod 0777 /run/screen` or ensure the `utmp` group is mapped.
- **Bedrock ZIP MIME-Type issue** → Revisit the Mojang download page.
- **Java 17 no longer works** → PaperMC 1.21.8+ requires Java 21. Re-run the installer to get Corretto 21 fallback.

Use the PR template. Do not execute anything in this workspace. See **[.github/copilot-instructions.md](.github/copilot-instructions.md)**.

For safe simulation workflow details, see **[SIMULATION.md](SIMULATION.md)**.

> **Simulation CLI:** For step-by-step Copilot CLI workflow, see [.github/copilot-instructions.md](.github/copilot-instructions.md).

## References

- PaperMC: <https://papermc.io/>
- PaperMC Fill v3 API Docs: <https://docs.papermc.io/misc/downloads-service/>
- PaperMC Fill v3 Swagger: <https://fill.papermc.io/swagger-ui/index.html>
- Proxmox Wiki: <https://pve.proxmox.com/wiki/Main_Page>
- Mojang Bedrock Server: <https://www.minecraft.net/en-us/download/server/bedrock>

## License

[MIT](LICENSE)

> Proxmox Helper: `scripts/proxmox_create_ct_bedrock.sh` creates a Debian 12/13 container and installs Bedrock.
