import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { readFileSync, existsSync, readdirSync } from "fs";
import { join, sep } from "path";
import { homedir } from "os";

export default function (pi: ExtensionAPI) {
  let cachedFramework: string | null = null;
  let projectVersion: string | null = null;
  let projectName: string | null = null;
  let sessionCtx: ExtensionContext | null = null;
  let totalInput = 0;
  let totalOutput = 0;

  pi.on("message_end", (_event, _ctx) => {
    const msg = _event.message as Record<string, unknown>;
    const usage = msg?.usage as Record<string, unknown> | undefined;
    if (usage && typeof usage.input === "number" && typeof usage.output === "number") {
      totalInput += usage.input as number;
      totalOutput += usage.output as number;
    }
  });

  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) return;

    if (cachedFramework === null) {
      const detected = detectFramework(ctx.cwd);
      cachedFramework = detected.framework;
      projectVersion = detected.projectVersion;
    }
    if (projectName === null) {
      projectName = ctx.cwd.split("/").pop() || ctx.cwd.split("\\").pop() || null;
    }
    sessionCtx = ctx;
    const framework = cachedFramework;
    const logo = loadLogo();

    // ── Custom Header ──────────────────────────────────────────────
    ctx.ui.setHeader((_tui, theme) => ({
      render(width: number): string[] {
        if (!logo) return [""];
        return logo.map(l => truncateToWidth(theme.fg("accent", l), width));
      },
      invalidate() { },
    }));

    // ── Custom Footer (2 líneas) ───────────────────────────────────
    ctx.ui.setFooter((_tui, theme, footerData) => {
      return {
        invalidate() { },
        render(width: number): string[] {
          // ── LÍNEA 1: Versión + Framework + Runtime ────────────
          const versionParts: string[] = [];

          // Project name + version
          const pkgVersion = projectVersion || "";
          if (projectName && pkgVersion) {
            versionParts.push(theme.fg("muted", `${projectName} v${pkgVersion}`));
          } else if (projectName) {
            versionParts.push(theme.fg("muted", projectName));
          } else if (pkgVersion) {
            versionParts.push(theme.fg("muted", `v${pkgVersion}`));
          }

          // Git branch
          const branch = footerData.getGitBranch();
          if (branch) {
            versionParts.push(theme.fg("muted", `Branch: ${branch}`));
          }

          // Framework detectado (incluye su versión)
          if (framework) {
            versionParts.push(theme.fg("muted", framework));
          }

          const versionLine = versionParts.length > 0
            ? versionParts.join(` ${theme.fg("dim", "│")} `)
            : "";

          // ── LÍNEA 2: Info personalizada ───────────────────────
          const infoParts: { text: string; color: string }[] = [];

          // Modelo
          const modelId = sessionCtx?.model?.id;
          if (modelId) {
            infoParts.push({ text: modelId, color: "muted" });
          }

          // Tokens
          if (totalInput + totalOutput > 0) {
            infoParts.push({
              text: `↑${fmt(totalInput)} ↓${fmt(totalOutput)}`,
              color: "muted",
            });
          }

          // Contexto %
          const usage = sessionCtx?.getContextUsage();
          const pct = usage?.percent;
          if (pct != null) {
            const ctxColor = pct > 80 ? "error" : pct > 50 ? "warning" : "muted";
            infoParts.push({
              text: `${pct.toFixed(0)}% ctx`,
              color: ctxColor,
            });
          }

          const leftInfo = infoParts
            .map(p => theme.fg(p.color, p.text))
            .join(` ${theme.fg("dim", "|")} `);

          // ── Ensamblar (ambas líneas alineadas a la derecha) ────
          const lines: string[] = [];
          if (versionLine) {
            lines.push(padLeft(versionLine, width));
          }
          lines.push(padLeft(leftInfo, width));

          // Truncate each line to terminal width
          return lines.map(l => truncateToWidth(l, width));
        },
      };
    });
  });

  pi.registerCommand("builtin-header", {
    description: "Restore built-in header with keybinding hints",
    handler: async (_args, ctx) => {
      ctx.ui.setHeader(undefined);
      ctx.ui.setFooter(undefined);
      ctx.ui.notify("Built-in header restored", "info");
    },
  });
}

// ── Helpers ────────────────────────────────────────────────────────────

function loadLogo(): string[] | null {
  try {
    const p = join(homedir(), ".pi", "agent", "logo.txt");
    return readFileSync(p, "utf8").split("\n");
  } catch {
    return null;
  }
}

interface DetectionResult {
  framework: string;
  projectVersion: string | null;
}

function detectFramework(cwd: string): DetectionResult {
  let projectVersion: string | null = null;
  let framework = "";

  try {
    // ── Node.js ────────────────────────────────────────────────────
    if (existsSync(join(cwd, "package.json"))) {
      const pkg = JSON.parse(readFileSync(join(cwd, "package.json"), "utf-8"));
      projectVersion = pkg.version || null;

      const allDeps = { ...pkg.dependencies || {}, ...pkg.devDependencies || {} };
      const parts: string[] = [];

      const frameworks: [string, string][] = [
        ["next", "Next.js"],
        ["nuxt3", "Nuxt"], ["nuxt", "Nuxt"],
        ["@sveltejs/kit", "SvelteKit"], ["svelte", "Svelte"],
        ["@angular/core", "Angular"], ["angular", "Angular"],
        ["@remix-run/react", "Remix"], ["remix", "Remix"],
        ["@nestjs/core", "NestJS"], ["nestjs", "NestJS"],
        ["@solidjs/router", "SolidJS"], ["solid-js", "SolidJS"],
        ["react", "React"], ["preact", "Preact"],
        ["vue", "Vue"],
        ["astro", "Astro"],
        ["express", "Express"],
        ["fastify", "Fastify"],
        ["gatsby", "Gatsby"],
        ["electron", "Electron"],
        ["expo", "React Native"], ["react-native", "React Native"],
      ];

      for (const [pkgName, display] of frameworks) {
        const ver = allDeps[pkgName];
        if (ver) {
          const cleanVer = ver.replace(/^[~^>=<]+/, "");
          parts.push(`${display}${cleanVer && cleanVer !== "*" ? ` ${cleanVer}` : ""}`);
          break;
        }
      }

      // Node.js engine constraint (declarada en el proyecto, no del sistema)
      const nodeVer = pkg.engines?.node?.replace(/^[~^>=<]+/, "");
      if (nodeVer) {
        parts.push(`Node.js ${nodeVer}`);
      }

      framework = parts.join(" │ ");
      return { framework, projectVersion };
    }

    // ── Dart / Flutter ────────────────────────────────────────────
    if (existsSync(join(cwd, "pubspec.yaml"))) {
      const content = readFileSync(join(cwd, "pubspec.yaml"), "utf-8");
      projectVersion = content.match(/^version:\s*(.+)$/m)?.[1]?.trim() || null;

      // Extraer environment SDK y Flutter constraints
      const envSection = content.match(/environment:\s*\n([\s\S]*?)(?:^\w|\n\s*\n)/m)?.[1] || "";
      const dartVer = envSection.match(/sdk:\s*["']?([^"'\n]+)["']?\s*$/m)?.[1];
      const flutterVer = envSection.match(/flutter:\s*["']?([^"'\n]+)["']?\s*$/m)?.[1];

      const isFlutter = content.includes("flutter:");
      if (isFlutter) {
        const parts: string[] = [];
        if (flutterVer) {
          parts.push(`Flutter ${flutterVer}`);
        } else {
          parts.push("Flutter");
        }
        if (dartVer) parts.push(`Dart ${dartVer}`);
        framework = parts.join(" │ ");
      } else {
        framework = dartVer ? `Dart ${dartVer}` : "Dart";
      }
      return { framework, projectVersion };
    }

    // ── Rust ──────────────────────────────────────────────────────
    if (existsSync(join(cwd, "Cargo.toml"))) {
      const content = readFileSync(join(cwd, "Cargo.toml"), "utf-8");
      projectVersion = content.match(/^\[package\]\s*\n.*\n\s*version\s*=\s*"(.+?)"/m)?.[1] || null;
      const parts: string[] = [];

      const crates: [string, string][] = [
        ["axum", "Axum"], ["actix-web", "Actix Web"], ["rocket", "Rocket"],
        ["leptos", "Leptos"], ["yew", "Yew"], ["tauri", "Tauri"],
      ];

      for (const [crate, display] of crates) {
        if (content.includes(crate)) {
          const ver = content.match(new RegExp(`${crate}\\s*=\\s*"([^"]+)"`))?.[1];
          parts.push(`${display}${ver ? ` ${ver.replace(/^[~^>=<]+/, "")}` : ""}`);
          break;
        }
      }

      const edition = content.match(/edition\s*=\s*"(.+?)"/)?.[1];
      if (edition) parts.push(`Rust edition ${edition}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "Rust";
      return { framework, projectVersion };
    }

    // ── Go ────────────────────────────────────────────────────────
    if (existsSync(join(cwd, "go.mod"))) {
      const content = readFileSync(join(cwd, "go.mod"), "utf-8");
      projectVersion = null;
      const goVer = content.match(/^go\s+(\d+\.\d+(?:\.\d+)?)$/m)?.[1];
      framework = goVer ? `Go ${goVer}` : "Go";
      return { framework, projectVersion };
    }

    // ── Python (pyproject.toml) ───────────────────────────────────
    if (existsSync(join(cwd, "pyproject.toml"))) {
      const content = readFileSync(join(cwd, "pyproject.toml"), "utf-8");
      projectVersion = content.match(/^version\s*=\s*"(.+)"$/m)?.[1] || null;
      const parts: string[] = [];

      const pyFrameworks: [string, string, RegExp][] = [
        ["django", "Django", /django[\s"']*(?:>=|==|~=)\s*"?([^"\s,\n]+)/im],
        ["flask", "Flask", /flask[\s"']*(?:>=|==|~=)\s*"?([^"\s,\n]+)/im],
        ["fastapi", "FastAPI", /fastapi[\s"']*(?:>=|==|~=)\s*"?([^"\s,\n]+)/im],
      ];

      for (const [key, display, regex] of pyFrameworks) {
        if (content.toLowerCase().includes(key)) {
          const ver = content.match(regex)?.[1];
          parts.push(`${display}${ver ? ` ${ver.replace(/^[~^>=<]+/, "")}` : ""}`);
          break;
        }
      }

      const pyVer = content.match(/requires-python\s*=\s*"(.+?)"/)?.[1];
      if (pyVer) parts.push(`Python ${pyVer}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "Python";
      return { framework, projectVersion };
    }

    // ── Python (requirements.txt) ─────────────────────────────────
    if (existsSync(join(cwd, "requirements.txt"))) {
      const content = readFileSync(join(cwd, "requirements.txt"), "utf-8");
      const parts: string[] = [];
      projectVersion = null;

      const reqFrameworks: [string, string][] = [
        ["django", "Django"], ["flask", "Flask"], ["fastapi", "FastAPI"],
      ];

      for (const [key, display] of reqFrameworks) {
        const match = content.match(new RegExp(`^${key}[=~!<>]+\\s*([^\\s#]+)`, "im"));
        if (match) {
          parts.push(`${display} ${match[1]}`);
          break;
        } else if (content.toLowerCase().includes(key)) {
          parts.push(display);
          break;
        }
      }

      framework = parts.length > 0 ? parts.join(" │ ") : "Python";
      return { framework, projectVersion };
    }

    // ── PHP ───────────────────────────────────────────────────────
    if (existsSync(join(cwd, "composer.json"))) {
      const pkg = JSON.parse(readFileSync(join(cwd, "composer.json"), "utf-8"));
      projectVersion = null;
      const parts: string[] = [];
      const req = pkg.require || {};

      const phpFrameworks: [string, string][] = [
        ["laravel/framework", "Laravel"],
        ["symfony/framework-bundle", "Symfony"],
        ["cakephp/cakephp", "CakePHP"],
        ["codeigniter/framework", "CodeIgniter"],
      ];

      for (const [pkgName, display] of phpFrameworks) {
        if (req[pkgName]) {
          const ver = req[pkgName].replace(/^[~^><=]+/, "");
          parts.push(`${display} ${ver}`);
          break;
        }
      }

      const phpVer = req.php?.replace(/^[~^><=]+/, "");
      if (phpVer) parts.push(`PHP ${phpVer}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "PHP";
      return { framework, projectVersion };
    }

    // ── Ruby ──────────────────────────────────────────────────────
    if (existsSync(join(cwd, "Gemfile"))) {
      const content = readFileSync(join(cwd, "Gemfile"), "utf-8");
      const parts: string[] = [];
      projectVersion = null;

      const rubyFrameworks: [string, string][] = [["rails", "Rails"], ["sinatra", "Sinatra"]];

      for (const [gem, display] of rubyFrameworks) {
        const match = content.match(new RegExp(`^\\s*gem\\s+['"]${gem}['"]\\s*,\\s*['"]([^'"]+)['"]`, "m"));
        if (match) {
          parts.push(`${display} ${match[1].replace(/^[~^><= ]+/, "")}`);
          break;
        } else if (content.match(new RegExp(`^\\s*gem\\s+['"]${gem}['"]`, "m"))) {
          parts.push(display);
          break;
        }
      }

      const rubyVer = content.match(/^ruby\s+['"](.+?)['"]/m)?.[1];
      if (rubyVer) parts.push(`Ruby ${rubyVer}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "Ruby";
      return { framework, projectVersion };
    }

    // ── Java / Kotlin (Gradle) ────────────────────────────────────
    if (existsSync(join(cwd, "build.gradle")) || existsSync(join(cwd, "build.gradle.kts"))) {
      const f = existsSync(join(cwd, "build.gradle")) ? "build.gradle" : "build.gradle.kts";
      const content = readFileSync(join(cwd, f), "utf-8");
      const parts: string[] = [];
      projectVersion = null;

      if (content.includes("kotlin")) parts.push("Kotlin");

      const sbVer = content.match(/spring[\s_-]?boot\s+version\s*[=:]\s*['"](.+?)['"]/im)
        || content.match(/org\.springframework\.boot['"]?\s+version\s+['"](.+?)['"]/);

      if (sbVer?.[1]) {
        parts.push(`Spring Boot ${sbVer[1]}`);
      } else if (content.includes("spring")) {
        parts.push("Spring Boot");
      }

      if (content.includes("android")) {
        framework = parts.length > 0 ? `Android (${parts.join(" │ ")})` : "Android";
        return { framework, projectVersion };
      }
      parts.push("Gradle");
      framework = parts.join(" │ ");
      return { framework, projectVersion };
    }

    // ── Java (Maven) ──────────────────────────────────────────────
    if (existsSync(join(cwd, "pom.xml"))) {
      const content = readFileSync(join(cwd, "pom.xml"), "utf-8");
      const parts: string[] = [];
      projectVersion = content.match(/<version>\s*(.+?)\s*<\//)?.[1] || null;

      const sbVer = content.match(/<spring-boot[.\w-]*\.version>\s*(.+?)\s*<\//)?.[1]
        || content.match(/<parent>[\s\S]*?<groupId>org\.springframework\.boot[\s\S]*?<version>\s*(.+?)\s*<\//)?.[1];

      if (sbVer) {
        parts.push(`Spring Boot ${sbVer}`);
      } else if (content.includes("spring-boot")) {
        parts.push("Spring Boot");
      } else if (content.includes("quarkus")) {
        const qVer = content.match(/<quarkus\.version>\s*(.+?)\s*<\//)?.[1];
        parts.push(qVer ? `Quarkus ${qVer}` : "Quarkus");
      } else if (content.includes("micronaut")) {
        parts.push("Micronaut");
      }

      const javaVer = content.match(/<java\.version>\s*(.+?)\s*<\//)?.[1]
        || content.match(/<maven\.compiler\.(source|target)>\s*(.+?)\s*<\//)?.[2];
      if (javaVer) parts.push(`Java ${javaVer}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "Java";
      return { framework, projectVersion };
    }

    // ── Swift ─────────────────────────────────────────────────────
    if (existsSync(join(cwd, "Package.swift"))) {
      const content = readFileSync(join(cwd, "Package.swift"), "utf-8");
      const parts: string[] = [];
      projectVersion = null;

      if (content.includes("vapor")) {
        const ver = content.match(/\.upToNextMajor\s*\(from:\s*"([^"]+)"/)?.[1];
        parts.push(ver ? `Vapor ${ver}` : "Vapor");
      } else if (content.includes("swift-nio")) {
        parts.push("NIO");
      }

      const swiftVer = content.match(/\/\/\s*swift-tools-version:\s*(\d+\.\d+)/)?.[1];
      if (swiftVer) parts.push(`Swift ${swiftVer}`);
      framework = parts.length > 0 ? parts.join(" │ ") : "Swift";
      return { framework, projectVersion };
    }

    // ── .NET (C#) ─────────────────────────────────────────────────
    const csprojFiles = readdirSync(cwd).filter(f => f.endsWith(".csproj"));
    if (csprojFiles.length > 0) {
      const content = readFileSync(join(cwd, csprojFiles[0]), "utf-8");
      const parts: string[] = [];
      projectVersion = null;

      if (content.includes("Microsoft.AspNetCore")) {
        const ver = content.match(/Microsoft\.AspNetCore\.App\s+Version="([^"]+)"/)?.[1]
          || content.match(/Microsoft\.AspNetCore(?:\.[\w.]+)?\s+Version="([^"]+)"/)?.[1];
        parts.push(ver ? `ASP.NET Core ${ver}` : "ASP.NET Core");
      } else if (content.includes("Microsoft.Maui")) {
        parts.push(".NET MAUI");
      } else if (content.includes("Blazor")) {
        parts.push("Blazor");
      }

      const tf = content.match(/<TargetFramework>\s*(.+?)\s*<\//)?.[1];
      if (tf) parts.push(`.NET ${tf}`);
      framework = parts.length > 0 ? parts.join(" │ ") : ".NET";
      return { framework, projectVersion };
    }

    // ── Elixir ────────────────────────────────────────────────────
    if (existsSync(join(cwd, "mix.exs"))) {
      const content = readFileSync(join(cwd, "mix.exs"), "utf-8");
      const parts: string[] = [];
      projectVersion = content.match(/version:\s*"(.+?)"/)?.[1] || null;

      if (content.includes("phoenix")) {
        const ver = content.match(/:phoenix\s*,\s*['"]~>\s*([^'"]+)['"]/)?.[1];
        parts.push(ver ? `Phoenix ${ver}` : "Phoenix");
      }

      framework = parts.length > 0 ? parts.join(" │ ") : "Elixir";
      return { framework, projectVersion };
    }

    // ── Haskell ───────────────────────────────────────────────────
    if (existsSync(join(cwd, "stack.yaml"))) {
      const content = readFileSync(join(cwd, "stack.yaml"), "utf-8");
      projectVersion = null;
      const resolver = content.match(/resolver:\s*(.+?)\s*$/m)?.[1];
      framework = resolver ? `Haskell (${resolver})` : "Haskell";
      return { framework, projectVersion };
    }
    if (existsSync(join(cwd, "cabal.project"))) {
      framework = "Haskell";
      return { framework, projectVersion: null };
    }

    // ── Docker ────────────────────────────────────────────────────
    if (existsSync(join(cwd, "Dockerfile"))) {
      const content = readFileSync(join(cwd, "Dockerfile"), "utf-8");
      projectVersion = null;
      const from = content.match(/^FROM\s+(.+?)(?:\s+AS\s+\w+)?\s*$/im)?.[1];
      framework = from ? `Docker (${from})` : "Docker";
      return { framework, projectVersion };
    }

    return { framework: "", projectVersion: null };
  } catch {
    return { framework: "", projectVersion: null };
  }
}

function fmt(n: number): string {
  return n >= 1000 ? `${(n / 1000).toFixed(1)}k` : `${n}`;
}

/** Longitud visible de un string ANSI (sin los códigos de escape). */
function visibleWidth(str: string): number {
  return str.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, "").length;
}

/** Rellena con espacios a la izquierda para alinear a la derecha. */
function padLeft(str: string, width: number): string {
  const len = visibleWidth(str);
  if (len >= width) return str;
  return " ".repeat(width - len) + str;
}


