#!/usr/bin/env bash
# Provision an unprivileged Ubuntu LXC (CT) for Minecraft on Proxmox.
# Requires: run on Proxmox node as root; tools: pct, pveam
# Example:
# sudo ./proxmox_ct_provision.sh --ctid 12650 --hostname mc-ct --cores 4 --memory 8192 --disk 16 --bridge vmbr0 --storage local-lvm --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh"

set -euo pipefail
err(){ echo "ERROR: $*" >&2; exit 1; }
info(){ echo "[*] $*"; }
need(){ command -v "$1" >/dev/null 2>&1 || err "Missing command: $1"; }

CTID=""
HOSTNAME="mc-ct"
CORES=4
MEM=8192
DISK=16
BRIDGE="vmbr0"
STORAGE="local-lvm"
TEMPLATE="ubuntu-24.04-standard_24.04-1_amd64.tar.zst"
POST_INSTALL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ctid) CTID="$2"; shift 2;;
    --hostname) HOSTNAME="$2"; shift 2;;
    --cores) CORES="$2"; shift 2;;
    --memory) MEM="$2"; shift 2;;
    --disk) DISK="$2"; shift 2;;
    --bridge) BRIDGE="$2"; shift 2;;
    --storage) STORAGE="$2"; shift 2;;
    --template) TEMPLATE="$2"; shift 2;;
    --post-install) POST_INSTALL="$2"; shift 2;;
    *) err "Unknown option: $1";;
  esac
done

[[ -n "${CTID}" ]] || err "--ctid is required"
[[ "$(id -u)" -eq 0 ]] || err "Run as root."
need pct; need pveam

# Ensure template available
if ! pveam available | awk '{print $2}' | grep -qx "${TEMPLATE}"; then
  info "Refreshing template list…"
  pveam update
fi
TSTORE="local"
if [[ ! -f "/var/lib/vz/template/cache/${TEMPLATE}" ]]; then
  info "Downloading template: ${TEMPLATE}"
  pveam download "${TSTORE}" "${TEMPLATE}"
else
  info "Template present: ${TEMPLATE}"
fi

# Create CT
info "Creating CT ${CTID} (${HOSTNAME})"
pct create "${CTID}" "local:vztmpl/${TEMPLATE}" \
  -hostname "${HOSTNAME}" \
  -cores "${CORES}" -memory "${MEM}" -rootfs "${STORAGE}:${DISK}" \
  -net0 "name=eth0,bridge=${BRIDGE},ip=dhcp" \
  -features "nesting=1,keyctl=1" \
  -unprivileged 1

pct start "${CTID}"

# Optional post-install inside CT
if [[ -n "${POST_INSTALL}" ]]; then
  info "Running post-install in CT"
  pct exec "${CTID}" -- bash -lc "apt-get update -y && apt-get install -y curl wget nano screen unzip git openjdk-21-jre-headless ufw"
  pct exec "${CTID}" -- bash -lc "wget -O /root/setup_minecraft_lxc.sh '${POST_INSTALL}' && chmod +x /root/setup_minecraft_lxc.sh && /root/setup_minecraft_lxc.sh"
fi

ip="$(pct exec "${CTID}" -- bash -lc "hostname -I | awk '{print \$1}'" || true)"
[[ -n "${ip}" ]] && info "CT IP: ${ip}" || echo "[!] Could not determine CT IP yet."
echo "Done."
