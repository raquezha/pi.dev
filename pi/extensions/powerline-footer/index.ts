import { basename } from "node:path";
import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

// Dracula VIBRANT Palette
const VIBRANT = {
  bg: "#282a36",
  cyan: "#8be9fd",
  green: "#50fa7b",
  orange: "#ffb86c",
  pink: "#ff79c6",
  purple: "#bd93f9",
  yellow: "#f1fa8c",
};

// Dracula PALE Palette (5% More Color)
const PALE = {
  bg: "#1e1f29",
  cyan: "#8da8a8",
  green: "#8da88d",
  orange: "#a8968d",
  pink: "#b896a4",
  purple: "#9b9bc0",
  yellow: "#b8b88d",
};

type Segment = {
  text: string;
  bg: string; // Hex
  fg: string; // Hex
};

const LEFT_CAP = "█";
const SEPARATOR = "";
const SPACE = " ";

function hexToRgb(hex: string) {
  const cleaned = hex.replace("#", "");
  const r = parseInt(cleaned.substring(0, 2), 16);
  const g = parseInt(cleaned.substring(2, 4), 16);
  const b = parseInt(cleaned.substring(4, 6), 16);
  return { r, g, b };
}

function toAnsiBg(hex: string): string {
  const { r, g, b } = hexToRgb(hex);
  return `\x1b[48;2;${r};${g};${b}m`;
}

function toAnsiFg(hex: string): string {
  const { r, g, b } = hexToRgb(hex);
  return `\x1b[38;2;${r};${g};${b}m`;
}

const ANSI_RESET_BG = "\x1b[49m";
const ANSI_RESET_FG = "\x1b[39m";

function kFormat(num: number): string {
  if (!Number.isFinite(num)) return "0";
  const abs = Math.abs(num);
  if (abs < 1000) return `${Math.round(num)}`;
  if (abs < 1000000) return `${(num / 1000).toFixed(1)}k`;
  if (abs < 1000000000) return `${(num / 1000000).toFixed(1)}M`;
  if (abs < 1000000000000) return `${(num / 1000000000).toFixed(1)}B`;
  return `${(num / 1000000000000).toFixed(1)}T`;
}

function formatCost(cost: number): string {
  if (!Number.isFinite(cost) || cost <= 0) return "0.00";
  return cost.toFixed(2);
}

function formatHeaderTime(date: Date): string {
  return `${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`;
}

function renderPowerline(segments: Segment[]): string {
  let line = "";
  const firstSeg = segments[0];
  if (firstSeg) {
    line += toAnsiFg(firstSeg.bg) + toAnsiBg(firstSeg.bg) + LEFT_CAP;
  }

  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i]!;
    const nextSeg = segments[i + 1];
    line += toAnsiBg(seg.bg) + toAnsiFg(seg.fg) + seg.text;
    if (nextSeg) {
      line += toAnsiBg(nextSeg.bg) + toAnsiFg(seg.bg) + SEPARATOR;
    } else {
      line += ANSI_RESET_BG + toAnsiFg(seg.bg) + SEPARATOR + ANSI_RESET_FG;
    }
  }
  return line;
}

export default function (pi: ExtensionAPI) {
  // Command to cycle theme
  pi.registerCommand("cycle-theme", {
    description: "Cycle between vibrant and pale Dracula themes",
    handler: async (_args, ctx) => {
      const current = ctx.ui.theme.name;
      const next = current === "dracula-vibrant" ? "ghostly-pale" : "dracula-vibrant";
      
      const result = ctx.ui.setTheme(next);
      if (result.success) {
        ctx.ui.notify(`Switched: ${current} → ${next}`, "info");
      } else {
        ctx.ui.notify(`Error switching to ${next}: ${result.error}`, "error");
      }
    },
  });

  pi.on("session_start", async (event, ctx) => {
    if (!ctx.hasUI) return;

    const projectName = basename(ctx.cwd || process.cwd()) || "pi.dev";
    
    // Set terminal title
    ctx.ui.setTitle(`π ${projectName}`);

    ctx.ui.setHeader((tui, theme) => {
      let timeout: ReturnType<typeof setTimeout> | undefined;
      let interval: ReturnType<typeof setInterval> | undefined;

      const scheduleClock = () => {
        const now = new Date();
        const delay = (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
        timeout = setTimeout(() => {
          tui.requestRender();
          interval = setInterval(() => tui.requestRender(), 60_000);
        }, Math.max(1, delay));
      };

      scheduleClock();

      return {
        dispose() {
          if (timeout) clearTimeout(timeout);
          if (interval) clearInterval(interval);
        },
        invalidate() {},
        render(width: number): string[] {
          const now = new Date();
          const themeName = (theme.name || "theme").toLowerCase();
          const p = themeName === "ghostly-pale" ? PALE : VIBRANT;
          
          // Keep title in sync with theme
          ctx.ui.setTitle(`π ${projectName} • ${themeName}`);

          const segments: Segment[] = [
            { text: ` 󰌽 raquezha `, bg: p.pink, fg: p.bg },
            { text: ` π ${projectName} `, bg: p.green, fg: p.bg },
          ];

          // Add mindset if active
          const mindset = process.env.PI_MINDSET || (pi as any).getMindset?.() || (pi as any).getMindsetName?.();
          if (mindset) {
            segments.push({ text: ` 🎩 ${mindset} `, bg: p.orange, fg: p.bg });
          }

          segments.push(
            { text: ` 󰥔 ${formatHeaderTime(now)} `, bg: p.purple, fg: p.bg },
            { text: ` 󰏘 ${themeName} `, bg: p.cyan, fg: p.bg },
          );

          return [truncateToWidth(renderPowerline(segments), width, "")];
        },
      };
    });

    ctx.ui.setFooter((tui, theme, footerData) => {
      const dispose = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose,
        invalidate() {},
        render(width: number): string[] {
          let totalInput = 0;
          let totalOutput = 0;
          let totalCost = 0;
          let totalCacheRead = 0;

          for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type !== "message" || entry.message.role !== "assistant") continue;
            const usage = entry.message.usage;
            if (usage) {
              totalInput += usage.input;
              totalOutput += usage.output;
              totalCost += usage.cost.total;
              totalCacheRead += (usage as any).cacheRead ?? 0;
            }
          }

          const contextUsage = ctx.getContextUsage?.();
          const contextPercent =
            typeof contextUsage?.percent === "number" ? Math.round(contextUsage.percent) : "?";
          
          const cachePercent = (totalInput + totalCacheRead) > 0 
            ? Math.round((totalCacheRead / (totalInput + totalCacheRead)) * 100) 
            : 0;

          const branch = footerData.getGitBranch();
          const modelId = ctx.model?.id ?? "no-model";
          const thinkingLevel = pi.getThinkingLevel?.() ?? "off";
          const modelText = ctx.model?.reasoning ? `${modelId} • ${thinkingLevel}` : modelId;

          const themeName = (theme.name || "theme").toLowerCase();
          const p = themeName === "ghostly-pale" ? PALE : VIBRANT;

          const segments: Segment[] = [
            ...(branch ? [{ text: `  ${branch} `, bg: p.pink, fg: p.bg }] : []),
            { text: ` 󰁝 ${kFormat(totalInput)} `, bg: p.green, fg: p.bg },
            { text: ` 󰁅 ${kFormat(totalOutput)} `, bg: p.purple, fg: p.bg },
            { text: ` 󰌪 ${kFormat(totalCacheRead)} `, bg: p.yellow, fg: p.bg },
            { text: ` 󱍢 $${formatCost(totalCost)} `, bg: p.orange, fg: p.bg },
            { text: ` 󰆼 ${contextPercent}% `, bg: p.cyan, fg: p.bg },
            { text: ` 󱐋 ${modelId} `, bg: p.purple, fg: p.bg },
          ];

          // Add mindset if active
          const mindset = process.env.PI_MINDSET || (pi as any).getMindset?.() || (pi as any).getMindsetName?.();
          if (mindset) {
            segments.push({ text: ` 🎩 ${mindset} `, bg: p.pink, fg: p.bg });
          }


          const left = renderPowerline(segments);

          const statuses = Array.from(footerData.getExtensionStatuses().values())
            .filter((value): value is string => Boolean(value))
            .join(" ");
          const rightText = statuses;
          if (!rightText) {
            return [truncateToWidth(left, width, "")];
          }

          const right = theme.fg("dim", rightText);
          const availableLeftWidth = Math.max(0, width - visibleWidth(right) - 1);
          const safeLeft = truncateToWidth(left, availableLeftWidth, "");
          const padWidth = Math.max(1, width - visibleWidth(safeLeft) - visibleWidth(right));
          const pad = SPACE.repeat(padWidth);
          return [truncateToWidth(safeLeft + pad + right, width)];
        },
      };
    });
  });
}
