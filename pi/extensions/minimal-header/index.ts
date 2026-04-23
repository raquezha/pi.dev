import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.setHeader((_tui, theme) => {
        return {
          render(width: number): string[] {
            const now = new Date();
            const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
            const dateStr = now.toDateString();
            
            // 1. Branding: π v0.67.68 · Mon Apr 20 2026 · 14:30:05
            const branding = theme.fg("accent", theme.bold(" π ")) + 
                             theme.fg("text", `v0.67.68`) + 
                             theme.fg("dim", ` · ${dateStr} · ${timeStr}`);

            // 2. Get resources safely
            let skills = "none";
            let extensions = "none";
            try {
              const commands = pi.getCommands();
              if (commands && Array.isArray(commands)) {
                skills = commands
                  .filter(c => c && c.source === "skill")
                  .map(c => c.name.replace("skill:", "").replace("android-", ""))
                  .join(theme.fg("dim", " · ")) || "none";
                
                extensions = commands
                  .filter(c => c && c.source === "extension")
                  .map(c => c.name)
                  .join(theme.fg("dim", " · ")) || "none";
              }
            } catch (e) {
              skills = "loading...";
            }

            // 3. Define the data block (include session context)
            let contextInfo = "none";
            try {
              const sessionFile = ctx?.sessionManager?.getSessionFile?.();
              const cwd = ctx?.cwd;
              if (sessionFile) {
                contextInfo = sessionFile;
              } else if (cwd) {
                contextInfo = cwd;
              }
            } catch (e) {
              contextInfo = "loading...";
            }

            const rows = [
              ["Context", theme.fg("dim", contextInfo)],
              ["Skills", skills],
              ["Exts", extensions],
              ["Help", theme.fg("dim", "/cmds · !bash · ctrl+c exit · ctrl+o more")]
            ];

            const maxLabelWidth = Math.max(...rows.map(r => r[0].length));
            const separator = theme.fg("dim", "─".repeat(width));

            const tableLines = [
              branding,
              separator,
              ...rows.map(([label, content]) => {
                const paddedLabel = theme.fg("accent", label.padEnd(maxLabelWidth + 2));
                return paddedLabel + content;
              }),
              separator,
            ];

            // Left-aligned with 3-space margin
            const indent = "   ";
            return ["", ...tableLines.map(l => indent + truncateToWidth(l, width - 3)), ""];
          },
          invalidate() {},
        };
      });
    }
  });
}
