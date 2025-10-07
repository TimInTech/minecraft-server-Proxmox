#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y unzip wget screen curl ca-certificates

# Nutzer & Verzeichnisse
if ! id -u minecraft >/dev/null 2>&1; then
  useradd -r -m -s /bin/bash minecraft
fi
install -d -m 0775 -o root -g utmp /run/screen || true
install -d -m 0755 -o minecraft -g minecraft /opt/minecraft-bedrock
cd /opt/minecraft-bedrock

# Letzte Bedrock-URL ermitteln
HTML="$(curl -fsSL https://www.minecraft.net/en-us/download/server/bedrock)"
LATEST_URL="$(printf '%s' "$HTML" | grep -Eo 'https://www\.minecraft\.net/bedrockdedicatedserver/bin-linux/bedrock-server-[0-9.]+\.zip' | head -n1 || true)"
if [[ -z "${LATEST_URL}" ]]; then
  echo "ERROR: Could not find Bedrock server URL" >&2
  exit 1
fi

# Content-Type prüfen (robust gegen CR in Headern)
if ! curl -fsSI "$LATEST_URL" | tr -d '\r' | grep -iqE '^content-type:\s*application/zip'; then
  echo "ERROR: unexpected content-type for $LATEST_URL" >&2
  exit 1
fi

echo "Downloading: $LATEST_URL"
wget -qO bedrock-server.zip "$LATEST_URL"

ACTUAL_SHA="$(sha256sum bedrock-server.zip | awk '{print $1}')"
echo "bedrock-server.zip sha256: ${ACTUAL_SHA}"

: "${REQUIRE_BEDROCK_SHA:=1}"
if [[ "${REQUIRE_BEDROCK_SHA}" = "1" ]]; then
  if [[ -z "${REQUIRED_BEDROCK_SHA256:-}" ]]; then
    echo "ERROR: Set REQUIRED_BEDROCK_SHA256 to a known-good value (export REQUIRED_BEDROCK_SHA256=<sha>)" >&2
    exit 1
  fi
  if [[ "${ACTUAL_SHA}" != "${REQUIRED_BEDROCK_SHA256}" ]]; then
    echo "ERROR: SHA256 mismatch (expected ${REQUIRED_BEDROCK_SHA256}, got ${ACTUAL_SHA})" >&2
    exit 1
  fi
fi

# ZIP testen & entpacken
unzip -tq bedrock-server.zip >/dev/null
unzip -oq bedrock-server.zip
rm -f bedrock-server.zip

# Binärdatei vorhanden?
if [[ ! -x ./bedrock_server && ! -f ./bedrock_server ]]; then
  echo "ERROR: bedrock_server missing after extraction" >&2
  exit 1
fi

# Startskript
cat > start.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exec env LD_LIBRARY_PATH=. ./bedrock_server
EOF
chmod +x start.sh
chown -R minecraft:minecraft /opt/minecraft-bedrock

# Start in screen
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft-bedrock && screen -DmS bedrock ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft-bedrock && screen -DmS bedrock ./start.sh' minecraft
fi

echo "✅ Setup complete. Attach: screen -r bedrock"
