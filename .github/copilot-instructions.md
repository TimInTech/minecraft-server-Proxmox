# Copilot Run Instructions – Minecraft Server on Proxmox (Simulation Mode)

## Zweck
Nur erklären und Änderungen als **Diff** erzeugen. **Keine** Skripte ausführen. **Kein Build**. Ziel ist ein durchgängiger CLI-Ablauf mit GitHub Copilot CLI.

## Voraussetzungen
1) Git, GitHub CLI und Copilot CLI sind eingerichtet.  
2) Du arbeitest im Repo-Klon.

```bash
cd "$HOME/github_repos/minecraft-server-Proxmox"
git status
````

---

## Antworten auf „Run/Build?“

Immer Simulation. Nur Beispiele zeigen, nichts lokal ausführen.

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

> Diese Befehle sind **Beispiele** für externe Systeme. In dieser Umgebung nur erklären. Details siehe `SIMULATION.md`.

---

## Safe-Workflow mit Copilot CLI

### 1) Arbeitszweig vorbereiten

```bash
cd "$HOME/github_repos/minecraft-server-Proxmox"
git switch -c copilot/refactor-sim || git switch copilot/refactor-sim
```

### 2) Audit + Refactor per Ein-Prompt (nur Diff ausgeben lassen)

```bash
gh copilot chat -p '
Refactor this repo in SIMULATION ONLY. Do not execute anything. Output a single unified diff file named refactor.diff (git apply -p0 friendly). Scope:

1) setup_minecraft.sh + setup_minecraft_lxc.sh
   - If OpenJDK 21 missing on Debian 12, add fallback: install Amazon Corretto 21 via APT with /usr/share/keyrings keyring and signed-by pin.
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
   - Add RETAIN_DAYS env default=7 and ExecStartPost cleanup with find … -mtime +$RETAIN_DAYS -delete.

5) Docs
   - Create COPILOT_RUN_INSTRUCTIONS.md (this file) summary link in README.
   - README: mention Java 21 requirement with Corretto fallback, UFW install before ufw commands, memory auto-sizing note,
     Bedrock checksum enforcement note, and link to SIMULATION.md.

Constraints:
- Do NOT run or simulate shell in this environment. Produce only a single file: refactor.diff.
- Touch only the files above + README.md + new COPILOT_RUN_INSTRUCTIONS.md as needed.
- Keep changes minimal and consistent with current style.
'
```

### 3) Diff holen und prüfen

Copilot legt die Datei an oder zeigt sie an. Wenn als Datei erstellt:

```bash
ls -lh refactor.diff
```

Wenn nur als Chat-Ausgabe kam, speichere sie:

```bash
nano refactor.diff
# Inhalt aus der Copilot-Antwort einfügen, speichern
```

### 4) Diff anwenden und committen

```bash
git apply -p0 refactor.diff
git status
git add -A
git commit -m "refactor(simulation): Corretto21 fallback, RAM autosize, Bedrock checksum, systemd hardening, docs"
```

### 5) Rückweg bei Problemen

```bash
git restore -SW :/
git reset --hard HEAD
```

### 6) Push und PR (optional)

```bash
git push -u origin copilot/refactor-sim
gh pr create --fill --title "Refactor (simulation)" --body "Simulation-mode changes per COPILOT_RUN_INSTRUCTIONS.md"
```

---

## Hinweise

* Keine lokalen Installationen anstoßen. Copilot erzeugt **nur** einen Diff.
* In Antworten immer klarstellen: Beispiele dienen externer Ausführung.
* Für Schritt-für-Schritt-Effekte der Skripte siehe `SIMULATION.md`.
* CI-Erweiterungen (ShellCheck, Markdown-Lint, Link-Check) bitte in separatem PR ergänzen.


::contentReference[oaicite:0]{index=0}

