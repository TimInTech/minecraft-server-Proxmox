# Copilot Run Instructions – Minecraft Server on Proxmox (Simulation Mode)

## Context
Do not execute locally. Explain only. Provide simulated steps and risks.

This repository contains **shell scripts** (not a buildable project).  
There is **no `build` task**. In this workspace we operate in **simulation-only mode**: do not execute commands on this machine. When asked to "run", only show and explain the commands; do not actually run them.

## Execution Options

When asked “Run/Build”, provide these options as example commands (explanation/simulation only; do not execute here):

### Option 1: Java server in VM

```bash
chmod +x setup_minecraft.sh
./setup_minecraft.sh
screen -r minecraft
```

### Option 2: Java server in LXC/Container

```bash
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
screen -r minecraft
```

### Option 3: Bedrock server

```bash
chmod +x setup_bedrock.sh
./setup_bedrock.sh
screen -r bedrock
```

### Option 4: Update existing Java server (PaperMC)

```bash
chmod +x update.sh
./update.sh
```

### Option 5 (optional, Java only): Enable systemd auto-start

```bash
sudo cp minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable --now minecraft
```

## Notes

* Options 1–3 perform `apt` installs and system changes — explain but do not execute in this environment.
* Only show these five options; do **not** suggest any `build`/`compile` steps.
* Always show the full shell commands for the user's host (`chmod +x` before execution) but clarify they are examples for external execution.
* For detailed step-by-step effects of each script, refer to `SIMULATION.md`.

