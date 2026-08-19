import React, { createContext, useContext, useEffect, useState } from "react";
import { de } from "./de";
import { en } from "./en";
import { Language, TranslationSchema } from "./types";

interface LanguageContextType {
  lang: Language;
  setLang: (lang: Language) => void;
  t: TranslationSchema;
}

const LanguageContext = createContext<LanguageContextType>({
  lang: "en",
  setLang: () => {},
  t: en,
});

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [lang, setLangState] = useState<Language>(() => {
    // Check URL path first (e.g. /de or /de/)
    if (typeof window !== "undefined") {
      const pathname = window.location.pathname.toLowerCase();
      if (pathname.includes("/de") || window.location.hash.includes("/de")) {
        return "de";
      }
      const saved = localStorage.getItem("app_lang") as Language;
      if (saved === "de" || saved === "en") {
        return saved;
      }
    }
    return "en";
  });

  const setLang = (newLang: Language) => {
    setLangState(newLang);
    try {
      localStorage.setItem("app_lang", newLang);
      document.documentElement.lang = newLang;
      document.title = (newLang === "de" ? de : en).meta.title;
    } catch {}
  };

  useEffect(() => {
    document.documentElement.lang = lang;
    document.title = (lang === "de" ? de : en).meta.title;
  }, [lang]);

  const t = lang === "de" ? de : en;

  return (
    <LanguageContext.Provider value={{ lang, setLang, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useTranslation = () => useContext(LanguageContext);
