# Contributing (Simulation-Only Workspace)

Thanks for your interest! This repository contains shell scripts to set up Minecraft servers on Proxmox. In this workspace, we do not execute commands or install packages. Contributions should focus on script quality, documentation, and simulated flows.

## Ground rules

- Do not run or install anything on this machine.
- When asked to run, provide commands and explain expected outcomes; do not execute.
- Keep `SIMULATION.md` accurate and up to date.
- Prefer least-privilege and secure defaults in scripts (non-root users for services, explicit permissions).

## How to contribute

1. Fork and create a feature branch.
2. Make changes to scripts and/or docs.
3. Update `SIMULATION.md` to describe effects, risks, and rollback.
4. Open a Pull Request using the provided template.

## Coding style (shell)

- `set -euo pipefail` for safety.
- Quote variables and use `"$(...)"` command substitution.
- Prefer explicit paths and idempotent operations.
- Validate downloads and inputs where practical.

## Security & reliability

- Use non-root service users where possible.
- Consider systemd hardening options when suggesting units.
- Validate downloads (e.g., check HTTP status, basic sanity checks) without running them here.
- Document open ports and network exposure.

## Documentation

- Keep README concise; defer detailed run explanations to `SIMULATION.md`.
- Use fenced code blocks for commands, with `bash` language hints.
- Provide rollback/cleanup steps.

## Reviewing PRs

- Confirm no steps imply local execution.
- Check that all new/changed behavior is reflected in `SIMULATION.md`.
- Ensure examples include `chmod +x` before script invocation.
