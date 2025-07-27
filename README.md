# 🧱️ Minecraft Server on Proxmox 🌍

![⛏️ Minecraft Server Setup](https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/minecraft-setup.png?raw=true)

This repository provides a guide and automated scripts to set up a **Minecraft server** on **Proxmox** using either a **Virtual Machine (VM)** or an **LXC container**.

---

## 🔗 Support This Project 💎

If you find this guide helpful, consider purchasing through this affiliate link:
**⛏️ [NiPoGi AK1PLUS Mini PC – Intel Alder Lake‑N N100](https://amzn.to/3FvH4GX)**
Using this link supports the project at no additional cost to you. Thank you! 🙌

---

## 📌 Features 📜

✅ Automated installation of Minecraft Java/Bedrock servers  
✅ Works with Proxmox VM or LXC container  
✅ Performance optimizations included (RAM allocation, CPU prioritization)  
✅ Customizable settings (world generation, plugins, mods)  
✅ Troubleshooting guide included for common issues  

---

## 💎 Installation Guide (Proxmox VM) 🖥️

### 1️⃣ Create a Proxmox VM 💠

* Open the Proxmox web interface → Click on **“Create VM”**
* **General Settings**:
  * Name: `Minecraft-Server`
* **OS Selection**:
  * Use an **Ubuntu 24.04 LTS** ISO image *(recommended)*. Debian 11/12 can also be used but require additional steps for Java 21 and will fall back to Java 17 if needed.
* **System Configuration**:
  * BIOS: **OVMF (UEFI)** or **SeaBIOS**
  * Machine Type: **q35** (recommended)
* **Disk & Storage**:
  * **20 GB+ storage** (depending on world size)
  * Storage Type: **`virtio`** (recommended)
* **CPU & RAM**:
  * 2 vCPUs (recommended: 4)
  * 4 GB RAM (recommended: 8 GB)
* **Network**:
  * Model: **VirtIO**
  * Enable the **QEMU Guest Agent** after installation

### 2️⃣ Install Dependencies ⚙️

```bash
apt update && apt upgrade -y
apt install -y curl wget nano screen unzip git
````

> **Note:** The setup script handles the Java installation. On Ubuntu 24.04 it installs OpenJDK 21. If Java 21 is not available (e.g. on Debian 11/12) it automatically falls back to Java 17. Alternatively, you can use the Microsoft OpenJDK repository.

### 3️⃣ Run the Minecraft Server Setup Script ⛏️

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
```

---

## 🛠️ Installation Guide (Proxmox LXC Container) 📆

### 1️⃣ Create a Proxmox LXC Container 🧱️

* Open the Proxmox web interface → Click on **“Create CT”**
* **General Settings**:

  * Name: `Minecraft-LXC`
  * Set the root user **password**
* **Template Selection**:

  * Choose an **Ubuntu 24.04 LTS** template *(recommended)*. Debian 11/12 templates are supported but use Java 17 by default if Java 21 is not available.
* **Resources**:

  * CPU: 2 vCPUs (recommended: 4)
  * RAM: 4 GB (recommended: 8 GB)
  * Disk Storage: 10 GB (recommended: 20 GB)
* **Network Settings**:

  * Network Device: `eth0`
  * Bridge: `vmbr0` *(adjust as needed)*
  * IPv4: Static (e.g. `192.168.0.222/24`)
  * Gateway (IPv4): typically `192.168.0.1`
  * Firewall: Enable (optional)
* **Advanced Settings**:

  * Enable **“Nesting”** (required for Java & systemd)
  * Disable **“Unprivileged Container”** if needed

### 2️⃣ Install Required Dependencies ⚒️

```bash
apt update && apt upgrade -y
apt install -y curl wget nano screen unzip git
```

> **Note:** The LXC installation script installs Java 21 on Ubuntu 24.04. If Java 21 is not available (e.g. on Debian 11/12) it automatically installs OpenJDK 17.

### 3️⃣ Run the LXC Setup Script 🛠️

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```

---

## 🔧 Post‑Installation Notes

### ✅ Can I install this as a non‑root user?

Yes – root is only needed during setup (e.g. to create the `minecraft` user). After installation, all operations (start, stop, update) can and should be done as the `minecraft` user.

### 🎮 How do I access the Minecraft console?

```bash
sudo -u minecraft screen -r
```

If needed:

```bash
sudo -u minecraft screen -ls
sudo -u minecraft bash /opt/minecraft/start.sh
```

### 🔄 How do I update the server?

#### Java Edition:

```bash
cd /opt/minecraft
sudo -u minecraft ./update.sh
```

If it’s missing:

```bash
sudo nano /opt/minecraft/update.sh
```

Paste:

```bash
#!/bin/bash
wget -O server.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/416/downloads/paper-1.20.4-416.jar
```

Then:

```bash
sudo chmod +x /opt/minecraft/update.sh
```

#### Bedrock Edition:

Manual update required – download the latest `.zip` from the official site and replace the old one. *(Due to licensing restrictions, automatic download is not included.)*

---

## 🔍 Troubleshooting & Solutions 🚩

### 1️⃣ Java Version Error

```bash
apt install -y openjdk-21-jre-headless
systemctl restart minecraft
```

### 2️⃣ Missing `start.sh`

```bash
cd /opt/minecraft
nano start.sh
```

Paste:

```bash
#!/bin/bash
java -Xms2G -Xmx4G -jar server.jar nogui
```

Then:

```bash
chmod +x start.sh
./start.sh
```

### 3️⃣ Firewall (UFW) Setup

```bash
ufw allow 25565/tcp
ufw allow 25565/tcp6
ufw enable
```

---

## 🤝 Contribute 🌟

* Found a bug? 🐛 [Open an Issue](https://github.com/TimInTech/minecraft-server-Proxmox/issues)
* Want to improve the script? ⚙️ Submit a Pull Request

💎 **Happy crafting!** 🎮
