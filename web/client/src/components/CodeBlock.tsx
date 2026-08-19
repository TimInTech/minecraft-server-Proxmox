import React, { useState } from "react";
import { Check, Copy, Terminal } from "lucide-react";
import { useTranslation } from "@/i18n";

interface CodeBlockProps {
  command: string;
  label?: string;
  className?: string;
}

export function CodeBlock({
  command,
  label = "bash",
  className = "",
}: CodeBlockProps) {
  const [copied, setCopied] = useState(false);
  const { t } = useTranslation();

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(command);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Fallback for older browsers
      const textarea = document.createElement("textarea");
      textarea.value = command;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand("copy");
      document.body.removeChild(textarea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <div
      className={`overflow-hidden rounded bg-[#18201d] border border-[#354038] shadow-lg ${className}`}
    >
      <div className="flex items-center justify-between px-3.5 py-2 bg-[#232b27] border-b border-[#354038] text-xs font-mono text-[#aeb4ab]">
        <div className="flex items-center gap-2">
          <div className="flex gap-1.5" aria-hidden="true">
            <span className="w-2.5 h-2.5 rounded-full bg-[#c9783a]" />
            <span className="w-2.5 h-2.5 rounded-full bg-[#6a716b]" />
            <span className="w-2.5 h-2.5 rounded-full bg-[#6a716b]" />
          </div>
          <span className="flex items-center gap-1.5 text-[11px] text-[#c9783a]">
            <Terminal size={12} /> {label}
          </span>
        </div>
        <button
          onClick={handleCopy}
          className="flex items-center gap-1.5 px-2.5 py-1 rounded bg-[#2c3732] hover:bg-[#384640] text-[#e5e9e2] text-xs transition-colors"
          aria-label={copied ? t.quickstart.copiedBtn : t.quickstart.copyBtn}
        >
          {copied ? (
            <>
              <Check size={13} className="text-[#83b46f]" />
              <span className="text-[#83b46f] font-medium">
                {t.quickstart.copiedBtn}
              </span>
            </>
          ) : (
            <>
              <Copy size={13} className="text-[#dea16e]" />
              <span>{t.quickstart.copyBtn}</span>
            </>
          )}
        </button>
      </div>
      <div className="p-4 overflow-x-auto font-mono text-sm text-[#e5e9e2] leading-relaxed bg-[#18201d]">
        <code className="select-all block text-white/95 break-all whitespace-pre-wrap">
          {command}
        </code>
      </div>
    </div>
  );
}
