import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type CapabilityState = {
  cwd: string;
  repoType: "javascript-typescript" | "generic";
  codeIntelligenceInstalled: boolean;
  codeIntelligenceSource?: string;
  subagentsInstalled: boolean;
  subagentsSource?: string;
  repoCodeIntelligenceConfigured: boolean;
  contextModeConfigured: boolean;
  contextModeConfigPath?: string;
};

type PromptMode = "general" | "structural" | "debug-heavy" | "review";

type RouterState = {
  lastPromptMode: PromptMode;
  lastPrompt?: string;
};

const ROUTER_STATUS_PARAMS = Type.Object({});

export default function aiRouterExtension(pi: ExtensionAPI) {
  let capabilities: CapabilityState = createCapabilityState(process.cwd());
  const routerState: RouterState = {
    lastPromptMode: "general",
  };

  async function refreshCapabilities(cwd: string): Promise<CapabilityState> {
    const contextModeConfig = detectContextModeConfig(cwd);
    const codeIntelligence = detectInstalledPiPackage(cwd, "@catdaemon/pi-code-intelligence");
    const subagents = detectInstalledPiPackage(cwd, "pi-subagents");

    capabilities = {
      cwd,
      repoType: detectRepoType(cwd),
      codeIntelligenceInstalled: codeIntelligence.installed,
      codeIntelligenceSource: codeIntelligence.source,
      subagentsInstalled: subagents.installed,
      subagentsSource: subagents.source,
      repoCodeIntelligenceConfigured: hasRepoCodeIntelligenceConfig(cwd),
      contextModeConfigured: Boolean(contextModeConfig),
      contextModeConfigPath: contextModeConfig ?? undefined,
    };

    return capabilities;
  }

  function setStatus(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;

    const parts: string[] = [];
    parts.push(capabilities.repoType === "javascript-typescript" ? "js/ts repo" : "generic repo");
    parts.push(capabilities.codeIntelligenceInstalled ? "code-intelligence ready" : "code-intelligence missing");
    parts.push(capabilities.subagentsInstalled ? "subagents ready" : "subagents missing");
    parts.push(capabilities.contextModeConfigured ? "context-mode ready" : "context-mode missing");
    parts.push(`mode:${routerState.lastPromptMode}`);
    ctx.ui.setStatus("ai-router", parts.join(" · "));
  }

  function formatRouterStatus(): string {
    const lines = [
      `Repository type: ${capabilities.repoType}`,
      `Prompt mode: ${routerState.lastPromptMode}`,
      `Code intelligence package: ${capabilities.codeIntelligenceInstalled ? "installed" : "missing"}`,
      `Code intelligence source: ${capabilities.codeIntelligenceSource ?? "not detected"}`,
      `Subagents package: ${capabilities.subagentsInstalled ? "installed" : "missing"}`,
      `Subagents source: ${capabilities.subagentsSource ?? "not detected"}`,
      `Repo-local code intelligence config: ${capabilities.repoCodeIntelligenceConfigured ? "present" : "absent"}`,
      `context-mode MCP: ${capabilities.contextModeConfigured ? `configured (${capabilities.contextModeConfigPath})` : "not configured"}`,
      `Routing policy: ${describeRoutingPolicy()}`,
    ];

    return lines.join("\n");
  }

  function describeRoutingPolicy(): string {
    if (routerState.lastPromptMode === "structural") {
      return capabilities.codeIntelligenceInstalled
        ? "Prefer code-intelligence search/impact before broad repo exploration"
        : "Use focused built-in tools; code-intelligence is not installed";
    }

    if (routerState.lastPromptMode === "debug-heavy") {
      return capabilities.contextModeConfigured
        ? "Prefer context-mode for large outputs/logs, then inspect targeted files"
        : "Use focused commands; context-mode is not configured";
    }

    if (routerState.lastPromptMode === "review") {
      return capabilities.codeIntelligenceInstalled
        ? "Prefer code-intelligence review and impact analysis, then read targeted files"
        : "Use focused reads and built-in tools for review";
    }

    return "Use built-in tools normally; prefer code-intelligence/context-mode when clearly beneficial";
  }

  pi.on("session_start", async (_event, ctx) => {
    routerState.lastPromptMode = "general";
    routerState.lastPrompt = undefined;
    await refreshCapabilities(ctx.cwd);
    setStatus(ctx);
    if (ctx.hasUI) {
      ctx.ui.setStatus("ai-router-output", undefined);
    }
  });

  pi.on("before_agent_start", async (event, ctx) => {
    await refreshCapabilities(ctx.cwd);

    const promptText = typeof event.prompt === "string" ? event.prompt : "";
    routerState.lastPrompt = promptText;
    routerState.lastPromptMode = classifyPrompt(promptText);
    setStatus(ctx);

    const parts: string[] = [];
    parts.push("## Hybrid Routing");
    parts.push(`- Repository type: ${capabilities.repoType}.`);
    parts.push(`- Detected prompt mode: ${routerState.lastPromptMode}.`);
    parts.push(`- code-intelligence package installed: ${capabilities.codeIntelligenceInstalled ? "yes" : "no"}.`);
    parts.push(`- pi-subagents package installed: ${capabilities.subagentsInstalled ? "yes" : "no"}.`);
    parts.push(`- Repo-local code-intelligence config present: ${capabilities.repoCodeIntelligenceConfigured ? "yes" : "no"}.`);
    parts.push(`- context-mode MCP configured: ${capabilities.contextModeConfigured ? "yes" : "no"}.`);
    parts.push("");
    parts.push("Routing rules:");

    if (capabilities.codeIntelligenceInstalled) {
      parts.push(
        "- For architecture, related files, existing patterns, impacted callers/tests, or broad repo discovery, prefer `code_intelligence_search`, `code_intelligence_impact`, or `code_intelligence_analyze_changes` before wide `bash` or `read` exploration.",
      );
      parts.push(
        "- If code intelligence is not active in this repo yet, use `/code-intelligence-doctor` and then `/enable-code-intelligence` once inside Pi.",
      );
      if (routerState.lastPromptMode === "review") {
        parts.push("- For review tasks, prefer `/code-intelligence-review` before manual broad inspection.");
      }
    } else {
      parts.push(
        "- code-intelligence is not installed. Use focused built-in tools and reinstall EURECATagent if you want local code graph and impact analysis.",
      );
    }

    if (routerState.lastPromptMode === "debug-heavy" && capabilities.contextModeConfigured) {
      parts.push(
        "- This prompt may produce large output. Prefer the `mcp` tool to discover `ctx_` tools from `context-mode` before dumping long logs or test output into the conversation.",
      );
    }

    if (capabilities.contextModeConfigured) {
      parts.push(
        "- When a task may produce large logs, snapshots, wide searches, or heavy intermediate output, prefer the `mcp` tool to search for `ctx_` tools from the `context-mode` server.",
      );
    }

    if (capabilities.subagentsInstalled) {
      for (const suggestion of getSubagentSuggestions(promptText, routerState.lastPromptMode)) {
        parts.push(suggestion);
      }
    }

    parts.push("- Once you know the relevant files, switch to the built-in `read`, `edit`, `write`, and focused `bash` commands.");
    parts.push("- Keep responses concise and avoid reading many unrelated files when code-intelligence can narrow the search first.");

    return {
      systemPrompt: `${event.systemPrompt}\n\n${parts.join("\n")}`,
    };
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    await refreshCapabilities(ctx.cwd);
    const command = typeof event.input.command === "string" ? event.input.command : "";
    if (!command) return undefined;

    if (ctx.hasUI) {
      if (shouldWarnAboutBroadStructuralSearch(command, capabilities, routerState)) {
        ctx.ui.notify("Prefer code_intelligence_search or code_intelligence_impact before broad structural searches.", "warning");
      }

      if (shouldWarnAboutLargeOutput(command, capabilities)) {
        ctx.ui.setStatus("ai-router-output", "Prefer context-mode for large output/log-heavy commands");
      } else {
        ctx.ui.setStatus("ai-router-output", undefined);
      }
    }

    return undefined;
  });

  pi.registerCommand("router-status", {
    description: "Show hybrid routing status for code-intelligence, subagents, and context-mode",
    handler: async (_args, ctx) => {
      await refreshCapabilities(ctx.cwd);
      setStatus(ctx);
      if (ctx.hasUI) {
        ctx.ui.notify(formatRouterStatus(), "info");
      }
    },
  });

  pi.registerCommand("router-refresh", {
    description: "Refresh hybrid routing capability detection",
    handler: async (_args, ctx) => {
      await refreshCapabilities(ctx.cwd);
      setStatus(ctx);
      if (ctx.hasUI) {
        ctx.ui.notify("Hybrid routing capabilities refreshed", "info");
      }
    },
  });

  pi.registerTool({
    name: "router_status",
    label: "Router Status",
    description: "Inspect code-intelligence, subagents, and context-mode readiness for the current repository.",
    promptSnippet: "Check whether code-intelligence, subagents, and context-mode are ready before a repository exploration task.",
    promptGuidelines: [
      "Use router_status at the start of a structural or review task when you need to know whether code-intelligence, subagents, and context-mode are available.",
    ],
    parameters: ROUTER_STATUS_PARAMS,
    async execute() {
      await refreshCapabilities(capabilities.cwd);
      return {
        content: [{ type: "text", text: formatRouterStatus() }],
        details: {
          ...capabilities,
          ...routerState,
          routingPolicy: describeRoutingPolicy(),
        },
      };
    },
  });
}

function createCapabilityState(cwd: string): CapabilityState {
  return {
    cwd,
    repoType: "generic",
    codeIntelligenceInstalled: false,
    codeIntelligenceSource: undefined,
    subagentsInstalled: false,
    subagentsSource: undefined,
    repoCodeIntelligenceConfigured: false,
    contextModeConfigured: false,
    contextModeConfigPath: undefined,
  };
}

function detectRepoType(cwd: string): CapabilityState["repoType"] {
  const markers = [
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    "pnpm-workspace.yaml",
    "bun.lockb",
    "bun.lock",
  ];

  return markers.some((marker) => existsSync(join(cwd, marker))) ? "javascript-typescript" : "generic";
}

function hasRepoCodeIntelligenceConfig(cwd: string): boolean {
  return existsSync(join(cwd, ".pi-code-intelligence.json")) || existsSync(join(cwd, ".pi", "code-intelligence.json"));
}

function detectInstalledPiPackage(cwd: string, packageName: string): { installed: boolean; source: string | null } {
  const candidates = [
    join(cwd, ".pi", "settings.json"),
    join(homedir(), ".pi", "agent", "settings.json"),
  ];

  for (const candidate of candidates) {
    try {
      if (!existsSync(candidate)) continue;
      const content = readFileSync(candidate, "utf8");
      const parsed = JSON.parse(content) as {
        packages?: Array<string | { source?: string }>;
      };
      const packages = parsed.packages ?? [];
      for (const entry of packages) {
        const source = typeof entry === "string" ? entry : entry?.source;
        if (!source) continue;
        if (source.includes(packageName)) {
          return { installed: true, source };
        }
      }
    } catch {
      // ignore invalid settings
    }
  }

  return { installed: false, source: null };
}

function detectContextModeConfig(cwd: string): string | null {
  const candidates = [
    join(cwd, ".pi", "mcp.json"),
    join(cwd, ".mcp.json"),
    join(homedir(), ".pi", "agent", "mcp.json"),
    join(homedir(), ".config", "mcp", "mcp.json"),
  ];

  for (const candidate of candidates) {
    try {
      if (!existsSync(candidate)) continue;
      const content = readFileSync(candidate, "utf8");
      const parsed = JSON.parse(content) as {
        mcpServers?: Record<string, unknown>;
      };
      if (parsed.mcpServers && "context-mode" in parsed.mcpServers) {
        return candidate;
      }
    } catch {
      // ignore unreadable or invalid files
    }
  }

  return null;
}

function classifyPrompt(prompt: string): PromptMode {
  const normalized = prompt.toLowerCase();

  if (/(where|dónde|which files|qué archivos|who calls|quién usa|flow|flujo|navigate|naviga|symbol|símbolo|architecture|arquitectura|entry point|entrypoint|impact|related files|callers|tests? affected)/.test(normalized)) {
    return "structural";
  }

  if (/(log|trace|stacktrace|test output|snapshot|stderr|stdout|failing tests|integration test|e2e|crash|crashlytics)/.test(normalized)) {
    return "debug-heavy";
  }

  if (/(review|revisa|audit|audita|security|seguridad|quality|calidad|pull request|pr\b)/.test(normalized)) {
    return "review";
  }

  return "general";
}

function getSubagentSuggestions(prompt: string, mode: PromptMode): string[] {
  const normalized = prompt.toLowerCase();
  const suggestions: string[] = [];

  if (mode === "structural") {
    suggestions.push(
      "- If the task spans multiple files or the codebase area is unclear, consider `/run-chain generic-discovery -- <task>` or ask for `generic-discovery` to build reusable context before editing.",
    );
  }

  if (mode === "review") {
    suggestions.push(
      "- For a deeper delegated review, consider `generic-reviewer`, `generic-parallel-review`, or a reviewer fanout when the diff is large or risky.",
    );
  }

  if (/(implement|implementation|implementar|refactor|refactorizar|fix|arregla|bug|feature|change|cambio|modify|modificar|update|actualizar|build|crear)/.test(normalized)) {
    suggestions.push(
      "- For approved multi-step implementation work, consider `/run-chain generic-implement-safe -- <task>` to scout, plan, implement, and review with a single writer.",
    );
  }

  if (/(research|investiga|documentation|documentación|docs|compare|comparar|library|librer|framework|best practice|patrón|approach|enfoque)/.test(normalized)) {
    suggestions.push(
      "- When you need external references plus local code context, consider `/run-chain generic-research-and-plan -- <task>`.",
    );
  }

  return Array.from(new Set(suggestions));
}

function shouldWarnAboutBroadStructuralSearch(command: string, capabilities: CapabilityState, state: RouterState): boolean {
  if (!capabilities.codeIntelligenceInstalled) {
    return false;
  }

  if (state.lastPromptMode !== "structural" && state.lastPromptMode !== "review") {
    return false;
  }

  const normalized = command.toLowerCase();
  const usesBroadSearch = /\b(rg|grep|find)\b/.test(normalized);
  if (!usesBroadSearch) {
    return false;
  }

  return /(architecture|route|screen|repository|service|controller|component|hook|schema|caller|impact|references?|usage|feature|test)/.test(normalized);
}

function shouldWarnAboutLargeOutput(command: string, capabilities: CapabilityState): boolean {
  if (!capabilities.contextModeConfigured) {
    return false;
  }

  const normalized = command.toLowerCase();
  return /(npm test|pnpm test|yarn test|bun test|pytest|go test|cargo test|mvn test|gradle test|xcodebuild|flutter test|jest|vitest|playwright|cypress|tail -f|cat .*log|rg .* -n|grep .* -r)/.test(normalized);
}
