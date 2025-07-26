# 🧱️ Minecraft Server on Proxmox 🌍

![⛏️ Minecraft Server Setup](https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/minecraft-setup.png?raw=true)

This repository provides a guide and automated scripts to set up a **Minecraft server** on **Proxmox** using either a **Virtual Machine (VM)** or an **LXC container**.

---

## 🔗 Support This Project 💎

If you find this guide helpful, consider purchasing through this affiliate link:
**⛏️ [NiPoGi AK1PLUS Mini PC – Intel Alder Lake-N N100](https://amzn.to/3FvH4GX)**
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

* Open Proxmox Web Interface → Click on **"Create VM"**
* **General Settings**:

  * Name: `Minecraft-Server`
* **OS Selection**:

  * Use a **Ubuntu 24.04 LTS** ISO image *(empfohlen)*. Debian 11/12 können ebenfalls verwendet werden, benötigen jedoch zusätzliche Schritte für Java 21 und es wird gegebenenfalls auf Java 17 zurückgegriffen.
* **System Configuration**:

  * BIOS: **OVMF (UEFI) or SeaBIOS**
  * Machine Type: **q35** (recommended)
* **Disk & Storage**:

  * **20GB+ Storage** (depending on world size)
  * Storage Type: **`virtio`** (recommended)
* **CPU & RAM**:

  * 2 vCPUs (recommended: 4)
  * 4GB RAM (recommended: 8GB)
* **Network**:

  * Model: **VirtIO**
  * Enable **QEMU Guest Agent** after installation

### 2️⃣ Install Dependencies ⚙️

```bash
apt update && apt upgrade -y  
apt install -y curl wget nano screen unzip git
```

> **Hinweis:** Das Setup‑Skript kümmert sich um die Java‑Installation. Auf Ubuntu 24.04 wird OpenJDK 21 installiert. Ist Java 21 nicht verfügbar (z. B. auf Debian 11/12), wird automatisch auf Java 17 zurückgegriffen. Alternativ kann das Microsoft‑OpenJDK‑Repository genutzt werden【32683142696490†L318-L331】.

### 3️⃣ Run the Minecraft Server Setup Script ⛏️

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh  
chmod +x setup_minecraft.sh  
./setup_minecraft.sh
```

---

## 🛠️ Installation Guide (Proxmox LXC Container) 📆

### 1️⃣ Create a Proxmox LXC Container 🧱️

* Open Proxmox Web Interface → Click on **"Create CT"**
* **General Settings**:

  * Name: `Minecraft-LXC`
  * Set root user **password**
* **Template Selection**:

  * Wähle ein **Ubuntu 24.04 LTS**‑Template *(empfohlen)*. Debian 11/12‑Templates werden unterstützt, verwenden aber standardmäßig Java 17, falls Java 21 nicht verfügbar ist.
* **Resources**:

  * CPU: 2 vCPUs (recommended: 4)
  * RAM: 4GB (recommended: 8GB)
  * Disk Storage: 10GB (recommended: 20GB)
* **Network Settings**:

  * Network Device: `eth0`
  * Bridge: `vmbr0` *(adjust as needed)*
  * IPv4: Static (e.g. `192.168.0.222/24`)
  * Gateway (IPv4): typically `192.168.0.1`
  * Firewall: Enable (optional)
* **Advanced Settings**:

  * Enable **"Nesting"** (required for Java & systemd)
  * Disable **"Unprivileged Container"** if needed

### 2️⃣ Install Required Dependencies ⚒️

```bash
apt update && apt upgrade -y  
apt install -y curl wget nano screen unzip git
```

> **Hinweis:** Das LXC‑Installationsskript installiert Java 21 auf Ubuntu 24.04. Wenn Java 21 nicht verfügbar ist (z. B. auf Debian 11/12), wird automatisch OpenJDK 17 installiert.

### 3️⃣ Run the LXC Setup Script 🛠️

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh  
chmod +x setup_minecraft_lxc.sh  
./setup_minecraft_lxc.sh
```

---

## 🔧 Post-Installation Notes

### ✅ Can I install this as a non-root user?

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

If it's missing:

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
