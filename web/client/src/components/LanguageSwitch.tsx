import React from "react";
import { useTranslation } from "@/i18n";
import { Languages } from "lucide-react";

interface LanguageSwitchProps {
  className?: string;
}

export function LanguageSwitch({ className = "" }: LanguageSwitchProps) {
  const { lang, setLang } = useTranslation();

  return (
    <div
      className={`inline-flex items-center gap-1 bg-[#27312d] p-1 rounded border border-white/10 ${className}`}
    >
      <Languages
        size={14}
        className="text-[#dea16e] ml-1 mr-0.5"
        aria-hidden="true"
      />
      <button
        onClick={() => setLang("en")}
        className={`px-2 py-0.5 text-xs font-mono rounded transition-colors ${
          lang === "en"
            ? "bg-[#c9783a] text-[#1c211f] font-bold"
            : "text-[#d3d9d0] hover:text-white"
        }`}
        aria-label="Switch to English"
        aria-pressed={lang === "en"}
      >
        EN
      </button>
      <span className="text-white/20 text-xs select-none">|</span>
      <button
        onClick={() => setLang("de")}
        className={`px-2 py-0.5 text-xs font-mono rounded transition-colors ${
          lang === "de"
            ? "bg-[#c9783a] text-[#1c211f] font-bold"
            : "text-[#d3d9d0] hover:text-white"
        }`}
        aria-label="Zu Deutsch wechseln"
        aria-pressed={lang === "de"}
      >
        DE
      </button>
    </div>
  );
}
