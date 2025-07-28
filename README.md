# 🧱️ Minecraft Server on Proxmox 🌍

![⛏️ Minecraft Server Setup](https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/minecraft-setup.png?raw=true)

Welcome to the ultimate setup guide for running a **Minecraft server** on your **Proxmox host**, whether using a **Virtual Machine (VM)** or a **Lightweight Container (LXC)**. This project provides fully automated scripts, performance tuning, and a modular approach to simplify your server deployment.

---

## 📚 Inhaltsverzeichnis

* [🧱 Minecraft Server on Proxmox 🌍](#-minecraft-server-on-proxmox-)
* [🔗 Support This Project 💎](#-support-this-project-)
* [📌 Features 📜](#-features-)
* [💎 Installation Guide (Proxmox VM) 🧰](#-installation-guide-proxmox-vm-)

  * [1️⃣ Create a Proxmox VM 🖥️](#-1️-create-a-proxmox-vm-)
  * [2️⃣ Install Dependencies ⚙️](#-2️-install-dependencies-)
  * [3️⃣ Run the Minecraft Server Setup Script ⛏️](#-3️-run-the-minecraft-server-setup-script-)
* [🛠️ Installation Guide (Proxmox LXC Container) 📦](#-installation-guide-proxmox-lxc-container-)

  * [1️⃣ Create a Proxmox LXC Container 📤](#-1️-create-a-proxmox-lxc-container-)
  * [2️⃣ Install Required Dependencies 🔩](#-2️-install-required-dependencies-)
  * [3️⃣ Run the LXC Setup Script ⚡](#-3️-run-the-lxc-setup-script-)
* [🔧 Post‑Installation Notes](#-postinstallation-notes)
* [🎮 Server Control & Admin Commands 📘](#-server-control--admin-commands-)
* [🔍 Troubleshooting & Solutions 🚩](#-troubleshooting--solutions-)
* [🤝 Contribute 🌟](#-contribute-)
* [📃 Inspiration & References](#-inspiration--references)

---

---

## 🔗 Support This Project 💎

If this guide was helpful or saved you time, consider supporting its development by using the affiliate link below:

**⛏️ [NiPoGi AK1PLUS Mini PC – Intel Alder Lake‑N N100](https://amzn.to/3FvH4GX)**

Your support helps keep this project active and free to use — at no extra cost to you. Thank you for contributing! 🙌

---

## 📌 Features 📜

✅ Automated setup for Minecraft Java & Bedrock servers
✅ Runs on both VMs and LXC containers in Proxmox
✅ Performance-tuned (RAM allocation, CPU priority)
✅ Easy customization (worlds, mods, plugins)
✅ Integrated troubleshooting and update instructions

---

## 💎 Installation Guide (Proxmox VM) 🧰

### 1️⃣ Create a Proxmox VM 🖥️

1. Open the Proxmox web interface → Click **“Create VM”**
2. **General Settings**:

   * Name: `Minecraft-Server`
3. **OS Selection**:

   * Choose **Ubuntu 24.04 LTS** *(recommended)* or **Debian 11/12** (requires Java fallback)
4. **System Configuration**:

   * BIOS: **OVMF (UEFI)** or **SeaBIOS**
   * Machine: **q35** (recommended)
5. **Disk & Storage**:

   * At least **20 GB** (more for large worlds)
6. **CPU & RAM**:

   * CPU: **2–4 vCPUs**
   * RAM: **4–8 GB**
7. **Network**:

   * Model: **VirtIO**
   * Enable the **QEMU Guest Agent**

### 2️⃣ Install Dependencies ⚙️

```bash
apt update && apt upgrade -y
apt install -y curl wget nano screen unzip git
```

> On Ubuntu 24.04, Java 21 is installed. On Debian 11/12, the script gracefully falls back to Java 17.

### 3️⃣ Run the Minecraft Server Setup Script ⛏️

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh
chmod +x setup_minecraft.sh
./setup_minecraft.sh
```

---

## 🛠️ Installation Guide (Proxmox LXC Container) 📦

### 1️⃣ Create a Proxmox LXC Container 📤

1. In the Proxmox interface → Click **“Create CT”**
2. **General Settings**:

   * Name: `Minecraft-LXC`
   * Set a root password
3. **Template**:

   * Recommended: **Ubuntu 24.04 LTS**
4. **Resources**:

   * CPU: **2–4 vCPUs**
   * RAM: **4–8 GB**
   * Disk: **10–20 GB**
5. **Network**:

   * Bridge: `vmbr0`
6. **Advanced Settings**:

   * Enable **Nesting**
   * Optionally disable **Unprivileged Container**

### 2️⃣ Install Required Dependencies 🔩

```bash
apt update && apt upgrade -y
apt install -y curl wget nano screen unzip git
```

### 3️⃣ Run the LXC Setup Script ⚡

```bash
wget https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh
chmod +x setup_minecraft_lxc.sh
./setup_minecraft_lxc.sh
```

---

## 🔧 Post‑Installation Notes

### ✅ Can I use a non‑root user?

Yes. After setup, switch to the `minecraft` user to run the server securely.

### 🎮 Access the Minecraft console:

```bash
sudo -u minecraft screen -r
```

If needed:

```bash
sudo -u minecraft screen -ls
sudo -u minecraft bash /opt/minecraft/start.sh
```

### 🔄 Update the server:

**Java Edition:**

```bash
cd /opt/minecraft
sudo -u minecraft ./update.sh
```

**Bedrock Edition:**
Manual update needed – download `.zip` from Mojang and replace the existing one.

---

## 🎮 Server Control & Admin Commands 📘

Looking for admin tips, console commands, and how to OP players?

👉 [**📘 Minecraft Server Control – Commands & Admin Guide (LXC/VM)**](SERVER_COMMANDS.md)

Includes:

* Start/stop/update routines for Java & Bedrock
* `start.sh` RAM tuning examples
* `screen` command usage
* Admin OP handling + `ops.json`
* Command block tricks
* Bedrock-specific quirks

---

## 🔍 Troubleshooting & Solutions 🚩

### 1️⃣ Java not found or wrong version

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

### 3️⃣ Firewall Setup (UFW)

```bash
ufw allow 25565/tcp
ufw allow 25565/tcp6
ufw enable
```

---

## 🤝 Contribute 🌟

Have a suggestion or want to report a bug?

* 🐞 [Open an Issue](https://github.com/TimInTech/minecraft-server-Proxmox/issues)
* ⚙️ Submit a Pull Request

💎 **Happy crafting and thanks for supporting open source!** 🎮

---

## 📃 Inspiration & References

* [PaperMC API](https://papermc.io/)
* [Mojang Bedrock Downloads](https://www.minecraft.net/en-us/download/server/bedrock)
* [Proxmox Community & Documentation](https://pve.proxmox.com/wiki/Main_Page)

---
