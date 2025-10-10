# Copilot Run Instructions – Minecraft Server on Proxmox

US English only. This guide defines a single‑prompt Copilot CLI workflow to produce a unified diff, apply it, lint scripts, verify the systemd unit, and open a PR.

## Prerequisites

- Git, GitHub CLI, and Copilot CLI installed and authenticated
- You are inside your local clone of this repository

```bash
cd "$HOME/github_repos/minecraft-server-Proxmox"
git status
```

---

## One‑Prompt Workflow

1) Create or switch to a working branch

```bash
git switch -c copilot/refactor || git switch copilot/refactor
```

2) Ask Copilot to generate a single unified diff

```bash
gh copilot chat -p '
Refactor this repo and output only one unified diff named maint_audit.clean.patch (git apply -p0 friendly). Scope:

1) setup_minecraft.sh + setup_minecraft_lxc.sh
   - Prefer OpenJDK 21; if missing, fallback to Amazon Corretto 21 via APT with /usr/share/keyrings/corretto.gpg and signed-by.
   - Auto-size memory from /proc/meminfo: Xms=RAM/4 (min 256M), Xmx=RAM/2 (min 448M, max 16384M).
   - Ensure /run/screen exists (root:utmp, 0775) and tmpfiles persistence. No sudo in LXC variant.
   - Download Paper via full API URLs; curl/wget with retry; verify upstream SHA256; fail if <5MB or mismatch.
   - start.sh uses /usr/bin/java if present; systemd when USE_SYSTEMD=1, else screen.

2) setup_bedrock.sh
   - English messages. HEAD check must allow application/zip or application/octet-stream.
   - Enforce REQUIRE_BEDROCK_SHA=1 and require REQUIRED_BEDROCK_SHA256 unless overridden; print actual SHA; unzip -tq before extract.
   - Ensure /run/screen and start a detached screen session.

3) minecraft.service
   - User/Group=minecraft; WorkingDirectory=/opt/minecraft; ExecStart=/opt/minecraft/start.sh
   - Hardening: NoNewPrivileges=true; ProtectSystem=full; ProtectHome=true; PrivateTmp=true; ProtectKernelTunables=true; ProtectKernelModules=true; ProtectControlGroups=true; RestrictSUIDSGID=true; RestrictNamespaces=true; CapabilityBoundingSet=; AmbientCapabilities=; ReadWritePaths=/opt/minecraft

4) update.sh
   - Use full Paper API URLs; retry; verify SHA256; fail if <5MB; print final version/build.

5) Docs
   - README: single Requirements list (Java 21 + Corretto fallback), Quick Links, and English-only sections.
   - SIMULATION.md: clearly state simulation-only workspace.
   - SERVER_COMMANDS.md: remove emojis from headings.

Constraints:
- Produce one file: maint_audit.clean.patch (unified diff).
- Keep changes minimal and consistent with current style.
'
```

3) Apply the diff

```bash
git apply -p0 maint_audit.clean.patch
```

4) Lint shell scripts locally (same as CI)

```bash
shopt -s globstar
shellcheck -S warning *.sh **/*.sh
```

5) Verify systemd unit fields

```bash
rg -n "^ExecStart|^User=|^Group=|^WorkingDirectory=" minecraft.service
```

6) Commit, push, and open a PR

```bash
git add -A
git commit -m "refactor: Java 21 + Corretto fallback, SHA checks, autosize, hardening, docs"
git push -u origin copilot/refactor
gh pr create --fill --title "Refactor: Java 21 + hardening" --body "Automated diff per copilot-instructions.md"
```

