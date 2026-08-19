import React, { useState } from "react";
import {
  ArrowDownRight,
  ArrowUpRight,
  CheckCircle2,
  ChevronRight,
  Cpu,
  FileCode2,
  Github,
  HardDrive,
  Info,
  Layers,
  Menu,
  RefreshCw,
  Server,
  ShieldAlert,
  ShieldCheck,
  Sparkles,
  TerminalSquare,
  X,
  Zap,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTranslation } from "@/i18n";
import { Logo } from "@/components/Logo";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { CodeBlock } from "@/components/CodeBlock";

export default function Home() {
  const { t } = useTranslation();
  const [mobileMenu, setMobileMenu] = useState(false);
  const [activeTab, setActiveTab] = useState<
    "vm" | "lxc" | "bedrock" | "update"
  >("vm");

  const scrollToSection = (id: string) => {
    setMobileMenu(false);
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  const navItems = [
    { id: "quickstart", label: t.nav.quickstart, kicker: "01" },
    { id: "features", label: t.nav.features, kicker: "02" },
    { id: "architecture", label: t.nav.architecture, kicker: "03" },
    { id: "techspecs", label: t.nav.techSpecs, kicker: "04" },
    { id: "documentation", label: t.nav.sources, kicker: "05" },
  ];

  return (
    <div className="app-shell min-h-screen bg-[#eeece7] text-[#1e2522]">
      {/* Accessibility Skip Link */}
      <a className="skip-link" href="#main-content">
        {t.nav.overview}
      </a>

      {/* Mobile Topbar */}
      <header className="mobile-topbar">
        <button
          className="icon-button"
          onClick={() => setMobileMenu(curr => !curr)}
          aria-label="Toggle navigation menu"
        >
          {mobileMenu ? <X size={20} /> : <Menu size={20} />}
        </button>
        <div className="mobile-brand flex items-center gap-2">
          <Logo className="w-6 h-6" />
          <span className="font-bold text-sm tracking-wider">
            MINECRAFT{" "}
            <em className="text-[#dea16e] not-italic font-mono text-xs">
              PROXMOX
            </em>
          </span>
        </div>
        <div className="flex items-center gap-2">
          <LanguageSwitch />
          <a
            className="icon-button"
            href="https://github.com/TimInTech/minecraft-server-Proxmox"
            target="_blank"
            rel="noreferrer"
            aria-label="GitHub Repository"
          >
            <Github size={18} />
          </a>
        </div>
      </header>

      {/* Sidebar Navigation Rail (Desktop) */}
      <aside
        className={`rail ${mobileMenu ? "rail-open" : ""}`}
        aria-label="Documentation Navigation"
      >
        <div className="rail-brand">
          <Logo className="brand-mark" />
          <div>
            <p className="brand-name">MINECRAFT</p>
            <p className="brand-sub">PROXMOX · v3.0</p>
          </div>
        </div>

        {/* Language Switcher in Rail */}
        <div className="my-4">
          <LanguageSwitch className="w-full justify-center" />
        </div>

        <div className="rail-revision">
          <span>{t.nav.verifiedRevision}</span>
          <code>PaperMC Fill v3</code>
          <small>{t.nav.staticBuild}</small>
        </div>

        <nav className="section-nav">
          <p className="rail-label">{t.nav.overview.toUpperCase()}</p>
          {navItems.map(item => (
            <button key={item.id} onClick={() => scrollToSection(item.id)}>
              <span>{item.kicker}</span>
              {item.label}
              <ChevronRight size={15} />
            </button>
          ))}
        </nav>

        <div className="rail-status">
          <div className="status-dot" />
          <div>
            <p>{t.hero.statusReady}</p>
            <strong>Fill v3 &amp; SHA256</strong>
          </div>
        </div>

        <a
          className="repo-link"
          href="https://github.com/TimInTech/minecraft-server-Proxmox"
          target="_blank"
          rel="noreferrer"
        >
          <Github size={16} /> {t.nav.githubRepo} <ArrowUpRight size={15} />
        </a>
      </aside>

      {/* Main Content Area */}
      <main id="main-content" className="page-content">
        {/* Hero Section */}
        <section className="hero" aria-labelledby="hero-title">
          <div className="hero-overlay" />
          <div className="hero-content">
            <div className="hero-seal">
              <Logo className="w-6 h-6" />
              <div>
                <span>{t.hero.badge}</span>
                <small>PROXMOX VE · VM &amp; LXC</small>
              </div>
            </div>

            <p className="eyebrow light">
              <span>{t.stats.version.value}</span> / {t.hero.oneCommandNote}
            </p>

            <h1 id="hero-title" className="text-balance">
              {t.hero.titleMain}
              <br />
              <i>{t.hero.titleHighlight}</i>
            </h1>

            <p className="hero-copy">{t.hero.subtitle}</p>

            <div className="hero-actions">
              <Button
                className="copper-button"
                onClick={() => scrollToSection("quickstart")}
              >
                {t.hero.ctaPrimary} <ArrowDownRight size={17} />
              </Button>
              <a
                className="text-button"
                href="https://github.com/TimInTech/minecraft-server-Proxmox"
                target="_blank"
                rel="noreferrer"
              >
                <Github size={16} /> {t.hero.ctaSecondary}{" "}
                <ArrowUpRight size={16} />
              </a>
            </div>
          </div>

          {/* Key Stats Strip */}
          <div className="hero-footnote">
            <div className="flex items-center gap-4 flex-wrap">
              <div>
                <span className="pulse-dot" /> {t.hero.statusReady}
              </div>
              <span className="text-white/30 hidden sm:inline">|</span>
              <div>
                <code className="text-[#dea16e]">{t.stats.api.value}</code>
              </div>
              <span className="text-white/30 hidden sm:inline">|</span>
              <div>
                <span>{t.stats.virtualization.value}</span>
              </div>
            </div>
            <code>MIT License</code>
          </div>

          <div
            className="hero-evidence hidden md:block"
            aria-label="Release Meta"
          >
            <span>RELEASE</span>
            <strong>v3.0.0</strong>
            <small>PaperMC Fill v3</small>
          </div>
        </section>

        {/* Report Frame & Content Sections */}
        <section className="report-frame">
          {/* Quickstart Section (Interactive One-Command Installers) */}
          <section id="quickstart" className="content-section">
            <div className="section-marker">
              <span>01</span>
              <span>{t.quickstart.kicker}</span>
            </div>

            <div className="section-headline">
              <div>
                <h2>{t.quickstart.title}</h2>
                <p className="lead">{t.quickstart.subtitle}</p>
              </div>
              <div className="checked-stamp">
                <ShieldCheck size={20} />
                <span>
                  INTEGRITY
                  <br />
                  <b>VERIFIED</b>
                </span>
              </div>
            </div>

            {/* Quickstart Interactive Tabs */}
            <div className="mt-8">
              <div className="flex flex-wrap gap-2 border-b border-[#c9c5bc] pb-2">
                <button
                  onClick={() => setActiveTab("vm")}
                  className={`px-4 py-2 text-xs font-mono font-medium rounded transition-all flex items-center gap-2 ${
                    activeTab === "vm"
                      ? "bg-[#1c211f] text-white shadow-sm border-b-2 border-[#c9783a]"
                      : "bg-[#e5e1d9] text-[#4b514b] hover:bg-[#dedbd4]"
                  }`}
                >
                  <Server size={14} /> {t.quickstart.tabs.vm}
                </button>
                <button
                  onClick={() => setActiveTab("lxc")}
                  className={`px-4 py-2 text-xs font-mono font-medium rounded transition-all flex items-center gap-2 ${
                    activeTab === "lxc"
                      ? "bg-[#1c211f] text-white shadow-sm border-b-2 border-[#c9783a]"
                      : "bg-[#e5e1d9] text-[#4b514b] hover:bg-[#dedbd4]"
                  }`}
                >
                  <Layers size={14} /> {t.quickstart.tabs.lxc}
                </button>
                <button
                  onClick={() => setActiveTab("bedrock")}
                  className={`px-4 py-2 text-xs font-mono font-medium rounded transition-all flex items-center gap-2 ${
                    activeTab === "bedrock"
                      ? "bg-[#1c211f] text-white shadow-sm border-b-2 border-[#c9783a]"
                      : "bg-[#e5e1d9] text-[#4b514b] hover:bg-[#dedbd4]"
                  }`}
                >
                  <Zap size={14} /> {t.quickstart.tabs.bedrock}
                </button>
                <button
                  onClick={() => setActiveTab("update")}
                  className={`px-4 py-2 text-xs font-mono font-medium rounded transition-all flex items-center gap-2 ${
                    activeTab === "update"
                      ? "bg-[#1c211f] text-white shadow-sm border-b-2 border-[#c9783a]"
                      : "bg-[#e5e1d9] text-[#4b514b] hover:bg-[#dedbd4]"
                  }`}
                >
                  <RefreshCw size={14} /> {t.quickstart.tabs.update}
                </button>
              </div>

              {/* Active Tab Panel */}
              <div className="mt-6 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                <div className="lg:col-span-5 space-y-4">
                  <h3 className="text-xl font-bold text-[#1e2522]">
                    {t.quickstart[activeTab].title}
                  </h3>
                  <p className="font-serif text-[#5e625b] text-base leading-relaxed">
                    {t.quickstart[activeTab].desc}
                  </p>

                  <ul className="space-y-2 pt-2">
                    {t.quickstart[activeTab].bullets.map((bullet, idx) => (
                      <li
                        key={idx}
                        className="flex items-start gap-2.5 text-sm text-[#4b514b]"
                      >
                        <CheckCircle2
                          size={16}
                          className="text-[#c9783a] shrink-0 mt-0.5"
                        />
                        <span>{bullet}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="lg:col-span-7">
                  <CodeBlock
                    command={t.quickstart[activeTab].command}
                    label={
                      activeTab === "bedrock"
                        ? "pve-host # bash"
                        : "guest $ bash"
                    }
                  />
                  <p className="mt-2 text-xs font-mono text-[#8b897f]">
                    ℹ️ Run directly via SSH or Proxmox console in your target
                    guest/host.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Features Section */}
          <section id="features" className="content-section">
            <div className="section-marker">
              <span>02</span>
              <span>{t.features.kicker}</span>
            </div>

            <div className="mt-6">
              <h2>{t.features.title}</h2>
              <p className="lead">{t.features.subtitle}</p>
            </div>

            <div className="diagnosis-grid mt-10">
              {t.features.items.map((item, index) => (
                <article className="diagnosis-card" key={index}>
                  <div className="flex justify-between items-center">
                    <span className="card-number">0{index + 1}</span>
                    <span className="text-[10px] font-mono uppercase bg-[#c9783a]/15 text-[#a45423] px-2 py-0.5 rounded">
                      {item.tag}
                    </span>
                  </div>
                  <h3>{item.title}</h3>
                  <p>{item.desc}</p>
                  <div className="rating">
                    <span /> Verified in v3.0
                  </div>
                </article>
              ))}
            </div>
          </section>

          {/* Architecture Section */}
          <section id="architecture" className="content-section flow-section">
            <div className="section-marker">
              <span>03</span>
              <span>{t.architecture.kicker}</span>
            </div>

            <div className="mt-6">
              <h2>{t.architecture.title}</h2>
              <p className="lead">{t.architecture.subtitle}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-10">
              {/* VM Card */}
              <div className="bg-[#faf9f5] border border-[#c9c5bc] border-t-4 border-t-[#c9783a] p-6 shadow-sm flex flex-col justify-between">
                <div>
                  <div className="flex items-center gap-3 mb-4">
                    <div className="p-2.5 bg-[#c9783a]/10 text-[#c9783a] rounded">
                      <Server size={22} />
                    </div>
                    <h3 className="text-lg font-bold">
                      {t.architecture.vmTitle}
                    </h3>
                  </div>
                  <p className="font-serif text-[#5e625b] text-sm mb-5 leading-relaxed">
                    {t.architecture.vmDesc}
                  </p>
                  <ul className="space-y-2 border-t border-[#c9c5bc]/50 pt-4 text-xs font-mono text-[#4b514b]">
                    {t.architecture.vmItems.map((item, idx) => (
                      <li key={idx} className="flex items-center gap-2">
                        <span className="text-[#c9783a]">✓</span> {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="mt-6 pt-4 border-t border-[#c9c5bc]/40 text-xs font-mono text-[#8b897f]">
                  Script: <code>setup_minecraft.sh</code>
                </div>
              </div>

              {/* LXC Card */}
              <div className="bg-[#faf9f5] border border-[#c9c5bc] border-t-4 border-t-[#7fa776] p-6 shadow-sm flex flex-col justify-between">
                <div>
                  <div className="flex items-center gap-3 mb-4">
                    <div className="p-2.5 bg-[#7fa776]/10 text-[#487042] rounded">
                      <Layers size={22} />
                    </div>
                    <h3 className="text-lg font-bold">
                      {t.architecture.lxcTitle}
                    </h3>
                  </div>
                  <p className="font-serif text-[#5e625b] text-sm mb-5 leading-relaxed">
                    {t.architecture.lxcDesc}
                  </p>
                  <ul className="space-y-2 border-t border-[#c9c5bc]/50 pt-4 text-xs font-mono text-[#4b514b]">
                    {t.architecture.lxcItems.map((item, idx) => (
                      <li key={idx} className="flex items-center gap-2">
                        <span className="text-[#487042]">✓</span> {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="mt-6 pt-4 border-t border-[#c9c5bc]/40 text-xs font-mono text-[#8b897f]">
                  Script: <code>setup_minecraft_lxc.sh</code>
                </div>
              </div>

              {/* Bedrock Card */}
              <div className="bg-[#faf9f5] border border-[#c9c5bc] border-t-4 border-t-[#79a5b9] p-6 shadow-sm flex flex-col justify-between">
                <div>
                  <div className="flex items-center gap-3 mb-4">
                    <div className="p-2.5 bg-[#79a5b9]/10 text-[#3e6f85] rounded">
                      <Zap size={22} />
                    </div>
                    <h3 className="text-lg font-bold">
                      {t.architecture.bedrockTitle}
                    </h3>
                  </div>
                  <p className="font-serif text-[#5e625b] text-sm mb-5 leading-relaxed">
                    {t.architecture.bedrockDesc}
                  </p>
                  <ul className="space-y-2 border-t border-[#c9c5bc]/50 pt-4 text-xs font-mono text-[#4b514b]">
                    {t.architecture.bedrockItems.map((item, idx) => (
                      <li key={idx} className="flex items-center gap-2">
                        <span className="text-[#3e6f85]">✓</span> {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="mt-6 pt-4 border-t border-[#c9c5bc]/40 text-xs font-mono text-[#8b897f]">
                  Script: <code>proxmox_create_ct_bedrock.sh</code>
                </div>
              </div>
            </div>
          </section>

          {/* Technical Specs & Verification */}
          <section id="techspecs" className="content-section limits-section">
            <div className="section-marker">
              <span>04</span>
              <span>{t.techSpecs.kicker}</span>
            </div>

            <div className="mt-6">
              <h2>{t.techSpecs.title}</h2>
              <p className="lead">{t.techSpecs.subtitle}</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 mt-8 items-start">
              <div className="lg:col-span-7 space-y-6">
                <div className="bg-[#faf9f5] p-6 border border-[#c9c5bc] rounded shadow-sm">
                  <h3 className="text-sm font-mono uppercase text-[#a45423] tracking-wider mb-3">
                    {t.techSpecs.compatibilityTitle}
                  </h3>
                  <div className="compatibility-tags">
                    {t.techSpecs.compatibilityList.map((spec, idx) => (
                      <span key={idx}>{spec}</span>
                    ))}
                  </div>
                </div>

                <div className="warning-panel">
                  <Info size={22} />
                  <div>
                    <h4 className="font-bold text-[#5b4939] text-sm">
                      {t.techSpecs.fillV3Title}
                    </h4>
                    <p className="mt-1">{t.techSpecs.fillV3Desc}</p>
                  </div>
                </div>

                <div className="bg-[#faf9f5] p-5 border-l-4 border-l-[#7fa776] border border-[#c9c5bc] text-xs font-mono text-[#4b514b]">
                  <p className="font-bold text-[#354038] mb-1">
                    {t.techSpecs.jvmTitle}
                  </p>
                  <code>{t.techSpecs.jvmDesc}</code>
                </div>
              </div>

              <div className="lg:col-span-5">
                <div className="security-note rounded">
                  <TerminalSquare size={24} />
                  <div>
                    <p className="card-label">SECURITY &amp; CREDENTIALS</p>
                    <strong>{t.techSpecs.guardrailTitle}</strong>
                    <span className="text-sm">{t.techSpecs.guardrailDesc}</span>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Documentation & Sources Section */}
          <section
            id="documentation"
            className="content-section source-section"
          >
            <div className="section-marker">
              <span>05</span>
              <span>{t.sources.kicker}</span>
            </div>

            <div className="source-head">
              <div>
                <h2>{t.sources.title}</h2>
                <p>{t.sources.subtitle}</p>
              </div>
              <a
                href="https://github.com/TimInTech/minecraft-server-Proxmox"
                target="_blank"
                rel="noreferrer"
              >
                GitHub Repository <ArrowUpRight size={17} />
              </a>
            </div>

            <div className="source-list">
              {t.sources.items.map((item, index) => (
                <a
                  key={index}
                  className="source-row"
                  href={item.url}
                  target="_blank"
                  rel="noreferrer"
                >
                  <span>0{index + 1}</span>
                  <FileCode2 size={20} />
                  <div>
                    <strong>{item.title}</strong>
                    <small>{item.badge}</small>
                  </div>
                  <p>{item.desc}</p>
                  <ArrowUpRight size={18} />
                </a>
              ))}
            </div>
          </section>

          {/* CTA Banner Section */}
          <section className="p-10 md:p-14 bg-[#1c211f] text-[#f8f3eb] border-t border-[#354038] text-center">
            <h2 className="text-2xl md:text-4xl font-bold tracking-tight text-balance">
              {t.ctaSection.title}
            </h2>
            <p className="max-w-2xl mx-auto font-serif text-[#d0d4cc] text-base md:text-lg mt-4 mb-8">
              {t.ctaSection.desc}
            </p>
            <div className="flex justify-center gap-4 flex-wrap">
              <a
                href="https://github.com/TimInTech/minecraft-server-Proxmox"
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-2 px-6 py-3 bg-[#c9783a] hover:bg-[#dea16e] text-[#181a18] font-bold rounded text-sm transition-all"
              >
                <Github size={18} /> {t.ctaSection.btnGithub}
              </a>
              <a
                href="https://github.com/TimInTech/minecraft-server-Proxmox/releases/latest"
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-2 px-6 py-3 bg-[#27312d] hover:bg-[#34423d] text-[#f8f3eb] font-semibold border border-white/20 rounded text-sm transition-all"
              >
                <Sparkles size={18} /> {t.ctaSection.btnReleases}
              </a>
            </div>
          </section>
        </section>

        {/* Footer */}
        <footer className="site-footer">
          <div className="footer-brand">
            <Logo className="w-6 h-6" />
            <span>
              MINECRAFT <em>PROXMOX</em>
            </span>
          </div>
          <p>{t.footer.tagline}</p>
          <div className="flex items-center gap-6">
            <span className="text-xs text-[#868e85]">{t.footer.author}</span>
            <a
              href="#main-content"
              className="hover:text-white transition-colors"
            >
              {t.footer.scrollTop} <ArrowDownRight size={15} />
            </a>
          </div>
        </footer>
      </main>
    </div>
  );
}
