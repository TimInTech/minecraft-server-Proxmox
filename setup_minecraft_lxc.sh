#!/usr/bin/env bash

# Minecraft Server Installer for LXC Containers on Proxmox
# Tested on Debian 11/12 and Ubuntu 24.04
# Author: TimInTech


set -euo pipefail

# Update package lists and install required dependencies
apt update && apt upgrade -y
apt install -y screen wget curl jq unzip

# Install Java: try OpenJDK 21 if available, fall back to OpenJDK 17.
if ! apt install -y openjdk-21-jre-headless; then
  echo "openjdk-21-jre-headless is not available; falling back to openjdk-17-jre-headless"
  apt install -y openjdk-17-jre-headless
fi

# Create the Minecraft server directory
mkdir -p /opt/minecraft && cd /opt/minecraft || exit 1
if ! id -u minecraft >/dev/null 2>&1; then useradd -r -m -s /bin/bash minecraft; fi
chown -R minecraft:minecraft /opt/minecraft

# Fetch the latest PaperMC version
LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions | last')
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/"$LATEST_VERSION" | jq -r '.builds | last')
BUILD_JSON="$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}")"
EXPECTED_SHA="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')"
JAR_NAME="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')"

# Validate if the version and build exist
if [[ -z "$LATEST_VERSION" || -z "$LATEST_BUILD" ]]; then
  echo "ERROR: Couldn't retrieve the latest PaperMC version. Check https://papermc.io/downloads"
  exit 1
fi

echo "Downloading PaperMC Version: $LATEST_VERSION, Build: $LATEST_BUILD"
wget -O "server.jar" "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
ACTUAL_SHA="$(sha256sum server.jar | awk '{print $1}')"
if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "null" ]; then
  if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    echo "ERROR: SHA256 mismatch for PaperMC (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})"
    exit 1
  fi
  echo "SHA256 verified: ${ACTUAL_SHA}"
else
  echo "WARNING: No upstream SHA provided; computed: ${ACTUAL_SHA}"
fi

# Accept the EULA
echo "eula=true" > eula.txt

# Create start script
cat <<EOF > start.sh
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
EOF

chmod +x start.sh

# Start the server in a detached screen session
if command -v runuser >/dev/null 2>&1; then runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'; else sudo -u minecraft bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'; fi

echo "✅ Minecraft Server setup complete! Use 'screen -r minecraft' to access the console."
