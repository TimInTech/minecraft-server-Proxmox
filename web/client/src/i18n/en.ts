import { TranslationSchema } from "./types";

export const en: TranslationSchema = {
  meta: {
    title: "Minecraft Server on Proxmox – Automated Java & Bedrock",
    description:
      "Production-ready automated Minecraft Server setup (PaperMC Java & Bedrock Dedicated) on Proxmox VE. Supports VMs and LXC/CT with Fill v3 API, SHA256 validation, and auto-updates.",
  },
  nav: {
    overview: "Overview",
    quickstart: "Quickstart",
    demos: "Terminal Demos",
    features: "Features",
    architecture: "Architecture",
    techSpecs: "Tech Specs",
    sources: "Documentation",
    githubRepo: "GitHub Repo",
    verifiedRevision: "VERSION 3.0",
    staticBuild: "Homelab Tested",
    switchLang: "Sprache wechseln",
  },
  hero: {
    badge: "PROXMOX VE AUTOMATION",
    titleMain: "Minecraft Server on Proxmox.",
    titleHighlight: "Automated, verified, production-ready.",
    subtitle:
      "Deploy high-performance PaperMC Java or Bedrock Dedicated servers on Proxmox VE in minutes. Full support for VMs, LXC containers, Fill v3 API, and automated maintenance.",
    ctaPrimary: "Get Started",
    ctaSecondary: "View on GitHub",
    statusReady: "V3.0 READY",
    oneCommandNote: "One-command setup · VM & LXC · Auto-Update",
  },
  stats: {
    version: { label: "LATEST RELEASE", value: "v3.0.0" },
    api: { label: "PAPERMC API", value: "Fill v3 REST" },
    virtualization: { label: "TARGET ENV", value: "VM + LXC/CT" },
    integrity: { label: "VALIDATION", value: "SHA256 & Channels" },
  },
  quickstart: {
    kicker: "01 / QUICKSTART",
    title: "Deploy with a Single Command",
    subtitle:
      "Select your target architecture and run the verified provisioning script inside your Proxmox guest or host.",
    tabs: {
      vm: "Java VM",
      lxc: "Java LXC / CT",
      bedrock: "Bedrock CT Helper",
      update: "Auto-Update",
    },
    vm: {
      title: "Minecraft Java Server on Debian / Ubuntu VM",
      desc: "Installs Java 21, sets up user 'minecraft', downloads the latest stable PaperMC build via Fill v3 API, configures screen sessions and creates a systemd service.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft.sh | bash",
      bullets: [
        "Automatic RAM scaling (Xms ≈ RAM/4, Xmx ≈ RAM/2, max 16G)",
        "SHA-256 integrity verification against PaperMC API",
        "Configures systemd service with automated restart",
        "Screen session management with clean console attach",
      ],
    },
    lxc: {
      title: "Minecraft Java Server inside Proxmox LXC Container",
      desc: "Optimized specifically for unprivileged or privileged LXC containers with runtime socket preparation and lightweight resource footprint.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/setup_minecraft_lxc.sh | bash",
      bullets: [
        "Creates /run/screen socket directory with correct permissions",
        "Eliminates VM hypervisor overhead for maximum tick rates",
        "PaperMC Fill v3 API download with User-Agent & Stable channel",
        "Automated backup and rollback structure",
      ],
    },
    bedrock: {
      title: "Bedrock Dedicated Server CT Provisioner",
      desc: "Executed on the Proxmox VE host to automatically download Debian template, provision an LXC container, configure networking and start Bedrock Dedicated Server.",
      command:
        "curl -fsSL https://raw.githubusercontent.com/TimInTech/minecraft-server-Proxmox/main/scripts/proxmox_create_ct_bedrock.sh | bash",
      bullets: [
        "Fully automated Proxmox container creation (pct create)",
        "Randomized CT root password for homelab security",
        "Configures UDP port 19132 for cross-platform Bedrock clients",
        "Includes systemd service for zero-touch auto-start",
      ],
    },
    update: {
      title: "Self-Updating Daemon & Maintenance",
      desc: "The included update script checks for new stable PaperMC releases, verifies build hashes, backs up the current JAR, and performs a graceful restart.",
      command: "sudo /opt/minecraft/update.sh",
      bullets: [
        "Safe in-place update with automated fallback rollback",
        "Filters only STABLE channel builds to prevent world corruption",
        "Can be scheduled via crontab or systemd timer",
        "Notifies attached players before server restart",
      ],
    },
    copyBtn: "Copy Command",
    copiedBtn: "Copied to Clipboard!",
  },
  demos: {
    kicker: "02 / LIVE TERMINAL DEMOS",
    title: "Verified Live on Proxmox VE",
    subtitle:
      "Watch real-time live terminal recordings demonstrating container verification, automated health checks, and practical post-install server management.",
    tabs: {
      verification: "01 · Live Container Verification",
      usage: "02 · Practical Server Management",
    },
    verification: {
      badge: "LIVE CT 120 HEALTH CHECK",
      title: "Automated PaperMC LXC Verification",
      desc: "Real live verification run on Proxmox VE (Container 120). Checks container network interfaces, systemd service state, Fill v3 API build updater, log stream, and LAN port 25565 reachability.",
      bullet1: "Container IP & network bridge check (192.168.178.125)",
      bullet2: "Live PaperMC Fill v3 API update & SHA256 integrity check",
      bullet3: "Zero-error systemd status & port 25565 connectivity",
    },
    usage: {
      badge: "POST-INSTALL ADMIN WORKFLOW",
      title: "Practical Server Management in Action",
      desc: "Demonstrates common day-to-day administrative actions performed directly on the server without needing an active Minecraft client connected.",
      bullet1: "Service status audit & JVM memory allocation inspection",
      bullet2: "Server configuration properties & operator/whitelist check",
      bullet3: "Instant automated world & config archive backup (/var/backups/minecraft/)",
    },
  },
  features: {
    kicker: "03 / CORE CAPABILITIES",
    title: "Engineered for Homelab Reliability",
    subtitle:
      "Built from real production homelab experience — focusing on stability, security, and zero manual hassle.",
    items: [
      {
        title: "Fill v3 REST API Integration",
        desc: "Migrated to PaperMC's modern Fill v3 API with semantic version sorting, custom User-Agent, and direct STABLE channel filtering. No 404s or broken build parsing.",
        tag: "Core Engine",
      },
      {
        title: "SHA256 & Size Integrity Checks",
        desc: "Every downloaded JAR is validated against the upstream hash and minimum file size threshold. Eliminates silent failures and HTML error pages saved as JARs.",
        tag: "Security",
      },
      {
        title: "Adaptive JVM Memory Sizing",
        desc: "Dynamic heap calculation tailored to your Proxmox guest allocation: Initial heap at ~25% RAM, maximum heap at ~50% RAM, intelligently capped at 16 GB.",
        tag: "Performance",
      },
      {
        title: "VM & LXC Container Parity",
        desc: "Whether you prefer full kernel isolation in KVM VMs or minimal RAM footprint in lightweight LXC containers, both architectures receive first-class scripts.",
        tag: "Virtualization",
      },
      {
        title: "Native systemd & Screen Support",
        desc: "Run as an isolated system user with automatic reboot on host boot, graceful SIGTERM shutdown handling, and interactive console access via screen.",
        tag: "Operations",
      },
      {
        title: "Bedrock Dedicated Server Helper",
        desc: "Dedicated host-level script for spinning up Bedrock CTs in seconds, complete with UDP port handling, firewall guidance, and headless startup.",
        tag: "Cross-Play",
      },
    ],
  },
  architecture: {
    kicker: "04 / ARCHITECTURE",
    title: "VM vs. LXC Container Comparison",
    subtitle:
      "Choose the virtualization approach that fits your homelab hardware and performance requirements.",
    vmTitle: "KVM Virtual Machine",
    vmDesc:
      "Best for maximum isolation, custom kernel modules, and seamless Proxmox backup integration.",
    vmItems: [
      "Full OS and kernel isolation",
      "Dedicated RAM allocation with memory ballooning",
      "Zero container permission or socket complexities",
      "Simple live migration across Proxmox cluster nodes",
    ],
    lxcTitle: "LXC Linux Container",
    lxcDesc:
      "Best for maximum tick rate, low memory overhead, and dense server clustering on smaller nodes.",
    lxcItems: [
      "Near-zero CPU & RAM hypervisor overhead",
      "Instant startup in under 3 seconds",
      "Pre-configured /run/screen socket directory",
      "Substantially lower RAM baseline per Minecraft instance",
    ],
    bedrockTitle: "Bedrock Server Support",
    bedrockDesc:
      "Native C++ Bedrock Dedicated Server binaries optimized for iOS, Android, Xbox, and Windows clients.",
    bedrockItems: [
      "Native UDP 19132 port routing",
      "Ready-to-use Proxmox CT creation helper",
      "No Java runtime overhead required",
      "Automated systemd service daemon",
    ],
  },
  techSpecs: {
    kicker: "05 / TECHNICAL VERIFICATION",
    title: "Technical Specifications & Compatibility",
    subtitle:
      "Verified against current Proxmox VE releases and enterprise Linux distributions.",
    compatibilityTitle: "Supported Platforms",
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
    guardrailTitle: "Safe Operations & Passwords",
    guardrailDesc:
      "Host scripts generate secure random root passwords for newly created containers and never expose credentials in plain text during visual demonstrations or shared logs.",
    fillV3Title: "PaperMC Fill v3 API Protocol",
    fillV3Desc:
      "Uses semantic version resolution (.versions | sort | last) with STABLE channel validation and fill-data.papermc.io direct endpoints, replacing the legacy v2 API completely.",
    jvmTitle: "JVM Memory Formula",
    jvmDesc:
      "Xms = floor(RAM_MB * 0.25)M · Xmx = min(floor(RAM_MB * 0.50), 16384)M · Auto-tuned with Aikar-compatible flags for stable garbage collection.",
  },
  sources: {
    kicker: "06 / DOCUMENTATION",
    title: "Comprehensive Documentation & Guides",
    subtitle:
      "Every script, architecture decision, and troubleshooting step is thoroughly documented in the repository.",
    items: [
      {
        title: "English README",
        desc: "Complete setup guide, backup strategies, troubleshooting, and configuration options.",
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
        title: "Server Commands Cheat Sheet",
        desc: "Useful in-game and console commands for server operators and admins.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/SERVER_COMMANDS.md",
        badge: "COMMANDS",
      },
      {
        title: "Bedrock Networking Guide",
        desc: "Port forwarding, NAT loopback, and firewall configuration for Bedrock clients.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/docs/BEDROCK_NETWORKING.md",
        badge: "NETWORKING",
      },
      {
        title: "Simulation & Dry-Run Guide",
        desc: "How to test and simulate server provisioning without modifying host state.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/blob/main/SIMULATION.md",
        badge: "SIMULATION",
      },
      {
        title: "GitHub Releases & Changelog",
        desc: "Version history, release notes, and download packages for all v3.x versions.",
        url: "https://github.com/TimInTech/minecraft-server-Proxmox/releases",
        badge: "RELEASES",
      },
    ],
  },
  ctaSection: {
    title: "Ready to launch your Minecraft server on Proxmox?",
    desc: "Clone the repository, inspect the shell scripts, or deploy directly with a single curl command.",
    btnGithub: "Star on GitHub",
    btnReleases: "Download v3.0",
    btnDocs: "Read Full Docs",
  },
  footer: {
    brandSubtitle: "HOMELAB RUNBOOK",
    tagline:
      "Automated Minecraft Server provisioning on Proxmox VE · Open Source MIT License",
    scrollTop: "Back to top",
    author: "Created with care by Tim Baumann (@TimInTech)",
  },
};
