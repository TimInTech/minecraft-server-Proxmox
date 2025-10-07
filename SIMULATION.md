# Simulation Guide – Do not execute locally

This repository contains shell scripts for installing and managing a Minecraft server on Proxmox hosts and guests. In this workspace, we operate in simulation-only mode: do not execute commands here. When asked to run, only show and explain the commands; do not install or modify this machine.

Quick links:

* Option 1: Java server in VM

  * chmod +x setup_minecraft.sh
  * ./setup_minecraft.sh
  * screen -r minecraft
* Option 2: Java server in LXC/Container

  * chmod +x setup_minecraft_lxc.sh
  * ./setup_minecraft_lxc.sh
  * screen -r minecraft
* Option 3: Bedrock server

  * chmod +x setup_bedrock.sh
  * ./setup_bedrock.sh
  * screen -r bedrock
* Option 4: Update existing Java server (PaperMC)

  * chmod +x update.sh
  * ./update.sh
* Option 5 (optional, Java only): Enable systemd auto-start

  * sudo cp minecraft.service /etc/systemd/system/minecraft.service
  * sudo systemctl daemon-reload
  * sudo systemctl enable --now minecraft

All commands above are examples for execution on a suitable external host/guest, not in this workspace.

## What each script does (simulated)

### setup_minecraft.sh (VM – Java Edition)

Installs a PaperMC-based Java server under /opt/minecraft.

* Packages: apt update/upgrade, installs screen, wget, curl, jq, unzip.
* Java: attempts OpenJDK 21; if unavailable, falls back to Amazon Corretto 21.
* Filesystem: creates `/opt/minecraft` owned by `minecraft`.
* **Download**: queries the PaperMC API to get the latest version/build and downloads `server.jar` (SHA256 verified).
* EULA: writes `eula.txt` with `eula=true`.
* Start script: creates `start.sh` with autosized memory (`Xms ≈ RAM/4`, `Xmx ≈ RAM/2`, floors `256M/448M`).
* Runtime: starts the server in a detached GNU screen session `minecraft`.

Expected state:

* `/opt/minecraft` with `server.jar`, `eula.txt`, `start.sh`, later `logs/`, `world/`, `plugins/`.
* Port `25565/tcp` listening.

### setup_minecraft_lxc.sh (LXC/Container – Java Edition)

Same as VM variant but without `sudo`. Also creates `/run/screen` (root:utmp, 0775) inside the CT for screen sockets.

### setup_bedrock.sh (VM/CT – Bedrock Edition)

* Installs deps, creates `/opt/minecraft-bedrock`, scrapes Mojang Bedrock link, checks `Content-Type`, downloads zip.
* Prints SHA256 of the zip and **enforces** it by default (`REQUIRED_BEDROCK_SHA256` must be set unless `REQUIRE_BEDROCK_SHA=0`).
* Tests and extracts zip; creates `start.sh` and launches a `screen` session `bedrock`.

### update.sh (Java Edition updater)

* Resolves latest Paper build via API, downloads `server.jar`, verifies SHA256, replaces file.

## Networking

* Java: TCP 25565; Bedrock: UDP 19132.

## Backups & recovery

* See README for `systemd` timer or cron examples.

## Risks & safeguards

* Network downloads may change/fail; verify connectivity and API.
* Low-memory CTs: installer uses conservative floors to avoid OOM; you can further lower values in `start.sh` if needed.

---

**Done.**

Ersetze die oben gelisteten Dateien in deinem Arbeitsbaum und committe/pushe wie gewohnt:

```bash
git add README.md setup_minecraft.sh setup_minecraft_lxc.sh SIMULATION.md
git commit -m "fix: installer downloads server.jar with SHA check; tiny-CT RAM floors; remove broken banner"
git push
```
