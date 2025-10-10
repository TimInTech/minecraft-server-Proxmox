#!/usr/bin/env bash
set -euo pipefail

# Festlegbare Minecraft-Version (verhindert SNAPSHOT/Pre-Release Überraschungen)
MC_VER="${MC_VER:-1.21.10}"

sudo apt update && sudo apt upgrade -y
sudo apt install -y screen wget curl jq unzip ca-certificates gnupg

ensure_java() {
  # Prefer OpenJDK 21; fallback to Amazon Corretto 21 via APT keyring.
  if sudo apt-get install -y openjdk-21-jre-headless 2>/dev/null; then return; fi
  # Debian 13 Fallback: Amazon Corretto 21 (signiertes Repo)
  sudo install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto.gpg
  echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y java-21-amazon-corretto-jre || sudo apt-get install -y java-21-amazon-corretto-jdk
}

ensure_java

# screen socket dir (Debian erwartet root:utmp) + Persistenz via tmpfiles
sudo install -d -m 0775 -o root -g utmp /run/screen
printf 'd /run/screen 0775 root utmp -\n' | sudo tee /etc/tmpfiles.d/screen.conf >/dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf || true

# Optional: systemd bevorzugen (Fallback: screen)
USE_SYSTEMD="${USE_SYSTEMD:-1}"

# user & dir
if ! id -u minecraft >/dev/null 2>&1; then sudo useradd -r -m -s /bin/bash minecraft; fi
sudo install -d -m 0755 -o minecraft -g minecraft /opt/minecraft
cd /opt/minecraft

# EULA
echo "eula=true" | sudo tee eula.txt >/dev/null

# Download Paper für feste $MC_VER (mit SHA256-Verifikation)
LATEST_BUILD="$(curl -fL --retry 3 --retry-delay 2 -sS "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}" | jq -r '.builds | last')"
BUILD_JSON="$(curl -fL --retry 3 --retry-delay 2 -sS "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}/builds/${LATEST_BUILD}")"
EXPECTED_SHA="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')"
JAR_NAME="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')"

sudo wget -q --tries=3 --timeout=20 -O server.jar "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
# Minimalgröße absichern gegen HTML-Fehldownloads (>5MB)
[ "$(stat -c%s server.jar)" -gt 5000000 ] || { echo "ERROR: server.jar zu klein/ungültig" >&2; exit 1; }

ACTUAL_SHA="$(sha256sum server.jar | awk '{print $1}')"
if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "null" ] && [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  echo "ERROR: PaperMC SHA256 mismatch (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})" >&2
  exit 1
fi
sudo chown minecraft:minecraft server.jar

# Memory autosize (floors for tiny CTs)
mem_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"; mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 )); ((xmx<448)) && xmx=448; ((xmx>16384)) && xmx=16384
xms=$(( mem_mb/4 )); ((xms<256)) && xms=256; ((xms>xmx)) && xms=$xmx

sudo tee start.sh >/dev/null <<E2
#!/usr/bin/env bash
exec /usr/bin/java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
sudo chown minecraft:minecraft start.sh eula.txt server.jar
chmod +x start.sh

if [ "$USE_SYSTEMD" = "1" ]; then
  # systemd-Service schreiben & starten
  sudo tee /etc/systemd/system/minecraft.service >/dev/null <<'EOF'
[Unit]
Description=Minecraft Server (Paper)
After=network-online.target
Wants=network-online.target

[Service]
User=minecraft
Group=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/opt/minecraft/start.sh
SuccessExitStatus=0 143
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
UMask=0027
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictSUIDSGID=true
RestrictNamespaces=true
CapabilityBoundingSet=
AmbientCapabilities=
ReadWritePaths=/opt/minecraft

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable --now minecraft
else
  # Start in screen (Fallback)
  if command -v runuser >/dev/null 2>&1; then
    runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -DmS minecraft ./start.sh'
  else
    sudo -u minecraft bash -lc 'cd /opt/minecraft && screen -DmS minecraft ./start.sh'
  fi
fi

echo "✅ Minecraft Java setup complete. Attach (screen): sudo -u minecraft screen -r minecraft"
