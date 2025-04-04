#!/bin/bash

# Verifica se o nome do projeto foi fornecido
if [ -z "$1" ]; then
  echo "Por favor, forneça o nome do projeto."
  echo "Uso: sh install.sh nome-do-projeto"
  exit 1
fi

# Pega o nome do projeto do primeiro argumento
PROJETO="$1"

# Cria um novo projeto Remix com o nome do projeto informado
pnpm dlx create-remix@latest "$PROJETO" -y

# Navega para o diretório do projeto recém-criado
cd "$PROJETO" || { echo "Falha ao navegar para o diretório do projeto!"; exit 1; }

# Inicializa Shadcn/UI com tema slate
pnpm dlx shadcn@latest init --yes -b slate 

# Adiciona todos os componentes do Shadcn
pnpm dlx shadcn@latest add --all

# Cria o arquivo de configuração do Vite
cat > vite.config.ts <<EOF
import { vitePlugin as remix } from "@remix-run/dev";
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

declare module "@remix-run/node" {
  interface Future {
    v3_singleFetch: true;
  }
}

export default defineConfig({
  plugins: [
    remix({
      future: {
        v3_fetcherPersist: true,
        v3_relativeSplatPath: true,
        v3_throwAbortReason: true,
        v3_singleFetch: true,
        v3_lazyRouteDiscovery: true,
      },
    }), 
    tsconfigPaths(),
  ],
  server: {
    port: 3000,
    host: true,
    // open: true,
    strictPort: true,
  },
});
EOF

# Executa o script de configuração do modo escuro
# Script para instalação do Dark Mode em uma aplicação Remix

# Instalar dependências necessárias
echo "Instalando remix-themes..."
pnpm add remix-themes clsx

# Criar o arquivo tailwind.css se não existir
  mkdir -p app
  cat > "app/tailwind.css" << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;

html,
body {
  @apply bg-white dark:bg-gray-950;

  @media (prefers-color-scheme: dark) {
    color-scheme: dark;
  }
}



@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --chart-1: 12 76% 61%;
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;
    --radius: 0.5rem;
    --sidebar-background: 0 0% 98%;
    --sidebar-foreground: 240 5.3% 26.1%;
    --sidebar-primary: 240 5.9% 10%;
    --sidebar-primary-foreground: 0 0% 98%;
    --sidebar-accent: 240 4.8% 95.9%;
    --sidebar-accent-foreground: 240 5.9% 10%;
    --sidebar-border: 220 13% 91%;
    --sidebar-ring: 217.2 91.2% 59.8%;
  }
  :root[class~="dark"] {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
    --chart-1: 220 70% 50%;
    --chart-2: 160 60% 45%;
    --chart-3: 30 80% 55%;
    --chart-4: 280 65% 60%;
    --chart-5: 340 75% 55%;
    --sidebar-background: 240 5.9% 10%;
    --sidebar-foreground: 240 4.8% 95.9%;
    --sidebar-primary: 224.3 76.3% 48%;
    --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 240 3.7% 15.9%;
    --sidebar-accent-foreground: 240 4.8% 95.9%;
    --sidebar-border: 240 3.7% 15.9%;
    --sidebar-ring: 217.2 91.2% 59.8%;
  }
}



@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

EOL
  echo "✅ Arquivo tailwind.css criado"


# Criar o arquivo sessions.server.tsx
echo "Criando sessions.server.tsx..."
mkdir -p app
cat > "app/sessions.server.tsx" << EOL
import { createThemeSessionResolver } from "remix-themes"
import { createCookieSessionStorage } from "@remix-run/node"

// You can default to 'development' if process.env.NODE_ENV is not set
const isProduction = process.env.NODE_ENV === "production"

const sessionStorage = createCookieSessionStorage({
  cookie: {
    name: "theme",
    path: "/",
    httpOnly: true,
    sameSite: "lax",
    secrets: ["s3cr3t"],
    // Set domain and secure only if in production
    ...(isProduction
      ? { domain: "your-production-domain.com", secure: true }
      : {}),
  },
})

export const themeSessionResolver = createThemeSessionResolver(sessionStorage)
EOL
echo "✅ Arquivo sessions.server.tsx criado"

# Criar o arquivo action.set-theme.ts
echo "Criando action.set-theme.ts..."
mkdir -p app/routes
cat > "app/routes/action.set-theme.ts" << EOL
import { createThemeAction } from "remix-themes"

import { themeSessionResolver } from "~/sessions.server"

export const action = createThemeAction(themeSessionResolver)
EOL
echo "✅ Arquivo action.set-theme.ts criado"

# Criar o componente mode-toggle.tsx
echo "Criando mode-toggle.tsx..."
mkdir -p app/components/ui
cat > "app/components/mode-toggle.tsx" << EOL
import { Moon, Sun } from "lucide-react"
import { Theme, useTheme } from "remix-themes"

import { Button } from "./ui/button"

export function ModeToggle() {
  const [theme, setTheme] = useTheme()

  function toggleTheme() {
    setTheme(theme === Theme.DARK ? Theme.LIGHT : Theme.DARK)
  }

  return (
    <Button variant="ghost" size="icon" onClick={toggleTheme}>
      <Sun className="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-[1.2rem] w-[1.2rem] rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Alternar tema</span>
    </Button>
  )
}
EOL
echo "✅ Componente mode-toggle.tsx criado"

# Modificar o arquivo root.tsx
echo "Modificando root.tsx..."
if [ -f "app/root.tsx" ]; then
  # Fazer backup do arquivo original
  cp "app/root.tsx" "app/root.tsx.bak"
 fi 
  # Modificar o arquivo root.tsx
  cat > "app/root.tsx" << EOL
import type { LinksFunction, LoaderFunctionArgs } from "@remix-run/node";
import {
  Links,
  LiveReload,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useLoaderData,
} from "@remix-run/react";

import clsx from "clsx";
import {
  PreventFlashOnWrongTheme,
  ThemeProvider,
  useTheme,
} from "remix-themes";

import "./tailwind.css";
import { themeSessionResolver } from "./sessions.server";

// Return the theme from the session storage using the loader
export async function loader({ request }: LoaderFunctionArgs) {
  const { getTheme } = await themeSessionResolver(request);
  return {
    theme: getTheme(),
  };
}

export const links: LinksFunction = () => [
  { rel: "preconnect", href: "https://fonts.googleapis.com" },
  {
    rel: "preconnect",
    href: "https://fonts.gstatic.com",
    crossOrigin: "anonymous",
  },
  {
    rel: "stylesheet",
    href: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap",
  },
];

export function Layout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}

// Função principal da aplicação
export default function AppWithProviders() {
  const data = useLoaderData<typeof loader>();
  return (
    <ThemeProvider specifiedTheme={data.theme} themeAction="/action/set-theme">
      <App />
    </ThemeProvider>
  );
}

// Componente da aplicação
export function App() {
  const data = useLoaderData<typeof loader>();
  const [theme] = useTheme();
  
  return (
    <html lang="pt-BR" className={clsx(theme)}>
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <PreventFlashOnWrongTheme ssrTheme={Boolean(data.theme)} />
        <Links />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
        <LiveReload />
      </body>
    </html>
  );
}
EOL
  echo "✅ Arquivo root.tsx modificado (backup em root.tsx.bak)"



echo "✅ Ajustar o index.tsx"

cat > "app/routes/_index.tsx" << EOL
import type { MetaFunction } from "@remix-run/node";
import { ModeToggle } from "~/components/mode-toggle";

export const meta: MetaFunction = () => {
  return [
    { title: "New Remix App" },
    { name: "description", content: "Welcome to Remix!" },
  ];
};

export default function Index() {
  return (
    <div className="flex h-screen items-center justify-center">
      <ModeToggle />
    </div>
  );
}
EOL

echo "✅ Configuração do Dark Mode concluída!"

pnpm run dev

echo "===================================="
echo "Instalação concluída com sucesso!"
echo "Projeto $PROJETO configurado."
echo "===================================="
echo "Para iniciar o desenvolvimento:"
echo "cd $PROJETO"
echo "pnpm dev"