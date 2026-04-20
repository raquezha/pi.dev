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
            
            const header = theme.fg("accent", `pi v0.67.68`) + 
                           theme.fg("dim", ` | `) + 
                           theme.fg("success", `${dateStr} | ${timeStr}`) +
                           theme.fg("dim", ` | `) +
                           theme.fg("accent", `hello raquezha!`);

            // Get skills and extensions safely
            let skills = "none";
            let extensions = "none";
            try {
              const commands = pi.getCommands();
              if (commands && Array.isArray(commands)) {
                skills = commands
                  .filter(c => c && c.source === "skill")
                  .map(c => c.name.replace("skill:", "").replace("android-", ""))
                  .join(", ") || "none";
                
                extensions = commands
                  .filter(c => c && c.source === "extension")
                  .map(c => c.name)
                  .join(", ") || "none";
              }
            } catch (e) {
              skills = "loading...";
            }

            const safeWidth = Math.min(width, 100); 
            const separator = theme.fg("dim", "─".repeat(safeWidth));

            const rawLines = [
              "",
              header,
              separator,
              `${theme.fg("accent", "Skills ")} ${theme.fg("text", skills)}`,
              `${theme.fg("accent", "Exts   ")} ${theme.fg("text", extensions)}`,
              `${theme.fg("accent", "Help   ")} ${theme.fg("dim", "ctrl+c exit · / commands · ! bash · ctrl+o more")}`,
              separator,
              "",
            ];

            // Center each line individually
            return rawLines.map(line => {
              const truncated = truncateToWidth(line, width);
              const vWidth = visibleWidth(truncated);
              const padding = Math.floor(Math.max(0, width - vWidth) / 2);
              return " ".repeat(padding) + truncated;
            });
          },
          invalidate() {},
        };
      });
    }
  });
}
