export type Language = "en" | "de";

export interface TranslationSchema {
  meta: {
    title: string;
    description: string;
  };
  nav: {
    overview: string;
    quickstart: string;
    features: string;
    architecture: string;
    techSpecs: string;
    sources: string;
    githubRepo: string;
    verifiedRevision: string;
    staticBuild: string;
    switchLang: string;
  };
  hero: {
    badge: string;
    titleMain: string;
    titleHighlight: string;
    subtitle: string;
    ctaPrimary: string;
    ctaSecondary: string;
    statusReady: string;
    oneCommandNote: string;
  };
  stats: {
    version: { label: string; value: string };
    api: { label: string; value: string };
    virtualization: { label: string; value: string };
    integrity: { label: string; value: string };
  };
  quickstart: {
    kicker: string;
    title: string;
    subtitle: string;
    tabs: {
      vm: string;
      lxc: string;
      bedrock: string;
      update: string;
    };
    vm: {
      title: string;
      desc: string;
      command: string;
      bullets: string[];
    };
    lxc: {
      title: string;
      desc: string;
      command: string;
      bullets: string[];
    };
    bedrock: {
      title: string;
      desc: string;
      command: string;
      bullets: string[];
    };
    update: {
      title: string;
      desc: string;
      command: string;
      bullets: string[];
    };
    copyBtn: string;
    copiedBtn: string;
  };
  features: {
    kicker: string;
    title: string;
    subtitle: string;
    items: Array<{
      title: string;
      desc: string;
      tag: string;
    }>;
  };
  architecture: {
    kicker: string;
    title: string;
    subtitle: string;
    vmTitle: string;
    vmDesc: string;
    vmItems: string[];
    lxcTitle: string;
    lxcDesc: string;
    lxcItems: string[];
    bedrockTitle: string;
    bedrockDesc: string;
    bedrockItems: string[];
  };
  techSpecs: {
    kicker: string;
    title: string;
    subtitle: string;
    compatibilityTitle: string;
    compatibilityList: string[];
    guardrailTitle: string;
    guardrailDesc: string;
    fillV3Title: string;
    fillV3Desc: string;
    jvmTitle: string;
    jvmDesc: string;
  };
  sources: {
    kicker: string;
    title: string;
    subtitle: string;
    items: Array<{
      title: string;
      desc: string;
      url: string;
      badge: string;
    }>;
  };
  ctaSection: {
    title: string;
    desc: string;
    btnGithub: string;
    btnReleases: string;
    btnDocs: string;
  };
  footer: {
    brandSubtitle: string;
    tagline: string;
    scrollTop: string;
    author: string;
  };
}
