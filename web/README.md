# Minecraft Server on Proxmox – Landingpage

Bilingual (German / English) static landingpage for [`TimInTech/minecraft-server-Proxmox`](https://github.com/TimInTech/minecraft-server-Proxmox).

Built with React 19, TypeScript, Vite, Tailwind CSS v4, and Radix UI. Zero backend dependencies, fully static, designed for deployment on GitHub Pages.

## 🚀 Local Development

```bash
# 1. Install dependencies
pnpm install

# 2. Start local development server (http://localhost:3000)
pnpm dev

# 3. Run TypeScript type check
pnpm check

# 4. Create production static build (outputs to dist/)
pnpm build

# 5. Preview production build locally (http://localhost:4173)
pnpm preview
```

## 🌐 Language Structure & i18n

- **English (Default):** `/` or `/minecraft-server-Proxmox/`
- **German:** `/de` or `/minecraft-server-Proxmox/de`
- Translation dictionaries are managed centrally under `client/src/i18n/`:
  - `types.ts` – TypeScript translation schema
  - `en.ts` – English copy
  - `de.ts` – German copy
  - `index.tsx` – React Context Provider & `useTranslation` hook

## 📦 GitHub Pages Deployment

The automated workflow `.github/workflows/pages.yml` triggers on pushes to `main`, installs dependencies with pnpm, builds the static artifact with base path `/minecraft-server-Proxmox/`, and publishes directly to GitHub Pages.

Live URL: `https://timintech.github.io/minecraft-server-Proxmox/`
