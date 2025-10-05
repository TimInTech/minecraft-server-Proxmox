#!/usr/bin/env bash
set -euo pipefail
STORE="${STORE:-local}"
CTID="${CTID:-121}"
MEM="${MEM:-2048}"
pveam update
TPL=$(pveam available | awk '/debian-12-standard_.*_amd64\.tar\.(zst|gz)$/ {n=$2} END{print n}')
[ -z "$TPL" ] && { echo "No Debian-12 template found"; exit 1; }
pveam download "$STORE" "$TPL"
pct create "$CTID" "${STORE}:vztmpl/${TPL}"   -hostname mc-bedrock -cores 2 -memory "$MEM" -swap 512   -rootfs local-lvm:8 -net0 name=eth0,bridge=vmbr0,ip=dhcp   -features keyctl=1,nesting=1 -unprivileged 0 -password 'changeme'
pct start "$CTID"
pct exec "$CTID" -- bash -lc '
  apt update && apt -y install wget curl
  wget -qO /root/setup_bedrock.sh https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox.git/main/setup_bedrock.sh
  bash /root/setup_bedrock.sh
'
echo "CT $CTID ready. Change password. Attach: pct enter $CTID"
