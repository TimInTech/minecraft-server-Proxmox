# Repository Guidelines

This repository provisions Minecraft servers (Java and Bedrock) on Proxmox VMs/LXCs using Bash scripts and a hardened systemd unit.

## Project Structure & Module Organization
- Root scripts: `setup_minecraft.sh`, `setup_minecraft_lxc.sh`, `setup_bedrock.sh`, `update.sh`
- Service unit: `minecraft.service` (runs as `minecraft`, hardening enabled)
- Helpers: `scripts/` (e.g., `scripts/proxmox_create_ct_bedrock.sh`)
- Docs & assets: `README.md`, `SIMULATION.md`, `SERVER_COMMANDS.md`, `docs/`, `assets/`
- CI & templates: `.github/` (ShellCheck workflow, PR template)

## Build, Test, and Development Commands
- Lint all shell scripts (same as CI):
  ```bash
  shopt -s globstar
  shellcheck -S warning *.sh **/*.sh
  ```
- Quick syntax check for a script:
  ```bash
  bash -n setup_minecraft.sh
  ```
- Simulation-only here: do not execute installers in this workspace. On a target host:
  ```bash
  chmod +x setup_minecraft.sh && ./setup_minecraft.sh
  ```

## Coding Style & Naming Conventions
- Bash with `set -euo pipefail`; 2-space indentation
- Quote variables; prefer `$(command)`; use idempotent ops (e.g., `install -d`)
- Names: ENV in UPPER_SNAKE (`MC_VER`, `REQUIRE_BEDROCK_SHA`); functions in lower_snake (`ensure_java`)
- Systemd: run as `minecraft`; hardening (e.g., `NoNewPrivileges`, `ProtectSystem=full`)

## Testing Guidelines
- No unit tests; CI runs ShellCheck
- Locally: run ShellCheck and `bash -n`; document behavior in `SIMULATION.md`
- Verify networked downloads (SHA256 and size > 5 MB). Bedrock requires `REQUIRED_BEDROCK_SHA256` unless `REQUIRE_BEDROCK_SHA=0`

## Commit & Pull Request Guidelines
- Conventional Commits (e.g., `feat(java): add updater`, `fix: correct SHA check`, `docs: update README`, `maint: cleanup`, `harden(bedrock): enforce checksum`)
- One focused change per PR; include description, security notes, example commands; update `SIMULATION.md` if behavior changes
- Use `.github/pull_request_template.md`; link related issues; console snippets preferred

## Security & Configuration Tips
- Prefer systemd over `screen`; if using screen, ensure `/run/screen` exists (`root:utmp`, `0775`) and add tmpfiles persistence
- Open only required ports: `25565/tcp` (Java), `19132/udp` (Bedrock)
- Keep services non-root; validate external URLs and MIME types before downloading

## Agent-Specific Instructions
- Do not execute scripts in this workspace; show and explain commands only
- Preserve structure and naming; keep ShellCheck passing; verify downloads and update docs accordingly
