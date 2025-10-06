#!/usr/bin/env bash
set -euo pipefail
apt update
apt install -y unzip wget screen curl ca-certificates
if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
mkdir -p /opt/minecraft-bedrock
chown -R minecraft:minecraft /opt/minecraft-bedrock
cd /opt/minecraft-bedrock
HTML="$(curl -fsSL https://www.minecraft.net/en-us/download/server/bedrock)"
LATEST_URL="$(printf '%s' "$HTML" | grep -Eo 'https://www\.minecraft\.net/bedrockdedicatedserver/bin-linux/bedrock-server-[0-9.]+\.zip' | head -1)"
if [[ -z "${LATEST_URL:-}" ]]; then echo "ERROR: Could not find Bedrock server URL"; exit 1; fi
curl -fsSI "$LATEST_URL" | grep -iqE '^content-type:\s*application/zip' || { echo "ERROR: unexpected content-type"; exit 1; }
echo "Downloading: $LATEST_URL"
wget -O bedrock-server.zip "$LATEST_URL"
ACTUAL_SHA="$(sha256sum bedrock-server.zip | awk '{print $1}')"
echo "bedrock-server.zip sha256: ${ACTUAL_SHA}"
if [[ "${REQUIRE_BEDROCK_SHA:=1}" = "1" ]]; then
  if [[ -z "${REQUIRED_BEDROCK_SHA256:-}" ]]; then
    echo "ERROR: Set REQUIRED_BEDROCK_SHA256 to a known-good value (export REQUIRED_BEDROCK_SHA256=<sha>)"
    exit 1
  fi
  if [[ "${ACTUAL_SHA}" != "${REQUIRED_BEDROCK_SHA256}" ]]; then
    echo "ERROR: SHA256 mismatch (expected ${REQUIRED_BEDROCK_SHA256}, got ${ACTUAL_SHA})"
    exit 1
  fi
fi
unzip -tq bedrock-server.zip >/dev/null
unzip -o bedrock-server.zip && rm -f bedrock-server.zip
[[ -x bedrock_server || -f bedrock_server ]] || { echo "ERROR: bedrock_server missing"; exit 1; }
cat > start.sh <<'E2'
#!/usr/bin/env bash
exec env LD_LIBRARY_PATH=. ./bedrock_server
E2
chmod +x start.sh
chown -R minecraft:minecraft /opt/minecraft-bedrock
install -d -m 775 -o root -g utmp /run/screen || true
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh' minecraft
fi
echo "✅ Setup complete. Attach: screen -r bedrock"
