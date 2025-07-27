#!/bin/bash

# Minecraft Server Installer for LXC Containers on Proxmox
# Tested on Debian 11/12 and Ubuntu 24.04
# Author: TimInTech

# Update package lists and install required dependencies
apt update && apt upgrade -y
apt install -y openjdk-21-jre-headless screen wget curl jq unzip

# Create the Minecraft server directory
mkdir -p /opt/minecraft && cd /opt/minecraft

# Fetch the latest PaperMC version
LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions | last')
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/$LATEST_VERSION | jq -r '.builds | last')

# Validate if the version and build exist
if [[ -z "$LATEST_VERSION" || -z "$LATEST_BUILD" ]]; then
  echo "ERROR: Couldn't retrieve the latest PaperMC version. Check https://papermc.io/downloads"
  exit 1
fi

echo "Downloading PaperMC Version: $LATEST_VERSION, Build: $LATEST_BUILD"
wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$LATEST_VERSION/builds/$LATEST_BUILD/downloads/paper-$LATEST_VERSION-$LATEST_BUILD.jar"

# Accept the EULA
echo "eula=true" > eula.txt

# Create start script
cat <<EOF > start.sh
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
EOF

chmod +x start.sh

# Start the server in a detached screen session
screen -dmS minecraft ./start.sh

echo "✅ Minecraft Server setup complete! Use 'screen -r minecraft' to access the console."
