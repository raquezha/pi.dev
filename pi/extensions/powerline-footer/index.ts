import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const SEPARATOR = "";

      return {
        render(width: number): string[] {
          let totalInput = 0;
          let totalOutput = 0;
          let totalCost = 0;

          for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              totalInput += entry.message.usage.input;
              totalOutput += entry.message.usage.output;
              totalCost += entry.message.usage.cost.total;
            }
          }

          const contextUsage = ctx.getContextUsage?.();
          const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const contextPercent = contextUsage?.percent !== null ? contextUsage?.percent?.toFixed(1) : "?";

          const kFormat = (num: number) => (num / 1000).toFixed(1) + "k";
          const mFormat = (num: number) => (num / 1000000).toFixed(1) + "M";

          // Dracula-inspired segments
          // Note: Using theme keys that map to Dracula colors in your terminal
          const segments = [
            { text: ` ↑${kFormat(totalInput)} `, bg: "syntaxType", fg: "customMessageBg" },
            { text: ` ↓${kFormat(totalOutput)} `, bg: "accent", fg: "customMessageBg" },
            { text: ` $${totalCost.toFixed(3)} `, bg: "border", fg: "text" },
            { text: ` ${contextPercent}%/${mFormat(contextWindow)} `, bg: "success", fg: "customMessageBg" },
          ];

          let line = "";
          for (let i = 0; i < segments.length; i++) {
            const seg = segments[i];
            const nextSeg = segments[i + 1];

            // 1. Render the colored segment text
            line += theme.bg(seg.bg as any, theme.fg(seg.fg as any, seg.text));

            // 2. Render the chevron with perfectly matched background/foreground
            if (nextSeg) {
              // Foreground of chevron = Background of current segment
              // Background of chevron = Background of next segment
              line += theme.bg(nextSeg.bg as any, theme.fg(seg.bg as any, SEPARATOR));
            } else {
              // Final chevron fades into the default footer background
              line += theme.fg(seg.bg as any, SEPARATOR);
            }
          }

          return [line];
        },
        invalidate() {},
        dispose: () => {},
      };
    });
  });
}
