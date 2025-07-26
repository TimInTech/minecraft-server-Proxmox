#!/bin/bash
set -e
echo "📦 Installing base dependencies..."
apt update && apt install -y curl wget screen unzip git
echo "☕ Installing Java..."
apt install -y openjdk-21-jre-headless || apt install -y openjdk-17-jre-headless

MEM_MIN=${MEM_MIN:-2G}
MEM_MAX=${MEM_MAX:-4G}
mkdir -p /opt/minecraft && cd /opt/minecraft
wget -q https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/latest/downloads/paper-1.20.1-latest.jar -O server.jar

echo '#!/bin/bash
java -Xms$MEM_MIN -Xmx$MEM_MAX -jar server.jar nogui' > start.sh
chmod +x start.sh
screen -dmS minecraft ./start.sh
