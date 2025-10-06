#!/usr/bin/env bash
set -euo pipefail
apt update && apt upgrade -y
apt install -y screen wget curl jq unzip ca-certificates gnupg
ensure_java() {
  if apt-get install -y openjdk-21-jre-headless 2>/dev/null; then return; fi
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
echo "eula=true" > eula.txt
mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo); mem_mb=$((mem_kb/1024))
xmx=$(( mem_mb/2 )); ((xmx<2048)) && xmx=2048; ((xmx>16384)) && xmx=16384
xms=$(( mem_mb/4 )); ((xms<1024)) && xms=1024; ((xms>xmx)) && xms=$xmx
cat > start.sh <<E2
#!/usr/bin/env bash
exec java -Xms${xms}M -Xmx${xmx}M -jar server.jar nogui
E2
chmod +x start.sh
install -d -m 775 -o root -g utmp /run/screen || true
if command -v runuser >/dev/null 2>&1; then
  runuser -u minecraft -- bash -lc 'cd /opt/minecraft && screen -dmS minecraft ./start.sh'
else
  su -s /bin/bash -c 'cd /opt/minecraft && screen -dmS minecraft ./start.sh' minecraft
fi
echo "✅ Minecraft Java setup complete (LXC). Attach: screen -r minecraft"
