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
sudo mkdir -p /opt/minecraft
if ! id -u minecraft >/dev/null 2>&1; then sudo useradd -r -m -s /bin/bash minecraft; fi
sudo chown -R minecraft:minecraft /opt/minecraft
cd /opt/minecraft
echo "eula=true" > eula.txt
mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo); mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 )); ((xmx<2048)) && xmx=2048; ((xmx>16384)) && xmx=16384
xms=$(( mem_mb/4 )); ((xms<1024)) && xms=1024; ((xms>xmx)) && xms=$xmx
cat > start.sh <<E2
#!/usr/bin/env bash
exec java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
chmod +x start.sh
sudo install -d -m 775 -o root -g utmp /run/screen || true
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'
else
  sudo -u minecraft bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'
fi
echo "✅ Minecraft Java setup complete. Attach: screen -r minecraft"
