# Minecraft Server on Proxmox
This repository provides ready-to-use scripts for deploying a Minecraft Java or Bedrock Edition server inside a Proxmox VM or LXC container.

## 💡 Features
- Supports Java (PaperMC) and Bedrock editions
- One-click setup for Ubuntu 24.04 (recommended)
- Java 21 with automatic fallback to Java 17 (for Debian)
- Automatic server updates using PaperMC API
- RAM/CPU configurable via environment variables
- systemd integration & update helper scripts

## ✅ Tested on
- Debian 11/12
- Ubuntu 24.04
- Proxmox 7.x / 8.x

See the full instructions in the repository.
