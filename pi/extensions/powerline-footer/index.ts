import { basename } from "node:path";
import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

// Dracula Palette
const DRACULA = {
  bg: "#282a36",
  fg: "#f8f8f2",
  selection: "#44475a",
  comment: "#6272a4",
  cyan: "#8be9fd",
  green: "#50fa7b",
  orange: "#ffb86c",
  pink: "#ff79c6",
  purple: "#bd93f9",
  red: "#ff5555",
  yellow: "#f1fa8c",
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
  if (Math.abs(num) < 1000) return `${Math.round(num)}`;
  return `${(num / 1000).toFixed(1)}k`;
}

function mFormat(num: number): string {
  if (!Number.isFinite(num) || num <= 0) return "0";
  if (num < 1_000_000) return `${Math.round(num / 1000)}k`;
  return `${(num / 1_000_000).toFixed(1)}M`;
}

function formatCost(cost: number): string {
  if (!Number.isFinite(cost) || cost <= 0) return "0.00";
  const twoDecimalValue = Number(cost.toFixed(2));
  if (twoDecimalValue === 0) return cost.toFixed(3);
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
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((tui, theme) => {
      const projectName = basename(ctx.cwd || process.cwd()) || "project";
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
          const segments: Segment[] = [
            { text: ` 󰌽 raquezha `, bg: DRACULA.pink, fg: DRACULA.bg },
            { text: ` π ${projectName} `, bg: DRACULA.green, fg: DRACULA.bg },
            { text: ` 󰥔 ${formatHeaderTime(now)} `, bg: DRACULA.purple, fg: DRACULA.bg },
            { text: ` 󰏘 ${themeName} `, bg: DRACULA.cyan, fg: DRACULA.bg },
          ];

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

          for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type !== "message" || entry.message.role !== "assistant") continue;
            totalInput += entry.message.usage?.input ?? 0;
            totalOutput += entry.message.usage?.output ?? 0;
            totalCost += entry.message.usage?.cost.total ?? 0;
          }

          const contextUsage = ctx.getContextUsage?.();
          const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const contextPercent =
            typeof contextUsage?.percent === "number" ? contextUsage.percent.toFixed(1) : "?";

          const branch = footerData.getGitBranch();
          const modelId = ctx.model?.id ?? "no-model";
          const thinkingLevel = pi.getThinkingLevel?.() ?? "off";
          const modelText = ctx.model?.reasoning
            ? `${modelId} • ${thinkingLevel}`
            : modelId;

          const segments: Segment[] = [
            ...(branch
              ? [{ text: `  ${branch} `, bg: DRACULA.pink, fg: DRACULA.bg }]
              : []),
            { text: ` ↑${kFormat(totalInput)} `, bg: DRACULA.green, fg: DRACULA.bg },
            { text: ` ↓${kFormat(totalOutput)} `, bg: DRACULA.purple, fg: DRACULA.bg },
            { text: ` $${formatCost(totalCost)} `, bg: DRACULA.orange, fg: DRACULA.bg },
            { text: ` ◔ ${contextPercent}% `, bg: DRACULA.yellow, fg: DRACULA.bg },
            { text: ` ✦ ${modelText} `, bg: DRACULA.cyan, fg: DRACULA.bg },
          ];

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
