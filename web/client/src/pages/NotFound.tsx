import React from "react";
import { Button } from "@/components/ui/button";
import { AlertCircle, Home as HomeIcon } from "lucide-react";
import { useTranslation } from "@/i18n";
import { Logo } from "@/components/Logo";

export default function NotFound() {
  const { lang, t } = useTranslation();

  const handleGoHome = () => {
    window.location.href = window.location.pathname.replace(/\/404.*$/, "/");
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-[#eeece7] text-[#1e2522] p-4">
      <div className="w-full max-w-md bg-[#faf9f5] border border-[#c9c5bc] border-t-4 border-t-[#c9783a] p-8 text-center shadow-lg">
        <div className="flex justify-center mb-4">
          <Logo className="w-12 h-12" />
        </div>

        <div className="inline-flex items-center gap-2 text-xs font-mono text-[#a45423] mb-3">
          <AlertCircle size={15} /> 404 NOT FOUND
        </div>

        <h1 className="text-3xl font-bold text-[#1e2522] mb-3">
          {lang === "de" ? "Seite nicht gefunden" : "Page Not Found"}
        </h1>

        <p className="font-serif text-[#5e625b] mb-6 leading-relaxed">
          {lang === "de"
            ? "Die angeforderte Dokumentationsseite oder URL existiert nicht."
            : "The requested documentation page or URL does not exist."}
        </p>

        <Button
          onClick={handleGoHome}
          className="bg-[#c9783a] hover:bg-[#dea16e] text-[#181a18] font-bold px-6 py-2 rounded"
        >
          <HomeIcon className="w-4 h-4 mr-2" />
          {lang === "de" ? "Zur Startseite" : "Return to Home"}
        </Button>
      </div>
    </div>
  );
}
