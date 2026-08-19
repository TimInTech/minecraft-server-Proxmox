import { TranslationSchema } from "./types";

export const de: TranslationSchema = {
  meta: {
    title:
      "Minecraft Server auf Proxmox – Automatisiertes Java & Bedrock Setup",
    description:
      "Produktionsreifes, automatisiertes Minecraft-Server-Setup (PaperMC Java & Bedrock) für Proxmox VE. Unterstützt VMs und LXC/CT mit Fill v3 API, SHA256-Integritätsprüfung und Auto-Updates.",
  },
  nav: {
    overview: "Übersicht",
    quickstart: "Schnellstart",
    features: "Funktionen",
    architecture: "Architektur",
    techSpecs: "Prüfstand",
    sources: "Dokumentation",
    githubRepo: "GitHub Repo",
    verifiedRevision: "VERSION 3.0",
    staticBuild: "Homelab Geprüft",
    switchLang: "Switch to English",
  },
  hero: {
    badge: "PROXMOX VE AUTOMATION",
    titleMain: "Minecraft Server auf Proxmox.",
    titleHighlight: "Automatisiert, verifiziert, betriebsbereit.",
    subtitle:
      "Richte performante PaperMC Java- oder Bedrock Dedicated Server auf Proxmox VE in wenigen Minuten ein. Volle Unterstützung für VMs, LXC-Container, Fill v3 API und automatische Wartung.",
    ctaPrimary: "Schnellstart",
    ctaSecondary: "Auf GitHub ansehen",
    statusReady: "V3.0 BEREIT",
    oneCommandNote: "Ein-Befehl-Installation · VM & LXC · Auto-Update",
  },
  stats: {
    version: { label: "AKTUELLES RELEASE", value: "v3.0.0" },
    api: { label: "PAPERMC API", value: "Fill v3 REST" },
    virtualization: { label: "ZIELUMGEBUNG", value: "VM + LXC/CT" },
    integrity: { label: "INTEGRITÄT", value: "SHA256 & Channels" },
  },
  quickstart: {
    kicker: "01 / SCHNELLSTART",
    title: "Mit einem einzigen Befehl einrichten",
    subtitle:
      "Wähle deine Zielarchitektur und starte das verifizierte Bereitstellungsskript direkt im Proxmox-Gast oder Host.",
    tabs: {
      vm: "Java VM",
      lxc: "Java LXC / CT",
      bedrock: "Bedrock CT Helfer",
      update: "Auto-Update",
    },
    vm: {
      title: "Minecraft Java Server auf Debian / Ubuntu VM",
      desc: "Installiert Java 21, richtet den Systembenutzer 'minecraft' ein, lädt den neuesten stabilen PaperMC-Build über die Fill v3 API, konfiguriert screen-Sessions und erstellt einen systemd-Dienst.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh | bash",
      bullets: [
        "Automatische RAM-Skalierung (Xms ≈ RAM/4, Xmx ≈ RAM/2, max. 16 GB)",
        "SHA-256 Integritätsprüfung gegen die PaperMC API",
        "systemd-Dienst mit automatischem Neustart bei Systemstart",
        "screen-Session-Verwaltung für sauberen Konsolenzugriff",
      ],
    },
    lxc: {
      title: "Minecraft Java Server im Proxmox LXC-Container",
      desc: "Speziell optimiert für unprivilegierte oder privilegierte LXC-Container mit Laufzeit-Socket-Vorbereitung und minimalem Ressourcen-Overhead.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh | bash",
      bullets: [
        "Erstellt das /run/screen Socket-Verzeichnis mit korrekten Rechten",
        "Eliminiert den Hypervisor-Overhead für maximale Tick-Raten",
        "PaperMC Fill v3 API Download mit User-Agent und Stable-Kanal",
        "Strukturierte Backups und Rollback-Sicherheit",
      ],
    },
    bedrock: {
      title: "Bedrock Dedicated Server CT Helfer",
      desc: "Wird direkt auf dem Proxmox VE Host ausgeführt, um automatisch ein Debian-Template herunterzuladen, den LXC-Container zu erstellen, das Netzwerk zu konfigurieren und Bedrock zu starten.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/scripts/proxmox_create_ct_bedrock.sh | bash",
      bullets: [
        "Vollautomatisierte Proxmox Container-Erstellung (pct create)",
        "Zufälliges, sicheres CT-Root-Passwort für Homelab-Sicherheit",
        "Konfiguriert UDP-Port 19132 für plattformübergreifende Bedrock-Clients",
        "Inklusive systemd-Dienst für wartungsfreien Autostart",
      ],
    },
    update: {
      title: "Automatisches Update & Wartung",
      desc: "Das enthaltene Update-Skript prüft auf neue stabile PaperMC-Releases, validiert Build-Hashes, sichert die aktuelle JAR-Datei und führt einen sauberen Neustart durch.",
      command: "sudo /opt/minecraft/update.sh",
      bullets: [
        "Sicheres In-Place-Update mit automatischem Fallback-Rollback",
        "Filtert ausschließlich STABLE-Kanal-Builds gegen Weltenbeschädigung",
        "Kann per crontab oder systemd-Timer periodisch ausgeführt werden",
        "Benachrichtigt aktive Spieler vor dem Serverneustart",
      ],
    },
    copyBtn: "Befehl kopieren",
    copiedBtn: "In die Zwischenablage kopiert!",
  },
  features: {
    kicker: "02 / KERNFUNKTIONEN",
    title: "Entwickelt für Homelab-Zuverlässigkeit",
    subtitle:
      "Entstanden aus echter Homelab-Praxis — mit Fokus auf Stabilität, Sicherheit und minimalen Wartungsaufwand.",
    items: [
      {
        title: "Fill v3 REST API Integration",
        desc: "Umgestellt auf PaperMCs moderne Fill v3 API mit semantischer Versionssortierung, individuellem User-Agent und STABLE-Kanal-Filterung. Keine 404s oder fehlerhaften Build-Parsings mehr.",
        tag: "Kern-Engine",
      },
      {
        title: "SHA256- & Größen-Integritätsprüfung",
        desc: "Jedes heruntergeladene JAR wird gegen den Upstream-Hash und Mindestgrößen validiert. Schließt stille Downloadfehler und als JAR gespeicherte HTML-Fehlerseiten aus.",
        tag: "Sicherheit",
      },
      {
        title: "Adaptive JVM-Speicherberechnung",
        desc: "Dynamische Heap-Berechnung passend zur Proxmox-Gastrohkapazität: Initialer Heap bei ca. 25% RAM, maximaler Heap bei ca. 50% RAM, sinnvoll gedeckelt bei 16 GB.",
        tag: "Performance",
      },
      {
        title: "VM- und LXC-Container-Parität",
        desc: "Egal ob vollständige Kernel-Isolation in KVM-VMs oder minimaler RAM-Bedarf in schlanken LXC-Containern — beide Architekturen werden erstklassig unterstützt.",
        tag: "Virtualisierung",
      },
      {
        title: "Natives systemd & Screen-Support",
        desc: "Läuft unter einem isolierten Systembenutzer mit automatischem Neustart bei Host-Boot, sicherem SIGTERM-Shutdown und interaktivem Konsolenzugriff per screen.",
        tag: "Betrieb",
      },
      {
        title: "Bedrock Dedicated Server Helfer",
        desc: "Host-Level-Skript zur sekundenschnellen Erstellung von Bedrock-Containern, inklusive UDP-Port-Handhabung, Firewall-Anleitung und headless Betrieb.",
        tag: "Cross-Play",
      },
    ],
  },
  architecture: {
    kicker: "03 / ARCHITEKTUR",
    title: "VM vs. LXC Container im Vergleich",
    subtitle:
      "Wähle das Virtualisierungsmodell, das zu deiner Homelab-Hardware und deinen Anforderungen passt.",
    vmTitle: "KVM Virtuelle Maschine",
    vmDesc:
      "Ideal für maximale Isolation, eigene Kernel-Module und nahtlose Proxmox-Backup-Integration.",
    vmItems: [
      "Vollständige Betriebssystem- und Kernel-Isolation",
      "Dedizierte RAM-Zuweisung mit Memory Ballooning",
      "Keine Container-Berechtigungs- oder Socket-Sonderfälle",
      "Einfache Live-Migration über Proxmox-Cluster-Nodes",
    ],
    lxcTitle: "LXC Linux Container",
    lxcDesc:
      "Ideal für maximale Tick-Rate, minimalen Speicherbedarf und viele Serverinstanzen auf kleineren Nodes.",
    lxcItems: [
      "Nahezu kein CPU- und RAM-Hypervisor-Overhead",
      "Sofortiger Start in unter 3 Sekunden",
      "Vorkonfiguriertes /run/screen Socket-Verzeichnis",
      "Deutlich geringerer RAM-Grundbedarf pro Minecraft-Instanz",
    ],
    bedrockTitle: "Bedrock Server Unterstützung",
    bedrockDesc:
      "Native C++ Bedrock Dedicated Server Binaries, optimiert für iOS, Android, Xbox und Windows.",
    bedrockItems: [
      "Natives UDP 19132 Port-Routing",
      "Direkt nutzbarer Proxmox CT-Erstellungshelfer",
      "Kein Java-Laufzeit-Overhead erforderlich",
      "Automatisierter systemd-Dienst für Hintergrundbetrieb",
    ],
  },
  techSpecs: {
    kicker: "04 / TECHNISCHE PRÜFUNG",
    title: "Spezifikationen & Kompatibilität",
    subtitle:
      "Geprüft und verifiziert für aktuelle Proxmox VE Releases und Enterprise-Linux-Distributionen.",
    compatibilityTitle: "Unterstützte Plattformen",
    compatibilityList: [
      "Proxmox VE 7.4+",
      "Proxmox VE 8.x",
      "Proxmox VE 9.x",
      "Debian 12 (Bookworm)",
      "Debian 13 (Trixie)",
      "Ubuntu 22.04 LTS",
      "Ubuntu 24.04 LTS",
      "OpenJDK Java 21",
    ],
    guardrailTitle: "Sicherer Betrieb & Passwörter",
    guardrailDesc:
      "Host-Skripte generieren sichere Zufallspasswörter für neu erstellte Container und geben Zugangsdaten niemals im Klartext in Demonstrationen oder öffentlichen Logs aus.",
    fillV3Title: "PaperMC Fill v3 API Protokoll",
    fillV3Desc:
      "Nutzt semantische Versionsauflösung (.versions | sort | last) mit STABLE-Kanalprüfung und direkten fill-data.papermc.io Endpunkten — löst die veraltete v2 API vollständig ab.",
    jvmTitle: "JVM Speicherformel",
    jvmDesc:
      "Xms = floor(RAM_MB * 0.25)M · Xmx = min(floor(RAM_MB * 0.50), 16384)M · Automatisch abgestimmt mit Aikar-kompatiblen Flags für stabile Garbage Collection.",
  },
  sources: {
    kicker: "05 / DOKUMENTATION",
    title: "Vollständige Dokumentation & Anleitungen",
    subtitle:
      "Jedes Skript, jede Architekturentscheidung und jeder Troubleshooting-Schritt ist im Repository detailliert dokumentiert.",
    items: [
      {
        title: "English README",
        desc: "Umfassender Setup-Guide, Backup-Strategien, Fehlerbehebung und Konfigurationsoptionen.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox#readme",
        badge: "README.md",
      },
      {
        title: "Deutsche Dokumentation",
        desc: "Vollständige deutsche Anleitung mit Schnellstart, Fehlerbehebung und Praxistipps.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/README.de.md",
        badge: "README.de.md",
      },
      {
        title: "Server-Befehle Übersicht",
        desc: "Praktische In-Game- und Konsolenbefehle für Serverbetreiber und Administratoren.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/SERVER_COMMANDS.md",
        badge: "COMMANDS",
      },
      {
        title: "Bedrock Netzwerk-Leitfaden",
        desc: "Portweiterleitung, NAT-Loopback und Firewall-Konfiguration für Bedrock-Clients.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/docs/BEDROCK_NETWORKING.md",
        badge: "NETWORKING",
      },
      {
        title: "Simulations- & Test-Leitfaden",
        desc: "Vorgehensweise zum Testen und Simulieren der Server-Einrichtung ohne Systemänderungen.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/SIMULATION.md",
        badge: "SIMULATION",
      },
      {
        title: "GitHub Releases & Changelog",
        desc: "Versionshistorie, Release Notes und Download-Pakete aller v3.x Versionen.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/releases",
        badge: "RELEASES",
      },
    ],
  },
  ctaSection: {
    title: "Bereit für deinen Minecraft Server auf Proxmox?",
    desc: "Klone das Repository, prüfe die Shell-Skripte oder starte direkt mit einem einzigen Befehl.",
    btnGithub: "Auf GitHub ansehen",
    btnReleases: "v3.0 Herunterladen",
    btnDocs: "Zur Dokumentation",
  },
  footer: {
    brandSubtitle: "HOMELAB RUNBOOK",
    tagline:
      "Automatisiertes Minecraft-Server-Setup auf Proxmox VE · Open Source MIT Lizenz",
    scrollTop: "Nach oben",
    author: "Entwickelt von Tim Baumann (@TimInTech)",
  },
};
