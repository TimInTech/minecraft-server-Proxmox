# 🧱 **Minecraft Server on Proxmox** 🌍

![⛏️ Minecraft Server Setup](https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/minecraft-setup.png?raw=true)

This repository provides a guide and automated scripts to set up a **Minecraft server** on **Proxmox** using either a **Virtual Machine (VM)** or an **LXC container**.

---

## 🔗 **Support This Project** 💎  
If you find this guide helpful, consider purchasing through this affiliate link:  
**⛏️ [NiPoGi AK1PLUS Mini PC – Intel Alder Lake-N N100](https://amzn.to/3FvH4GX)**  
Using this link supports the project at no additional cost to you. Thank you! 🙌

---

## 📌 **Features** 🗺️  
✅ **Automated installation** of Minecraft Java/Bedrock servers  
✅ Works with **Proxmox VM** or **LXC container**  
✅ **Performance optimizations** included (RAM allocation, CPU prioritization)  
✅ Customizable settings (world generation, plugins, mods)  
✅ **Minecraft-themed emojis** throughout the guide  

---

## 💎 **Installation Guide (Proxmox VM)** 🖥️

### **1️⃣ Create a Proxmox VM** 🛠️  
- Open Proxmox Web Interface → Click on **"Create VM"**  
- **General Settings**:  
  - Name: `Minecraft-Server`  
- **OS Selection**:  
  - Use a **Debian 11/12** or **Ubuntu 22.04** ISO image  
- **System Configuration**:  
  - BIOS: **OVMF (UEFI) or SeaBIOS**  
  - Machine Type: **q35** (recommended)  
- **Disk & Storage**:  
  - **20GB+ Storage** (depending on world size)  
  - Storage Type: **`virtio`** (recommended)  
- **CPU & RAM**:  
  - 2 vCPUs (recommended: 4)  
  - 4GB RAM (recommended: 8GB)  
- **Network**:  
  - Model: **VirtIO**  
  - Enable **QEMU Guest Agent** after installation  

### **Install Dependencies** ⚙️  
```bash
apt update && apt upgrade -y  
apt install -y curl wget nano screen unzip git openjdk-17-jre-headless
```

### **Run the Minecraft Server Setup Script** ⛏️  
```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh  
chmod +x setup_minecraft.sh  
./setup_minecraft.sh
```

---

## 🛠️ **Installation Guide (Proxmox LXC Container)** 📦  

### **1️⃣ Create a Proxmox LXC Container** 🧱  
- Open Proxmox Web Interface → Click on **"Create CT"**  
- **General Settings**:  
  - Name: `Minecraft-LXC`  
  - Set root user **password**  
- **Template Selection**:  
  - Choose a **Debian 11/12** or **Ubuntu 22.04** template  
- **Resources**:  
  - CPU: 2 vCPUs (recommended: 4)  
  - RAM: 4GB (recommended: 8GB)  
  - Disk Storage: 10GB (recommended: 20GB)  
- **Network Settings**:  
  - Network Device: `eth0`  
  - Bridge: `vmbr0` *(adjust as needed)*  
  - IPv4: Static (e.g. `192.168.0.222/24`)  
  - Gateway (IPv4): typically `192.168.0.1`  
  - Firewall: Enable (optional)  
- **Advanced Settings**:  
  - Enable **"Nesting"** (required for Java & systemd)  
  - Disable **"Unprivileged Container"** if needed  

### **2️⃣ Install Required Dependencies** ⚒️  
Log into the container and install:  
```bash
apt update && apt upgrade -y  
apt install -y curl wget nano screen unzip git openjdk-17-jre-headless
```

### **3️⃣ Run the LXC Setup Script** 🧰  
```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh  
chmod +x setup_minecraft_lxc.sh  
./setup_minecraft_lxc.sh
```

---

## 🔍 **Troubleshooting & Solutions** 🛑

### **1️⃣ Minecraft server did not start (No Systemd service)** 🚫  
**Error:** `Unit minecraft.service could not be found.`  

#### **Solution: Create the service manually** 🛠️  
```bash
nano /etc/systemd/system/minecraft.service
```  
Paste:  
```ini
[Unit]
Description=Minecraft Server ⛏️
After=network.target

[Service]
User=root
WorkingDirectory=/opt/minecraft
ExecStart=/bin/bash /opt/minecraft/start.sh
Restart=always

[Install]
WantedBy=multi-user.target
```  
Enable the service:  
```bash
systemctl daemon-reload  
systemctl enable minecraft  
systemctl start minecraft  
systemctl status minecraft
```

---

### **2️⃣ `server.jar` is empty** 🧨  
**Error:** `ls -l /opt/minecraft/` shows the file is 0 bytes.  

#### **Solution: Replace the empty `server.jar`** 💾  
For **PaperMC**:  
```bash
wget -O /opt/minecraft/server.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/450/downloads/paper-1.20.4-450.jar
```  
For **Vanilla Minecraft**:  
```bash
wget -O /opt/minecraft/server.jar https://www.minecraft.net/en-us/download/server
```  
Restart the server:  
```bash
systemctl restart minecraft
```

---

### **3️⃣ Firewall (`ufw`) is inactive** 🔥  
**Solution:** Open the Minecraft port:  
```bash
ufw allow 25565/tcp  
ufw allow 25565/tcp6  
ufw enable
```

---

## 🔧 **Manual Installation** 🗜️  

### **Steps for VM & LXC**  
1️⃣ **Install dependencies**:  
```bash
apt update && apt upgrade -y  
apt install -y curl wget nano screen unzip git openjdk-17-jre-headless
```  

2️⃣ **Create server directory**:  
```bash
mkdir -p /opt/minecraft && cd /opt/minecraft
```  

3️⃣ **Download `server.jar`**:  
```bash
wget -O server.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/450/downloads/paper-1.20.4-450.jar
```  

4️⃣ **Accept EULA**:  
```bash
echo "eula=true" > eula.txt
```  

5️⃣ **Create a start script**:  
```bash
cat <<EOF > start.sh
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
EOF
chmod +x start.sh
```  

6️⃣ **Setup Systemd Service**:  
```bash
nano /etc/systemd/system/minecraft.service
```  
Paste:  
```ini
[Unit]
Description=Minecraft Server ⛏️
After=network.target

[Service]
User=root
WorkingDirectory=/opt/minecraft
ExecStart=/bin/bash /opt/minecraft/start.sh
Restart=always

[Install]
WantedBy=multi-user.target
```  

7️⃣ **Start the server**:  
```bash
systemctl daemon-reload  
systemctl enable minecraft  
systemctl start minecraft  
tail -f /opt/minecraft/logs/latest.log  # Monitor logs 🧾
```  

---

## 🤝 **Contribute** 🌟  
- Found a bug? 🐛 **Open an Issue**  
- Want to improve the script? ⚙️ **Submit a Pull Request**  

 💎 **Happy crafting!** 🎮  
