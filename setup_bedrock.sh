#!/bin/bash

# Minecraft Bedrock Server Installer for Proxmox LXC/VM
# Tested on Debian 11/12 and Ubuntu 24.04
# Author: TimInTech

set -e  # Exit on any error

# Install required dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip wget screen curl

# Set up server directory
sudo mkdir -p /opt/minecraft-bedrock
sudo chown $(whoami):$(whoami) /opt/minecraft-bedrock
cd /opt/minecraft-bedrock

# Fetch the latest Bedrock server URL
LATEST_URL=$(curl -s https://www.minecraft.net/en-us/download/server/bedrock | grep -o 'https://minecraft.azureedge.net/bin-linux/bedrock-server-[0-9.]*.zip' | head -1)

# Exit if no URL was found
if [[ -z "$LATEST_URL" ]]; then
  echo "ERROR: Couldn't retrieve the latest Bedrock server URL."
  exit 1
fi

echo "Downloading Minecraft Bedrock Server from: $LATEST_URL"
wget -O bedrock-server.zip "$LATEST_URL"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
  echo "ERROR: Download failed. Check your internet connection."
  exit 1
fi

# Check if the file is a valid ZIP archive
if ! unzip -tq bedrock-server.zip >/dev/null; then
  echo "ERROR: The downloaded file is not a valid ZIP archive."
  rm -f bedrock-server.zip
  exit 1
fi

# Extract the server files
unzip -o bedrock-server.zip
rm -f bedrock-server.zip

# Make sure the server binary exists
if [[ ! -f "bedrock_server" ]]; then
  echo "ERROR: The server binary is missing. Installation failed."
  exit 1
fi

# Create start script
cat <<EOF > start.sh
#!/bin/bash
LD_LIBRARY_PATH=. ./bedrock_server
EOF

chmod +x start.sh

# Ensure screen is installed before starting the server
if ! command -v screen &> /dev/null; then
  echo "ERROR: 'screen' is not installed. Install it with 'sudo apt install screen'."
  exit 1
fi

# Start the server in a detached screen session
screen -dmS bedrock ./start.sh

echo "Setup complete! Use 'screen -r bedrock' to open the console."
