#!/usr/bin/env bash
# Provision an Ubuntu Cloud-Init VM for Minecraft on Proxmox.
# Requires: run on Proxmox node as root; tools: qm, pvesm, wget, timeout
# Example (DHCP):
# sudo ./proxmox_vm_provision.sh --vmid 19265 --name mc-vm --cores 4 --memory 8192 --disk 32 --bridge vmbr0 --storage local-lvm --ssh-key /root/.ssh/id_rsa.pub --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh"
# Example (static IP):
# sudo ./proxmox_vm_provision.sh --vmid 19265 --name mc-vm --cores 4 --memory 8192 --disk 32 --bridge vmbr0 --storage local-lvm --ssh-key /root/.ssh/id_rsa.pub --ip 192.168.1.50/24 --gw 192.168.1.1 --dns 1.1.1.1 --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh"

set -euo pipefail
err(){ echo "ERROR: $*" >&2; exit 1; }
info(){ echo "[*] $*"; }
need(){ command -v "$1" >/dev/null 2>&1 || err "Missing command: $1"; }

# Defaults
TEMPLATE_ID=9024
TEMPLATE_NAME="mc-vm-template"
IMAGE_VERSION="noble" # noble|jammy|focal
IMAGE_URL=""
IMAGE_FILE="/var/lib/vz/template/iso/ubuntu-cloudimg-amd64.img"
STORAGE="local-lvm"
SNIPPETS_STORE="local"
BRIDGE="vmbr0"
CORES=4
MEM=8192
DISK=32
SSH_KEY="/root/.ssh/id_rsa.pub"
CIUSER="ubuntu"
CIPASS=""
VMID=""
VMNAME=""
POST_INSTALL=""
IP_DHCP=1
IP_SPEC=""
GW_SPEC=""
DNS_SPEC=""
LOG_FILE=""

# Args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vmid) VMID="$2"; shift 2;;
    --name) VMNAME="$2"; shift 2;;
    --cores) CORES="$2"; shift 2;;
    --memory) MEM="$2"; shift 2;;
    --disk) DISK="$2"; shift 2;;
    --bridge) BRIDGE="$2"; shift 2;;
    --storage) STORAGE="$2"; shift 2;;
    --snippets-store) SNIPPETS_STORE="$2"; shift 2;;
    --ssh-key) SSH_KEY="$2"; shift 2;;
    --template-id) TEMPLATE_ID="$2"; shift 2;;
    --template-name) TEMPLATE_NAME="$2"; shift 2;;
    --image-version) IMAGE_VERSION="$2"; shift 2;;
    --image-url) IMAGE_URL="$2"; shift 2;;
    --ciuser) CIUSER="$2"; shift 2;;
    --cipass) CIPASS="$2"; shift 2;;
    --post-install) POST_INSTALL="$2"; shift 2;;
    --ip) IP_DHCP=0; IP_SPEC="$2"; shift 2;;
    --gw) GW_SPEC="$2"; shift 2;;
    --dns) DNS_SPEC="$2"; shift 2;;
    --log) LOG_FILE="$2"; shift 2;;
    *) err "Unknown option: $1";;
  esac
done

[[ -n "${VMID}" ]]   || err "--vmid is required"
[[ -n "${VMNAME}" ]] || err "--name is required"
[[ -f "${SSH_KEY}" ]]|| err "SSH key not found: ${SSH_KEY}"
[[ "$(id -u)" -eq 0 ]] || err "Run as root."

need qm; need pvesm; need wget; need timeout

pvesm status >/dev/null || err "pvesm not working"
pvesm status | awk '{print $1}' | grep -qx "${STORAGE}" || err "Storage '${STORAGE}' not found"
pvesm status | awk '{print $1}' | grep -qx "${SNIPPETS_STORE}" || err "Snippets store '${SNIPPETS_STORE}' not found"
if ! pvesm status --verbose 2>/dev/null | awk -v s="${SNIPPETS_STORE}" '$1==s && /content:.*snippets/ {f=1} END{exit f?0:1}'; then
  err "Storage '${SNIPPETS_STORE}' does not support snippets"
fi
! qm status "${VMID}" &>/dev/null || err "VMID ${VMID} already exists"

if [[ -z "${IMAGE_URL}" ]]; then
  case "${IMAGE_VERSION}" in
    noble|jammy|focal) IMAGE_URL="https://cloud-images.ubuntu.com/${IMAGE_VERSION}/current/${IMAGE_VERSION}-server-cloudimg-amd64.img";;
    *) err "--image-version must be noble|jammy|focal";;
  esac
fi

if [[ -n "${LOG_FILE}" ]]; then
  mkdir -p "$(dirname "${LOG_FILE}")"
  exec >>"${LOG_FILE}" 2>&1
  echo "=== VM provision $(date -Iseconds) ==="
fi

mkdir -p "$(dirname "${IMAGE_FILE}")"
if [[ ! -f "${IMAGE_FILE}" ]]; then
  info "Downloading cloud image: ${IMAGE_VERSION}"
  wget -O "${IMAGE_FILE}" "${IMAGE_URL}"
else
  info "Cloud image present: ${IMAGE_FILE}"
fi

# Create template if missing
if ! qm status "${TEMPLATE_ID}" &>/dev/null; then
  info "Creating template ${TEMPLATE_ID} (${TEMPLATE_NAME})"
  qm create "${TEMPLATE_ID}" --name "${TEMPLATE_NAME}" --memory 4096 --cores 2 --cpu host --net0 virtio,bridge="${BRIDGE}"
  qm importdisk "${TEMPLATE_ID}" "${IMAGE_FILE}" "${STORAGE}"
  qm set "${TEMPLATE_ID}" --scsihw virtio-scsi-pci --scsi0 "${STORAGE}:vm-${TEMPLATE_ID}-disk-0"
  qm set "${TEMPLATE_ID}" --ide2 "${STORAGE}:cloudinit" --boot c --bootdisk scsi0 --serial0 socket --vga serial0
  qm set "${TEMPLATE_ID}" --agent 1
  qm template "${TEMPLATE_ID}"
else
  info "Template exists: ${TEMPLATE_ID} – skip"
fi

info "Cloning ${VMID} (${VMNAME})"
qm clone "${TEMPLATE_ID}" "${VMID}" --name "${VMNAME}"

qm set "${VMID}" --cores "${CORES}" --memory "${MEM}"
qm set "${VMID}" --scsi0 "${STORAGE}:${DISK}"
qm set "${VMID}" --net0 virtio,bridge="${BRIDGE}"
qm set "${VMID}" --sshkeys "${SSH_KEY}" --ciuser "${CIUSER}"
[[ -n "${CIPASS}" ]] && qm set "${VMID}" --cipassword "${CIPASS}"

if [[ "${IP_DHCP}" -eq 1 ]]; then
  qm set "${VMID}" --ipconfig0 ip=dhcp
else
  [[ -n "${IP_SPEC}" && -n "${GW_SPEC}" ]] || err "Static IP requires --ip and --gw"
  [[ -n "${DNS_SPEC}" ]] && qm set "${VMID}" --nameserver "${DNS_SPEC}"
  qm set "${VMID}" --ipconfig0 "ip=${IP_SPEC},gw=${GW_SPEC}"
fi

if [[ -n "${POST_INSTALL}" ]]; then
  mkdir -p /var/lib/vz/snippets
  SNIPPET="/var/lib/vz/snippets/mc-user-data-${VMID}-$(date +%Y%m%d%H%M%S).yaml"
  cat > "${SNIPPET}" <<EOF
#cloud-config
package_update: true
packages: [curl, wget, nano, screen, unzip, git, openjdk-21-jre-headless, ufw]
runcmd:
  - [ ufw, allow, 25565/tcp ]
  - [ bash, -lc, "cd /root && wget -O setup_minecraft.sh '${POST_INSTALL}'" ]
  - [ bash, -lc, "chmod +x /root/setup_minecraft.sh" ]
  - [ bash, -lc, "/root/setup_minecraft.sh" ]
  - [ systemctl, enable, --now, minecraft ]
EOF
  qm set "${VMID}" --cicustom "user=${SNIPPETS_STORE}:snippets/$(basename "${SNIPPET}")"
fi

info "Starting VM ${VMID}"
qm start "${VMID}"

get_vm_ip(){
  for _ in {1..30}; do
    sleep 5
    if out="$(qm guest cmd "${VMID}" network-get-interfaces 2>/dev/null)"; then
      if command -v jq >/dev/null; then
        ip="$(echo "$out" | jq -r '.[]?."ip-addresses"?[]?|select(.["ip-address-type"]=="ipv4")|.address' | grep -v '^169\.' | head -n1)"
      else
        ip="$(echo "$out" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^169\.' | head -n1)"
      fi
      [[ -n "${ip:-}" ]] && { echo "$ip"; return 0; }
    fi
  done
  return 1
}

if ip="$(get_vm_ip)"; then info "VM IP: ${ip}"; else echo "[!] Could not determine VM IP yet."; fi
echo "Done."
