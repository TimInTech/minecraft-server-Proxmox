#!/usr/bin/env bash
set -euo pipefail

# ── Minecraft Java Server Installer (LXC/CT) ── v3.0 ──
# Uses PaperMC Fill v3 API (fill.papermc.io)

USER_AGENT="minecraft-server-Proxmox/3.0 (https://github.com/TimInTech/minecraft-server-Proxmox)"

apt update
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

# Autosize memory: Xms=RAM/4, Xmx=RAM/2; floors 1024M/2048M; cap Xmx ≤16G.
mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo); mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 ))
if (( xmx < 2048 )); then
  xmx=2048
fi
(( xmx > 16384 )) && xmx=16384
xms=$(( mem_mb/4 ))
if (( xms < 1024 )); then
  xms=1024
fi
(( xms > xmx )) && xms=$xmx

# ── Download latest stable PaperMC via Fill v3 API ──
FILL_API="https://fill.papermc.io/v3/projects/paper"

LATEST_VERSION=$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "${FILL_API}" | jq -r '.versions' | jq -r '.[keys_unsorted[0]][0]')
echo "Latest Minecraft version: ${LATEST_VERSION}"

BUILDS_JSON=$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "${FILL_API}/versions/${LATEST_VERSION}/builds")

# Filter for STABLE channel; fall back to latest build if no stable exists yet
STABLE_BUILD=$(printf '%s' "$BUILDS_JSON" | jq -r '
  (map(select(.channel == "STABLE")) | sort_by(.id) | last) //
  (sort_by(.id) | last)')

if [[ -z "$STABLE_BUILD" || "$STABLE_BUILD" == "null" ]]; then
  echo "ERROR: No builds found for version ${LATEST_VERSION}" >&2
  exit 1
fi

LATEST_BUILD=$(printf '%s' "$STABLE_BUILD" | jq -r '.id')
DOWNLOAD_URL=$(printf '%s' "$STABLE_BUILD" | jq -r '.downloads."server:default".url // empty')
EXPECTED_SHA=$(printf '%s' "$STABLE_BUILD" | jq -r '.downloads."server:default".checksums.sha256 // empty')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "ERROR: No download URL in API response for build ${LATEST_BUILD}" >&2
  exit 1
fi

echo "Downloading PaperMC build ${LATEST_BUILD} for ${LATEST_VERSION}..."

# NOTE: Enforce integrity and basic size sanity to avoid HTML error pages saved as JAR.
curl -fL -H "User-Agent: ${USER_AGENT}" --retry 3 --retry-delay 2 -o server.jar "$DOWNLOAD_URL"
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
echo "SHA256 verified: ${ACTUAL_SHA}"

cat > start.sh <<E2
#!/usr/bin/env bash
exec java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
chmod +x start.sh

# Ensure minecraft owns newly created files
chown -R minecraft:minecraft /opt/minecraft

# Ensure screen runtime directory exists with correct ownership and mode
# NOTE: In LXC, utmp group may not exist; fall back to root:root with 0777
if getent group utmp >/dev/null 2>&1; then
  install -d -m 0775 -o root -g utmp /run/screen || true
  printf 'd /run/screen 0775 root utmp -\n' > /etc/tmpfiles.d/screen.conf
else
  install -d -m 0777 -o root -g root /run/screen || true
  printf 'd /run/screen 0777 root root -\n' > /etc/tmpfiles.d/screen.conf
fi
systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf || true

# Start server in screen session (consistent with VM script and README)
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft && screen -dmS minecraft ./start.sh' minecraft
fi

echo "✅ Minecraft Java setup complete (LXC). Attach: screen -r minecraft"
