#!/usr/bin/env bash
# Version 2.0 – Überarbeitetes Provisioning-Skript für Ubuntu Cloud-Init VMs auf Proxmox
# Autor: TimInTech (angepasst durch Copilot)
# Datum: 2025-09-02
#
# Hinweis: Dieses Skript muss als root ausgeführt werden (ohne sudo). Es prüft aktiv, ob
#        der Benutzer root ist und bricht ansonsten ab.
#
# Zweck:
# - Erzeugt / klont ein Template aus einem Ubuntu cloud-image (noble/jammy/focal)
# - Klont das Template in eine neue VM und konfiguriert CPUs, RAM, Disk, Netzwerk, cloud-init
# - Optional: erstellt ein 'dir' Storage für snippets, falls die gewählte Storage keine snippets unterstützt
# - Optional: schreibt eine user-data snippet mit einem POST-INSTALL Script (cloud-init)
#
# Sicherheits-/Qualitätsregeln:
# - set -euo pipefail
# - Keine hardcodierten Secrets
# - Klare Fehlermeldungen (Deutsch)
#
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
SNIPPETS_STORE=""
SNIPPETS_PATH="/var/lib/vz/snippets"
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
ENSURE_SNIPPETS=0

usage(){
  cat <<EOF
Usage: $0 [options]

Wichtig: Dieses Skript muss als root ausgeführt werden (ohne sudo).

Optionen:
  --vmid ID                 VMID (erforderlich)
  --name NAME               VM Name (erforderlich)
  --cores N                 CPU-Kerne (default: ${CORES})
  --memory MB               RAM in MB (default: ${MEM})
  --disk GB                 Disk size in GB (default: ${DISK})
  --bridge BR               Netzwerkbridge (default: ${BRIDGE})
  --storage STORE           Primary storage (z.B. local-lvm) (default: ${STORAGE})
  --snippets-store STORE    Storage-ID to use for snippets (falls leer: gleiche wie --storage)
  --snippets-path PATH      Pfad für snippets dir (default: ${SNIPPETS_PATH})
  --ensure-snippets         Wenn gesetzt: erstelle ein dir-Storage für snippets falls nötig
  --ssh-key PATH            Pfad zur öffentlichen SSH-Key-Datei (default: ${SSH_KEY})
  --post-install URL        URL eines post-install scripts (wird via cloud-init ausgeführt)
  --ip IP/CIDR              Static IP (z.B. 192.168.1.50/24) - schaltet DHCP aus
  --gw IP                   Gateway (bei static IP erforderlich)
  --dns IP                  Nameserver (bei static IP optional)
  --image-version VER       noble|jammy|focal (default: ${IMAGE_VERSION})
  --image-url URL           Alternative Bild-URL
  --log FILE                Log-Datei
  --ciuser USER             Cloud-init username (default: ${CIUSER})
  --cipass PASS             Cloud-init password (optional)
  -h, --help                This help

Beispiel:
  # als root (ohne sudo) ausführen
  ./proxmox_vm_provision.sh --vmid 19265 --name mc-vm --cores 4 --memory 8192 --disk 32 \
    --bridge vmbr0 --storage local-lvm --ssh-key /root/.ssh/id_rsa.pub \
    --post-install "https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh" \
    --ensure-snippets
EOF
}

# --- parse args ---
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
    --snippets-path) SNIPPETS_PATH="$2"; shift 2;;
    --ensure-snippets) ENSURE_SNIPPETS=1; shift 1;;
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
    -h|--help) usage; exit 0;;
    *) err "Unknown option: $1";;
  esac
done

: "${SNIPPETS_STORE:=${STORAGE}}"

[[ -n "${VMID}" ]]   || err "--vmid is required"
[[ -n "${VMNAME}" ]] || err "--name is required"
[[ -f "${SSH_KEY}" ]] || err "SSH key not found: ${SSH_KEY}"

# Ensure running as root (explicit: ohne sudo)
if [[ "$(id -u)" -ne 0 ]]; then
  err "Dieses Skript muss als root ausgeführt werden (ohne sudo). Bitte root werden (z.B. 'su -') und erneut ausführen."
fi

need qm; need pvesm; need wget; need timeout

pvesm status >/dev/null || err "pvesm nicht verfügbar oder pvesm status schlägt fehl"
pvesm status | awk '{print $1}' | grep -qx "${STORAGE}" || err "Storage '${STORAGE}' nicht gefunden"
pvesm status | awk '{print $1}' | grep -qx "${SNIPPETS_STORE}" || true

# Helper: check storage existence and snippets support
storage_exists(){ pvesm status | awk '{print $1}' | grep -qx "$1"; }
storage_supports_snippets(){
  pvesm config "$1" 2>/dev/null | grep -qE '(^|[[:space:]])content.*\bsnippets\b' || return 1
}

info "Snippets store: ${SNIPPETS_STORE} (ensure-snippets=${ENSURE_SNIPPETS})"

# If snippets store exists, ensure it supports snippets or create new dir-storage if allowed
if storage_exists "${SNIPPETS_STORE}"; then
  if storage_supports_snippets "${SNIPPETS_STORE}"; then
    info "Snippets werden von '${SNIPPETS_STORE}' unterstützt."
  else
    if [[ "${ENSURE_SNIPPETS}" -eq 1 ]]; then
      NEW_SNIPPETS="${SNIPPETS_STORE}-snippets"
      i=0
      while storage_exists "${NEW_SNIPPETS}"; do
        i=$((i+1))
        NEW_SNIPPETS="${SNIPPETS_STORE}-snippets-${i}"
      done
      info "Storage '${SNIPPETS_STORE}' unterstützt keine snippets. Erstelle '${NEW_SNIPPETS}' unter '${SNIPPETS_PATH}'."
      mkdir -p "${SNIPPETS_PATH}"
      chown root:root "${SNIPPETS_PATH}"
      chmod 755 "${SNIPPETS_PATH}"
      pvesm add dir "${NEW_SNIPPETS}" --path "${SNIPPETS_PATH}" --content snippets || err "pvesm add dir für ${NEW_SNIPPETS} fehlgeschlagen"
      SNIPPETS_STORE="${NEW_SNIPPETS}"
      info "Snippets-Storage erstellt: ${SNIPPETS_STORE}"
    else
      err "Storage '${SNIPPETS_STORE}' unterstützt keine snippets. Nutze --ensure-snippets um ein snippets dir-Storage erstellen zu lassen oder wähle einen anderen Storage."
    fi
  fi
else
  # storage not present
  if [[ "${ENSURE_SNIPPETS}" -eq 1 ]]; then
    info "Snippets-Storage '${SNIPPETS_STORE}' nicht vorhanden. Erstelle dir-Storage unter '${SNIPPETS_PATH}'."
    mkdir -p "${SNIPPETS_PATH}"
    chown root:root "${SNIPPETS_PATH}"
    chmod 755 "${SNIPPETS_PATH}"
    pvesm add dir "${SNIPPETS_STORE}" --path "${SNIPPETS_PATH}" --content snippets || err "pvesm add dir für ${SNIPPETS_STORE} fehlgeschlagen"
    info "Snippets-Storage erstellt: ${SNIPPETS_STORE}"
  else
    err "Snippets-Storage '${SNIPPETS_STORE}' nicht gefunden. Setze --ensure-snippets oder erstelle einen Storage mit content=snippets in Proxmox."
  fi
fi

# final check
storage_supports_snippets "${SNIPPETS_STORE}" || err "Storage '${SNIPPETS_STORE}' unterstützt keine snippets (auch nach Erstellung nicht)."

! qm status "${VMID}" &>/dev/null || err "VMID ${VMID} existiert bereits"

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
  info "Cloud-Image herunterladen: ${IMAGE_VERSION}"
  wget -O "${IMAGE_FILE}" "${IMAGE_URL}"
else
  info "Cloud-Image vorhanden: ${IMAGE_FILE}"
fi

# Create template if missing
if ! qm status "${TEMPLATE_ID}" &>/dev/null; then
  info "Erstelle Template ${TEMPLATE_ID} (${TEMPLATE_NAME})"
  qm create "${TEMPLATE_ID}" --name "${TEMPLATE_NAME}" --memory 4096 --cores 2 --cpu host --net0 virtio,bridge="${BRIDGE}"
  qm importdisk "${TEMPLATE_ID}" "${IMAGE_FILE}" "${STORAGE}"
  qm set "${TEMPLATE_ID}" --scsihw virtio-scsi-pci --scsi0 "${STORAGE}:vm-${TEMPLATE_ID}-disk-0"
  qm set "${TEMPLATE_ID}" --ide2 "${STORAGE}:cloudinit" --boot c --bootdisk scsi0 --serial0 socket --vga serial0
  qm set "${TEMPLATE_ID}" --agent 1
  qm template "${TEMPLATE_ID}"
else
  info "Template existiert: ${TEMPLATE_ID} – überspringe Erstellung"
fi

info "Cloning ${VMID} (${VMNAME}) from template ${TEMPLATE_ID}"
qm clone "${TEMPLATE_ID}" "${VMID}" --name "${VMNAME}"

info "Set VM resources and devices"
qm set "${VMID}" --cores "${CORES}" --memory "${MEM}"
qm set "${VMID}" --scsi0 "${STORAGE}:${DISK}"
qm set "${VMID}" --net0 virtio,bridge="${BRIDGE}"
qm set "${VMID}" --sshkeys "${SSH_KEY}" --ciuser "${CIUSER}"
[[ -n "${CIPASS}" ]] && qm set "${VMID}" --cipassword "${CIPASS}"

if [[ "${IP_DHCP}" -eq 1 ]]; then
  qm set "${VMID}" --ipconfig0 ip=dhcp
else
  [[ -n "${IP_SPEC}" && -n "${GW_SPEC}" ]] || err "Static IP benötigt --ip und --gw"
  [[ -n "${DNS_SPEC}" ]] && qm set "${VMID}" --nameserver "${DNS_SPEC}"
  qm set "${VMID}" --ipconfig0 "ip=${IP_SPEC},gw=${GW_SPEC}"
fi

if [[ -n "${POST_INSTALL}" ]]; then
  mkdir -p "${SNIPPETS_PATH}"
  SNIPPET="${SNIPPETS_PATH}/mc-user-data-${VMID}-$(date +%Y%m%d%H%M%S).yaml"
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
  # Install snippet into Proxmox snippets store
  qm set "${VMID}" --cicustom "user=${SNIPPETS_STORE}:snippets/$(basename "${SNIPPET}")"
  info "Cloud-init user-data snippet erstellt: ${SNIPPET} -> ${SNIPPETS_STORE}:snippets/$(basename "${SNIPPET}")"
fi

info "Start VM ${VMID}"
qm start "${VMID}"

get_vm_ip(){
  local ip out
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

if ip="$(get_vm_ip)"; then info "VM IP: ${ip}"; else echo "[!] Konnte VM IP noch nicht ermitteln."; fi
echo "Done."
