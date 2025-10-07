# Copilot Run Instructions – Minecraft Server on Proxmox

## Zweck

Klar definierte Aufgaben für GitHub Copilot (CLI), um Skripte und Doku konsistent zu aktualisieren – inklusive Debian 13-Fallbacks.

## Voraussetzungen

1. Git, GitHub CLI und Copilot CLI sind eingerichtet
2. Du arbeitest im Repo-Klon

```bash
cd "$HOME/github_repos/minecraft-server-Proxmox"
git status
```

---

## Häufige Aufgaben (Ausführen auf Zielsystem nach Bedarf)

**Option 1: Java in VM**

```bash
chmod +x setup_minecraft.sh
./setup_minecraft.sh
sudo -u minecraft screen -r minecraft
```

**Option 2: Java in LXC**

```bash
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
sudo -u minecraft screen -r minecraft
```

**Option 3: Bedrock**

```bash
chmod +x setup_bedrock.sh
./setup_bedrock.sh
sudo -u minecraft screen -r bedrock
```

**Option 4: Java aktualisieren (PaperMC)**

```bash
chmod +x update.sh
./update.sh
```

**Option 5: systemd Autostart (optional, Java)**

```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable --now minecraft
```

---

## Empfohlener Copilot-Workflow

### 1) Branch vorbereiten

```bash
cd "$HOME/github_repos/minecraft-server-Proxmox"
git switch -c copilot/refactor || git switch copilot/refactor
```

### 2) Ein-Prompt für Audit & Refactor (nur Diff ausgeben lassen)

> Hinweis: Dieser Prompt weist Copilot an, **Debian 13** korrekt zu berücksichtigen.

```bash
gh copilot chat -p '
Refactor this repo. Output a single unified diff file named refactor.diff (git apply -p0 friendly). Scope:

1) setup_minecraft.sh + setup_minecraft_lxc.sh
   - If OpenJDK 21 is missing on **Debian 13**, add fallback: install Amazon Corretto 21 via APT with
     /usr/share/keyrings keyring and signed-by pin.
   - Auto-size JVM memory from /proc/meminfo: -Xms = 1/4, -Xmx = 1/2 of RAM (min 1G/2G).
   - Ensure /run/screen exists (chmod 775, root:utmp) before screen -dmS.

2) setup_bedrock.sh
   - Regex for artifact: bedrock-server-[0-9.]+\.zip
   - HEAD check: Content-Type must be application/zip before download.
   - Enforce checksum by default: REQUIRE_BEDROCK_SHA=1 and REQUIRED_BEDROCK_SHA256 mandatory.
   - Create /run/screen as above.

3) minecraft.service
   - Run as User/Group=minecraft.
   - Hardening: NoNewPrivileges=true, ProtectSystem=full, ProtectHome=true, PrivateTmp=true,
     ProtectKernelTunables=true, ProtectKernelModules=true, ProtectControlGroups=true,
     RestrictSUIDSGID=true, RestrictNamespaces=true, CapabilityBoundingSet=,
     AmbientCapabilities=, ReadWritePaths=/opt/minecraft.

4) Backups
   - Add RETAIN_DAYS env default=7 and ExecStartPost cleanup with:
     find "${BACKUP_DIR}" -type f -name "*.tar.gz" -mtime +"${RETAIN_DAYS}" -delete

5) Docs
   - Update README with: Java 21 requirement + Corretto fallback on Debian 13; UFW install before ufw commands;
     memory auto-sizing note; Bedrock checksum enforcement note.
   - Ensure this COPILOT_RUN_INSTRUCTIONS.md is linked from README.

Constraints:
- Produce only one file: refactor.diff (unified diff).
- Touch only the files above + README.md + this COPILOT_RUN_INSTRUCTIONS.md as needed.
- Keep changes minimal and consistent with current style.
'
```

### 3) Diff speichern/prüfen

```bash
ls -lh refactor.diff || nano refactor.diff
```

### 4) Diff anwenden & committen

```bash
git apply -p0 refactor.diff
git status
git add -A
git commit -m "refactor: Debian 13 Corretto fallback, RAM autosize, Bedrock checksum, systemd hardening, docs"
```

### 5) Rückweg bei Problemen

```bash
git restore -SW :/
git reset --hard HEAD
```

### 6) Push & PR

```bash
git push -u origin copilot/refactor
gh pr create --fill --title "Refactor: Debian 13 + hardening" --body "Automated diff per COPILOT_RUN_INSTRUCTIONS.md"
```

---

## Hinweise

* **Debian 13**: Corretto-Fallback (APT repo + keyring) aktivieren, wenn `openjdk-21-jre-headless` nicht verfügbar ist.
* `screen`: vor Nutzung `/run/screen` mit `root:utmp` und `775` sicherstellen.
* **Bedrock**: Standardmäßig Checksumme erzwingen (`REQUIRE_BEDROCK_SHA=1`); bekannten SHA in `REQUIRED_BEDROCK_SHA256` setzen.
* **Firewall**: UFW ggf. zuerst installieren (`sudo apt-get install -y ufw`), dann Ports freigeben.
