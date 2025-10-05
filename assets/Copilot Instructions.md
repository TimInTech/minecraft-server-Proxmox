# Copilot Run Instructions – Minecraft Server on Proxmox

## Context

This repository contains **shell scripts** (not a buildable project).  
There is **no `build` task**. Instead, users select one of the install/update scripts below and run it directly in a shell.

## Execution Options

When asked “Run/Build”, provide these options instead:

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

* Options 1–3 will run `apt` installs and make system changes.
* Only show these five options; do **not** suggest any `build`/`compile` steps.
* Always show the full runnable shell commands (`chmod +x` before execution).

