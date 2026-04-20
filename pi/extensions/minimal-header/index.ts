import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { VERSION } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.setHeader((_tui, theme) => {
        return {
          render(width: number): string[] {
            const now = new Date();
            const dateStr = now.toLocaleDateString("en-US", {
              weekday: "short",
              month: "short",
              day: "2-digit",
              year: "numeric",
            });
            const timeStr = now.toTimeString().split(" ")[0] + ":" + now.getMilliseconds().toString().slice(0, 1);
            
            const header = theme.fg("accent", `pi v${VERSION}`) + 
                           theme.fg("dim", ` | `) + 
                           theme.fg("success", `${dateStr} | ${timeStr}`);

            // Get skills and extensions safely
            let skills = "none";
            let extensions = "none";
            try {
              const commands = pi.getCommands() || [];
              skills = commands
                .filter(c => c && c.source === "skill")
                .map(c => c.name.replace("android-", ""))
                .join(", ") || "none";
              
              extensions = commands
                .filter(c => c && c.source === "extension")
                .map(c => c.name)
                .join(", ") || "none";
            } catch (e) {
              // Silently handle discovery lag
            }

            const safeWidth = Math.max(0, width);
            const separator = theme.fg("dim", "─".repeat(safeWidth));

            const lines = [
              "",
              header,
              separator,
              `${theme.fg("accent", "Skills ")} ${theme.fg("text", skills)}`,
              `${theme.fg("accent", "Exts   ")} ${theme.fg("text", extensions)}`,
              `${theme.fg("accent", "Help   ")} ${theme.fg("dim", "ctrl+c exit · / commands · ! bash · ctrl+o more")}`,
              separator,
              "",
            ];

            return lines;
          },
          invalidate() {},
        };
      });
    }
  });
}
