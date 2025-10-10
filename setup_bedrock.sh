#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y unzip wget screen curl ca-certificates

if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
mkdir -p /opt/minecraft-bedrock
chown -R minecraft:minecraft /opt/minecraft-bedrock
cd /opt/minecraft-bedrock

# Scrape Mojang page for the latest Linux ZIP link
HTML=$(curl -fsSL "https://www.minecraft.net/en-us/download/server/bedrock")
LATEST_URL=$(printf '%s' "$HTML" | grep -Eo 'https://www\.minecraft\.net/bedrockdedicatedserver/bin-linux/bedrock-server-[0-9.]+\.zip' | head -1)
if [[ -z "${LATEST_URL:-}" ]]; then
  echo "ERROR: Could not find Bedrock server URL on Mojang page" >&2
  exit 1
fi

# HEAD check for MIME type and optional size
if ! curl -fsSI "$LATEST_URL" | grep -iqE '^content-type:\s*(application/zip|application/octet-stream)'; then
  echo "ERROR: Unexpected Content-Type for Bedrock ZIP (must be application/zip or octet-stream)" >&2
  exit 1
fi
echo "Downloading: $LATEST_URL"
curl -fL --retry 3 --retry-delay 2 -o bedrock-server.zip "$LATEST_URL"
zip_size=$(stat -c '%s' bedrock-server.zip)
if (( zip_size < 1048576 )); then # 1MB sanity check
  echo "ERROR: Downloaded bedrock-server.zip is too small (${zip_size} bytes)." >&2
  exit 1
fi

ACTUAL_SHA=$(sha256sum bedrock-server.zip | awk '{print $1}')
echo "bedrock-server.zip sha256: ${ACTUAL_SHA}"

# NOTE: Enforce checksum by default; require REQUIRED_BEDROCK_SHA256 when REQUIRE_BEDROCK_SHA=1
if [[ "${REQUIRE_BEDROCK_SHA:=1}" = "1" ]]; then
  if [[ -z "${REQUIRED_BEDROCK_SHA256:-}" ]]; then
    echo "ERROR: Set REQUIRED_BEDROCK_SHA256 to a known-good value (export REQUIRED_BEDROCK_SHA256=<sha>)" >&2
    exit 1
  fi
  if [[ "${ACTUAL_SHA}" != "${REQUIRED_BEDROCK_SHA256}" ]]; then
    echo "ERROR: SHA256 mismatch (expected ${REQUIRED_BEDROCK_SHA256}, got ${ACTUAL_SHA})" >&2
    exit 1
  fi
fi

# Test and extract the archive
unzip -tq bedrock-server.zip >/dev/null
unzip -o bedrock-server.zip && rm -f bedrock-server.zip

if [[ ! -f bedrock_server ]]; then
  echo "ERROR: bedrock_server binary missing after extraction" >&2
  exit 1
fi

cat > start.sh <<'E2'
#!/usr/bin/env bash
exec env LD_LIBRARY_PATH=. ./bedrock_server
E2
chmod +x start.sh

chown -R minecraft:minecraft /opt/minecraft-bedrock

# Ensure screen runtime directory exists with correct ownership and mode
# NOTE: Required on Debian 12/13 so screen can create sockets.
install -d -m 0775 -o root -g utmp /run/screen || true

if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft-bedrock && screen -dmS bedrock ./start.sh' minecraft
fi

echo "✅ Setup complete. Attach: screen -r bedrock"
