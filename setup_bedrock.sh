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
LATEST_URL="$(printf '%s' "$HTML" | grep -Eo 'https://[^"[:space:]]*bedrock-server-[0-9.]+\.zip' | head -n1 || true)"
if [[ -z "${LATEST_URL}" ]]; then
  echo "ERROR: Could not find Bedrock server URL" >&2
  exit 1
fi

# Content-Type prüfen (robust gegen CR in Headern, folgt Redirects)
HEAD_OUT="$(curl -fsSIL "$LATEST_URL" | tr -d '\r')"
if ! printf '%s' "$HEAD_OUT" | grep -iqE '^content-type:\s*(application/zip|application/octet-stream)(\s*;|$)'; then
  echo "ERROR: unexpected content-type for $LATEST_URL" >&2
  echo "Got headers:" >&2
  printf '%s\n' "$HEAD_OUT" >&2
  exit 1
fi
# Optional: Content-Length prüfen, falls vorhanden und numerisch
CLEN="$(printf '%s' "$HEAD_OUT" | awk -F': ' 'tolower($1)=="content-length"{print $2}' | tr -d '[:space:]')"
if [[ -n "$CLEN" && "$CLEN" =~ ^[0-9]+$ && "$CLEN" -le 0 ]]; then
  echo "ERROR: content-length reported as $CLEN for $LATEST_URL" >&2
  exit 1
fi

# Sicherer Download in temporäre Datei
TMP_ZIP="$(mktemp -p /tmp bedrock-server.XXXXXX.zip)"
trap 'rm -f "$TMP_ZIP"' EXIT

echo "Downloading: $LATEST_URL"
wget -qO "$TMP_ZIP" "$LATEST_URL"

ACTUAL_SHA="$(sha256sum "$TMP_ZIP" | awk '{print $1}')"
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
unzip -tq "$TMP_ZIP" >/dev/null
unzip -oq "$TMP_ZIP"

# Binärdatei vorhanden?
if [[ ! -f ./bedrock_server ]]; then
  echo "ERROR: bedrock_server missing after extraction" >&2
  exit 1
fi
chmod +x ./bedrock_server || true

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
