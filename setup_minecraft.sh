#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install -y screen wget curl jq unzip ca-certificates gnupg

ensure_java() {
  if sudo apt-get install -y openjdk-21-jre-headless 2>/dev/null; then return; fi
  sudo install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto.gpg
  echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y java-21-amazon-corretto-jre || sudo apt-get install -y java-21-amazon-corretto-jdk
}
ensure_java

# screen socket dir (Debian expects root:utmp)
sudo install -d -m 0775 -o root -g utmp /run/screen || true

# user & dir
if ! id -u minecraft >/dev/null 2>&1; then sudo useradd -r -m -s /bin/bash minecraft; fi
sudo install -d -m 0755 -o minecraft -g minecraft /opt/minecraft
cd /opt/minecraft

# EULA
echo "eula=true" | sudo tee eula.txt >/dev/null

# Download latest Paper (with SHA256 verification)
LATEST_VERSION="$(curl -fsSL https://api.papermc.io/v2/projects/paper | jq -r '.versions | last')"
LATEST_BUILD="$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}" | jq -r '.builds | last')"
BUILD_JSON="$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}")"
EXPECTED_SHA="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')"
JAR_NAME="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')"

sudo wget -qO server.jar "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
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
sudo chown minecraft:minecraft start.sh eula.txt
chmod +x start.sh

# Start in screen
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -DmS minecraft ./start.sh'
else
  sudo -u minecraft bash -lc 'cd /opt/minecraft && screen -DmS minecraft ./start.sh'
fi

echo "✅ Minecraft Java setup complete. Attach: sudo -u minecraft screen -r minecraft"
