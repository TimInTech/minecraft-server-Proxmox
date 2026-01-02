# Copilot Instructions (AI Coding Agents)

## Big Picture
Dieses Repo sind defensive **Bash-Installer/Updater** für Minecraft auf Proxmox-Gästen:
- **Java (PaperMC)**: Provisionierung nach `/opt/minecraft`, Start via `screen`.
- **Bedrock**: Provisionierung nach `/opt/minecraft-bedrock`, Start via `screen`.
- Optionaler Autostart über systemd (`minecraft.service`, `minecraft-bedrock.service`).

## Simulation-Only (nicht ausführen)
- **Keine Side-Effects** in dieser Workspace-Umgebung: kein `apt`, `systemctl`, `curl/wget` (wenn es Dinge installiert/ändert), keine `./setup_*.sh`.
- Bei „run/build“ nur **Beispiel-Kommandos für externe Hosts** zeigen und kurz erklären. Siehe [SIMULATION.md](SIMULATION.md).
- Für Copilot-CLI-/Diff-Workflow: [COPILOT_RUN_INSTRUCTIONS.md](COPILOT_RUN_INSTRUCTIONS.md).

## Entry Points
- Java VM Installer: `setup_minecraft.sh`
- Java LXC Installer: `setup_minecraft_lxc.sh`
- Bedrock Installer: `setup_bedrock.sh`
- Java Updater: `update.sh`
- systemd Units: `minecraft.service`, `minecraft-bedrock.service`
- Doku: `README.md`, `SIMULATION.md`, `docs/BEDROCK_NETWORKING.md`

## Repo-spezifische Patterns (bitte beibehalten)
- Shell: `#!/usr/bin/env bash` + `set -euo pipefail` (z. B. in `setup_minecraft.sh`, `setup_bedrock.sh`).
- Java 21: erst **OpenJDK 21**, Fallback auf **Amazon Corretto 21 via APT keyring + signed-by** (`ensure_java()` in `setup_minecraft.sh`).
- JVM Autosize: aus `/proc/meminfo` → `-Xms ≈ RAM/4`, `-Xmx ≈ RAM/2`, Floors `1024M/2048M`, `Xmx`-Cap `≤16G` (generiertes `start.sh`).
- PaperMC Integrität: PaperMC API (`curl`+`jq`) liefert SHA256; Download prüft SHA + Mindestgröße `>5MB` gegen HTML-Fehlerseiten (`setup_minecraft.sh`, `update.sh`).
- Bedrock Integrität: Mojang-URL per Regex; **HTTP HEAD Content-Type** muss `application/zip|octet-stream` sein; Checksum standardmäßig **erzwingend** (`REQUIRE_BEDROCK_SHA=1`, `REQUIRED_BEDROCK_SHA256`) (`setup_bedrock.sh`).
- screen Socket: `/run/screen` muss existieren (`root:utmp`, `0775`) und via `systemd-tmpfiles` persistiert werden, sonst scheitert `screen` auf Debian 12/13.
- systemd Hardening: `minecraft.service` nutzt `User/Group=minecraft`, Hardening-Flags und `ReadWritePaths=/opt/minecraft`.

## Änderungen am Repo
- Minimal ändern, Stil beibehalten; keine neuen UX-Flows erfinden.
- Neue Env-Variablen/Optionen immer kurz in `README.md` und/oder `SIMULATION.md` dokumentieren.
- Keine Artefakte wie `*.bak`/`*.rej`/Report-Dateien einchecken (falls relevant: `.gitignore` ergänzen).
