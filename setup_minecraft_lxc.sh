#!/usr/bin/env bash
set -euo pipefail

# Festlegbare Minecraft-Version (Default, kann per ENV überschrieben werden)
MC_VER="${MC_VER:-1.21.10}"

apt update && apt upgrade -y
apt install -y screen wget curl jq unzip ca-certificates gnupg

ensure_java() {
  # Prefer OpenJDK 21; fallback to Amazon Corretto 21 via APT keyring (no sudo in LXC).
  if apt-get install -y openjdk-21-jre-headless 2>/dev/null; then return; fi
  # NOTE: Adding a vendor APT source; restrict with signed-by keyring.
  install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto.gpg
  echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list
  apt-get update
  apt-get install -y java-21-amazon-corretto-jre || apt-get install -y java-21-amazon-corretto-jdk
}

ensure_java

# screen socket dir (Debian expects root:utmp) + Persistenz via tmpfiles
install -d -m 0775 -o root -g utmp /run/screen
printf 'd /run/screen 0775 root utmp -\n' > /etc/tmpfiles.d/screen.conf
systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf || true

# Optional: systemd bevorzugen (Fallback screen)
USE_SYSTEMD="${USE_SYSTEMD:-1}"

# user & dir
if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
install -d -m 0755 -o minecraft -g minecraft /opt/minecraft
cd /opt/minecraft

# EULA
echo "eula=true" > eula.txt

# Download Paper für $MC_VER (SHA256 + Mindestgröße)
LATEST_BUILD="$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}" | jq -r '.builds | last')"
BUILD_JSON="$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}/builds/${LATEST_BUILD}")"
EXPECTED_SHA="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')"
JAR_NAME="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')"

wget -qO server.jar "https://api.papermc.io/v2/projects/paper/versions/${MC_VER}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
[ "$(stat -c%s server.jar)" -gt 5000000 ] || { echo "ERROR: server.jar zu klein/ungültig" >&2; exit 1; }
ACTUAL_SHA="$(sha256sum server.jar | awk '{print $1}')"
if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "null" ] && [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  echo "ERROR: PaperMC SHA256 mismatch (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})" >&2
  exit 1
fi
chown minecraft:minecraft server.jar

# Memory autosize (floors for tiny CTs)
mem_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"; mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 )); ((xmx<448)) && xmx=448; ((xmx>16384)) && xmx=16384
xms=$(( mem_mb/4 )); ((xms<256)) && xms=256; ((xms>xmx)) && xms=$xmx

cat > start.sh <<E2
#!/usr/bin/env bash
exec /usr/bin/java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
chown minecraft:minecraft start.sh eula.txt
chmod +x start.sh

if [ "$USE_SYSTEMD" = "1" ]; then
  cat > /etc/systemd/system/minecraft.service <<'EOF'
[Unit]
Description=Minecraft Server (Paper)
After=network-online.target
Wants=network-online.target

[Service]
User=minecraft
Group=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/bash /opt/minecraft/start.sh
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
  systemctl daemon-reload
  systemctl enable --now minecraft
else
  # Start in screen (Fallback)
  if command -v runuser >/dev/null 2>&1; then
    runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -DmS minecraft ./start.sh'
  else
    su -s /bin/bash -c 'cd /opt/minecraft && screen -DmS minecraft ./start.sh' minecraft
  fi
fi

echo "✅ Minecraft Java setup complete (LXC). Attach: screen -r minecraft"
