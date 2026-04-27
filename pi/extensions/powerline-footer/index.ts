import { basename } from "node:path";
import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

type BgToken =
  | "selectedBg"
  | "userMessageBg"
  | "customMessageBg"
  | "toolPendingBg"
  | "toolSuccessBg"
  | "toolErrorBg";

type FgToken =
  | "text"
  | "accent"
  | "muted"
  | "dim"
  | "success"
  | "error"
  | "warning"
  | "border"
  | "borderAccent"
  | "borderMuted"
  | "userMessageText"
  | "customMessageText"
  | "customMessageLabel"
  | "toolTitle"
  | "toolOutput"
  | "toolDiffAdded"
  | "toolDiffRemoved"
  | "toolDiffContext"
  | "mdHeading"
  | "mdLink"
  | "mdLinkUrl"
  | "mdCode"
  | "mdCodeBlock"
  | "mdCodeBlockBorder"
  | "mdQuote"
  | "mdQuoteBorder"
  | "mdHr"
  | "mdListBullet"
  | "syntaxComment"
  | "syntaxKeyword"
  | "syntaxFunction"
  | "syntaxVariable"
  | "syntaxString"
  | "syntaxNumber"
  | "syntaxType"
  | "syntaxOperator"
  | "syntaxPunctuation"
  | "thinkingOff"
  | "thinkingMinimal"
  | "thinkingLow"
  | "thinkingMedium"
  | "thinkingHigh"
  | "thinkingXhigh"
  | "bashMode";

type Segment = {
  text: string;
  bg: BgToken;
  fg: FgToken;
};

const LEFT_CAP = "█";
const SEPARATOR = "";
const SPACE = " ";

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

function formatHeaderDate(date: Date): string {
  const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return `${weekdays[date.getDay()]} ${String(date.getDate()).padStart(2, "0")} ${months[date.getMonth()]}`;
}

function formatHeaderTime(date: Date): string {
  return `${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`;
}

function renderPowerline(theme: Theme, segments: Segment[]): string {
  let line = "";
  const firstSeg = segments[0];
  if (firstSeg) {
    line += theme.bg(firstSeg.bg, theme.fg("dim", LEFT_CAP));
  }

  for (let i = 0; i < segments.length; i++) {
    const seg = segments[i]!;
    const nextSeg = segments[i + 1];

    line += theme.bg(seg.bg, theme.fg(seg.fg, seg.text));

    if (nextSeg) {
      line += theme.bg(nextSeg.bg, theme.fg("dim", SEPARATOR));
    } else {
      line += theme.fg("dim", SEPARATOR);
    }
  }

  return line;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    // Restore built-in header (do not override)

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
              ? [{ text: `  ${branch} `, bg: "customMessageBg" as BgToken, fg: "mdHeading" as FgToken }]
              : []),
            { text: ` ↑${kFormat(totalInput)} `, bg: "userMessageBg", fg: "warning" },
            { text: ` ↓${kFormat(totalOutput)} `, bg: "selectedBg", fg: "syntaxType" },
            { text: ` $${formatCost(totalCost)} `, bg: "toolPendingBg", fg: "syntaxString" },
            { text: ` ◔ ${contextPercent}%/${mFormat(contextWindow)} `, bg: "toolSuccessBg", fg: "accent" },
            { text: ` ✦ ${modelText} `, bg: "toolErrorBg", fg: "text" },
          ];

          const left = renderPowerline(theme, segments);

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
