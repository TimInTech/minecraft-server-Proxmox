# Repository Guidelines

## Project Structure & Module Organization
- Root scripts: `setup_minecraft.sh`, `setup_minecraft_lxc.sh`, `setup_bedrock.sh`, `update.sh` (installers/updater).
- Service: `minecraft.service` (systemd unit for Java server).
- Helpers: `scripts/` (e.g., `scripts/proxmox_create_ct_bedrock.sh`).
- Docs & assets: `docs/` (guides), `assets/` (images), `SERVER_COMMANDS.md`, `SIMULATION.md`.
- CI & templates: `.github/` (ShellCheck workflow, PR template).

## Build, Test, and Development Commands
- Lint shell scripts locally (same as CI):
  ```bash
  shopt -s globstar
  shellcheck -S warning *.sh **/*.sh
  ```
- Quick syntax check:
  ```bash
  bash -n setup_minecraft.sh
  ```
- Simulation-only in this workspace: do not execute installers here. On a target host, for example:
  ```bash
  chmod +x setup_minecraft.sh && ./setup_minecraft.sh
  ```

## Coding Style & Naming Conventions
- Bash with `set -euo pipefail` at top; 2-space indentation.
- Quote variables, use `$(...)`, prefer idempotent commands (e.g., `install -d`).
- Names: ENV in UPPER_SNAKE (`MC_VER`, `REQUIRE_BEDROCK_SHA`); functions in lower_snake (`ensure_java`); files `setup_*.sh`, `start.sh`.
- Systemd units: run as `minecraft`, include hardening directives.

## Testing Guidelines
- No unit tests; CI runs ShellCheck on PRs.
- Locally: run ShellCheck and `bash -n`; document effects in `SIMULATION.md`.
- Networked downloads must be verified (size sanity > 5 MB and SHA256). Bedrock requires `REQUIRED_BEDROCK_SHA256` unless `REQUIRE_BEDROCK_SHA=0`.

## Commit & Pull Request Guidelines
- Use Conventional Commits seen in history: `feat(java): message`, `fix: message`, `docs: message`, `maint: message`, `harden(bedrock): message`.
- One focused change per PR. Include description, security considerations, example commands, and update `SIMULATION.md`.
- Use `.github/pull_request_template.md`. Link related issues; console snippets beat screenshots.

## Security & Configuration Tips
- Prefer systemd over `screen`; if using screen, ensure `/run/screen` exists (`root:utmp`, `0775`).
- Open only required ports: `25565/tcp` (Java), `19132/udp` (Bedrock).
- Keep services non-root; use systemd hardening (e.g., `NoNewPrivileges`, `ProtectSystem=full`).
- Validate external URLs and MIME types before downloading.

## Agent-Specific Instructions
- Do not execute scripts in this workspace; show and explain commands only.
- Preserve existing structure and naming; keep ShellCheck passing; verify downloads and update docs accordingly.

