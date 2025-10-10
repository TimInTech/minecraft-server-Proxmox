#!/usr/bin/env bash
set -euo pipefail

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

mkdir -p /opt/minecraft
if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
chown -R minecraft:minecraft /opt/minecraft
cd /opt/minecraft

printf '%s\n' "eula=true" > eula.txt

# Autosize memory: Xms=RAM/4, Xmx=RAM/2; floors 256M/448M; cap Xmx ≤16G.
mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo); mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 ))
(( xmx < 448 )) && xmx=448
(( xmx > 16384 )) && xmx=16384
xms=$(( mem_mb/4 ))
(( xms < 256 )) && xms=256
(( xms > xmx )) && xms=$xmx

# Download latest PaperMC with SHA256 verification and min-size check (>5MB).
PAPER_API_ROOT="https://api.papermc.io/v2/projects/paper"
LATEST_VERSION=$(curl -fsSL "$PAPER_API_ROOT" | jq -r '.versions | last')
LATEST_BUILD=$(curl -fsSL "$PAPER_API_ROOT/versions/${LATEST_VERSION}" | jq -r '.builds | last')
BUILD_JSON=$(curl -fsSL "$PAPER_API_ROOT/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}")
EXPECTED_SHA=$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')
JAR_NAME=$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')
DOWNLOAD_URL="$PAPER_API_ROOT/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

# NOTE: Enforce integrity and basic size sanity to avoid HTML error pages saved as JAR.
curl -fL --retry 3 --retry-delay 2 -o server.jar "$DOWNLOAD_URL"
ACTUAL_SHA=$(sha256sum server.jar | awk '{print $1}')
if [[ -n "$EXPECTED_SHA" && "$EXPECTED_SHA" != "null" && "$ACTUAL_SHA" != "$EXPECTED_SHA" ]]; then
  echo "ERROR: SHA256 mismatch for PaperMC (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})" >&2
  exit 1
fi
jar_size=$(stat -c '%s' server.jar)
if (( jar_size < 5242880 )); then
  echo "ERROR: Downloaded server.jar is too small (${jar_size} bytes). Likely an error page." >&2
  exit 1
fi

cat > start.sh <<E2
#!/usr/bin/env bash
exec java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
chmod +x start.sh

# Ensure minecraft owns newly created files
chown -R minecraft:minecraft /opt/minecraft

# Ensure screen runtime directory exists with correct ownership and mode
# NOTE: Required on Debian 12/13 so screen can create sockets.
install -d -m 0775 -o root -g utmp /run/screen || true
# NOTE: Persist /run/screen via systemd-tmpfiles in CTs as well
printf 'd /run/screen 0775 root utmp -\n' > /etc/tmpfiles.d/screen.conf
systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf || true

if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft && screen -dmS minecraft ./start.sh' minecraft
fi

echo "✅ Minecraft Java setup complete (LXC). Attach: screen -r minecraft"
