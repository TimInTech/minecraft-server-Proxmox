Output assets/demo.gif

Set Shell "bash"
Set FontSize 18
Set Width 1050
Set Height 640
Set Theme "Catppuccin Mocha"
Set Padding 18
Set Margin 10
Set MarginFill "#1e1e2e"
Set WindowBar Colorful
Set BorderRadius 8
Set CursorBlink true
Set TypingSpeed 35ms
Set Framerate 20
Set PlaybackSpeed 1.0

Env PS1 "\[\033[01;32m\]root@pve\[\033[00m\]:\[\033[01;34m\]~\[\033[00m\]# "
Env TERM "xterm-256color"
Env PATH "/home/z2-ubuntu/Projekte/minecraft-server-Proxmox/demo/bin:/home/z2-ubuntu/Projekte/minecraft-server-Proxmox/.tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

Hide
Type "export PROMPT_COMMAND='' PS1='\[\033[01;32m\]root@pve\[\033[00m\]:\[\033[01;34m\]~\[\033[00m\]# '; clear"
Enter
Sleep 500ms
Show

Sleep 800ms
Type "# 1. Inspect Proxmox Minecraft LXC Container (CT 120)"
Enter
Sleep 800ms

Type "pct status 120 && pct exec 120 -- ip -br a"
Enter
Sleep 2.5s

Type "# 2. Verify Minecraft Server Systemd Service"
Enter
Sleep 800ms

Type "pct exec 120 -- systemctl status minecraft --no-pager"
Enter
Sleep 3s

Type "# 3. Run Live PaperMC Fill v3 API Update Check"
Enter
Sleep 800ms

Type "pct exec 120 -- /opt/minecraft/update.sh"
Enter
Sleep 3.5s

Type "# 4. Verify Minecraft Server Port & Startup Logs"
Enter
Sleep 800ms

Type "pct exec 120 -- tail -n 6 /opt/minecraft/logs/latest.log"
Enter
Sleep 3s

Type "# 5. Test LAN Connectivity on Port 25565"
Enter
Sleep 800ms

Type "nc -z -v -w 3 192.168.178.125 25565"
Enter
Sleep 3s

Type "# ✅ Proxmox Minecraft PaperMC Server test: 100% PASS"
Enter
Sleep 2.5s
