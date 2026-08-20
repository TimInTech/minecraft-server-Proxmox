Output assets/server-usage.gif

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
Type "# Practical Server Management: Minecraft PaperMC (CT 120)"
Enter
Sleep 800ms

Type "# 1. Check Server Service Status & RAM Allocation"
Enter
Sleep 600ms
Type "pct exec 120 -- systemctl status minecraft --no-pager"
Enter
Sleep 3s

Type "# 2. Inspect Server Properties (MOTD, Gamemode, Port)"
Enter
Sleep 600ms
Type "pct exec 120 -- grep -E '^(motd|gamemode|difficulty|max-players|server-port|white-list)=' /opt/minecraft/server.properties"
Enter
Sleep 2.5s

Type "# 3. Create Instant Automated World & Config Backup"
Enter
Sleep 600ms
Type "pct exec 120 -- bash -c 'mkdir -p /var/backups/minecraft && tar -czf /var/backups/minecraft/mc-backup.tar.gz -C /opt/minecraft world server.properties ops.json && ls -lh /var/backups/minecraft/'"
Enter
Sleep 3s

Type "# 4. Tail Live Server Logs & Chunk Storage Health"
Enter
Sleep 600ms
Type "pct exec 120 -- tail -n 5 /opt/minecraft/logs/latest.log"
Enter
Sleep 3s

Type "# ✅ Server Administration & Maintenance: Verified Operational"
Enter
Sleep 2.5s
