#!/usr/bin/env bash
set -euo pipefail
apt update
apt install -y unzip wget screen curl
if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
mkdir -p /opt/minecraft-bedrock
chown -R minecraft:minecraft /opt/minecraft-bedrock
cd /opt/minecraft-bedrock
HTML="$(curl -fsSL https://www.minecraft.net/en-us/download/server/bedrock)"
LATEST_URL="$(printf "%s" "$HTML" | grep -Eo 'https://www\.minecraft\.net/bedrockdedicatedserver/bin-linux/bedrock-server-[0-9.]+'\.zip | head -1)"
if [[ -z "${LATEST_URL:-}" ]]; then echo "ERROR: Could not find Bedrock server URL"; exit 1; fi
echo "Downloading: $LATEST_URL"
wget -O bedrock-server.zip "$LATEST_URL"
unzip -tq bedrock-server.zip >/dev/null
unzip -o bedrock-server.zip && rm -f bedrock-server.zip
[[ -f bedrock_server ]] || { echo "ERROR: bedrock_server missing"; exit 1; }
cat > start.sh <<'E2'
#!/bin/bash
LD_LIBRARY_PATH=. ./bedrock_server
E2
chmod +x start.sh
chown -R minecraft:minecraft /opt/minecraft-bedrock
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh'
else
  sudo -u minecraft bash -lc 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh'
fi
echo "Setup complete. Attach: screen -r bedrock"
