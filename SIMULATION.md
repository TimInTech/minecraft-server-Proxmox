# Simulation Guide – Do not execute locally

This repository contains shell scripts for installing and managing a Minecraft server on Proxmox hosts and guests. In this workspace, we operate in simulation-only mode: do not execute commands here. When asked to run, only show and explain the commands; do not install or modify this machine.

Quick links:

- Option 1: Java server in VM
  - chmod +x setup_minecraft.sh
  - ./setup_minecraft.sh
  - screen -r minecraft
- Option 2: Java server in LXC/Container
  - chmod +x setup_minecraft_lxc.sh
  - ./setup_minecraft_lxc.sh
  - screen -r minecraft
- Option 3: Bedrock server
  - chmod +x setup_bedrock.sh
  - ./setup_bedrock.sh
  - screen -r bedrock
- Option 4: Update existing Java server (PaperMC)
  - chmod +x update.sh
  - ./update.sh
- Option 5 (optional, Java only): Enable systemd auto-start
  - sudo cp minecraft.service /etc/systemd/system/minecraft.service
  - sudo systemctl daemon-reload
  - sudo systemctl enable --now minecraft

All commands above are examples for execution on a suitable external host/guest, not in this workspace.

## What each script does (simulated)

The descriptions below explain the side effects, created files, and expected outcomes as if the scripts were run on a compatible Debian/Ubuntu system. No commands are executed in this environment.

### setup_minecraft.sh (VM – Java Edition)

Installs a PaperMC-based Java server under /opt/minecraft.

- Packages: apt update/upgrade, installs screen, wget, curl, jq, unzip.
- Java: attempts OpenJDK 21; if unavailable, falls back to OpenJDK 17 (headless).
- Filesystem: creates /opt/minecraft owned by the invoking user; changes into that directory.
- Download: queries PaperMC API via curl+jq to get LATEST_VERSION and LATEST_BUILD; downloads server.jar accordingly.
- EULA: writes eula.txt with eula=true.
- Start script: creates start.sh (java -Xms2G -Xmx4G -jar server.jar nogui) and marks it executable.
- Update script: writes update.sh to refresh server.jar to latest build; marks it executable.
- Runtime: starts the server in a detached GNU screen session named minecraft.

Expected external state after run:

- Directory /opt/minecraft with files: server.jar, eula.txt, start.sh, update.sh, logs/, world/ (created on first run by server), plugins/ (optional).
- Listening TCP port 25565 (Java), process run via java in a screen session.

Common failure points and mitigations:

- Network/API: If PaperMC API unreachable or jq missing, download/version resolution fails → verify connectivity and jq installation.
- Java: If OpenJDK 21 not in repos, script falls back to 17 automatically.
- Permissions: Ensure user has rights to /opt/minecraft.
- Memory flags: Adjust -Xms/-Xmx in start.sh to match available RAM.

Idempotency:

- Re-running will overwrite server.jar and start/update scripts. Existing world files remain.

### setup_minecraft_lxc.sh (LXC/Container – Java Edition)

Similar to the VM installer but uses apt without sudo (typical for privileged containers) and does not write an update.sh. It:

- Updates packages, installs screen, wget, curl, jq, unzip.
- Installs OpenJDK 21 or falls back to 17.
- Sets up /opt/minecraft, downloads latest PaperMC server.jar.
- Accepts EULA and creates start.sh.
- Starts screen session minecraft.

Expected external state:

- /opt/minecraft with server.jar, eula.txt, start.sh; screen session; port 25565 open in the container.

Notes for LXC:

- Ensure container has network access and adequate memory/CPU limits.
- For unprivileged containers, file permissions and Java availability may vary.

### setup_bedrock.sh (VM/CT – Bedrock Edition)

Installs a Bedrock server under /opt/minecraft-bedrock.

- Packages: installs unzip, wget, screen, curl (with sudo).
- Filesystem: creates /opt/minecraft-bedrock and assigns to invoking user.
- Download: parses Mojang download page for the latest linux ZIP (azureedge) and downloads it.
- Validation: tests the ZIP with unzip -tq before extracting; extracts contents and removes ZIP.
- Start script: creates start.sh to run LD_LIBRARY_PATH=. ./bedrock_server.
- Runtime: starts a screen session bedrock running start.sh.

Expected external state:

- /opt/minecraft-bedrock with bedrock_server and related .so files, server.properties, whitelist.json, permissions.json.
- Listening UDP port 19132 (Bedrock), process in screen session bedrock.

Failure points:

- Parsing failures if page layout changes; fallback is to visit Mojang URL and download manually.
- Missing screen or unzip packages → ensure apt installations completed.

### update.sh (Java Edition updater)

Updates PaperMC server.jar to the latest available build.

- Assumes /opt/minecraft as working dir.
- Uses curl+jq to resolve latest version/build; downloads new server.jar.
- Does not stop the server; best practice is to stop the server, back up, then update.

Safe update flow (suggested): stop server (screen -S minecraft -X stuff 'stop\n'), back up /opt/minecraft, run update.sh, then start start.sh again.

### minecraft.service (Optional systemd unit – Java)

Defines a simple systemd service to run /opt/minecraft/start.sh as root at boot.

- User=root, WorkingDirectory=/opt/minecraft, ExecStart=/opt/minecraft/start.sh.
- Installation (example, do not execute here):
  - sudo cp minecraft.service /etc/systemd/system/minecraft.service
  - sudo systemctl daemon-reload
  - sudo systemctl enable --now minecraft

Consider customizing User to a non-root service account and hardening with systemd options (ProtectSystem, PrivateTmp, etc.).

### bedrock_helper.sh

Simple reminder script that prints: "Manual Bedrock update required. Visit official Mojang page to download."

## Networking

- Java Edition: TCP 25565 (default). Expose/forward on Proxmox or your router as needed.
- Bedrock Edition: UDP 19132 (default). Ensure UDP forwarding and firewall allowances.

## Backups and recovery (high-level)

- Back up /opt/minecraft and /opt/minecraft-bedrock before updates.
- Use tar archives and retain multiple days; see README for systemd timer or cron examples.
- To remove a server (cleanup): stop the process (screen -S SESSION_NAME -X stuff 'stop\n'); then remove the /opt directory.

## Risks and safeguards

- Package installation modifies system state; run scripts only on intended hosts.
- Network downloads from third parties (PaperMC, Mojang) can fail or change.
- Running as root via systemd is simple but less secure; prefer a dedicated non-root user in production.

## Simulation policy

In this workspace:

- Do not run apt, systemctl, curl against production endpoints for side effects, or any scripts.
- Provide commands and rationale only. When asked to run, respond with simulated steps and expected outcomes.
- Documentation and scripts changes should be proposed via PRs, with SIMULATION.md kept up to date.

## Integrity & Firewall

> Integrity: Java downloads are SHA256-verified via PaperMC API.  
> Bedrock has no official checksum; the installer prints the archive’s SHA256.  
> Enforce a known value by exporting `REQUIRED_BEDROCK_SHA256=<sha256>` before running `setup_bedrock.sh`.
