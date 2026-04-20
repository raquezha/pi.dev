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
            
            let header = "";
            try {
              const version = typeof VERSION !== 'undefined' ? VERSION : "0.67.68";
              const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
              const dateStr = now.toDateString();
              
              header = theme.fg("accent", `pi v${version}`) + 
                       theme.fg("dim", ` | `) + 
                       theme.fg("success", `${dateStr} | ${timeStr}`);
            } catch (e) {
              header = "pi v0.67.68";
            }

            // Get skills and extensions safely
            let skills = "none";
            let extensions = "none";
            try {
              const commands = pi.getCommands();
              if (commands && Array.isArray(commands)) {
                skills = commands
                  .filter(c => c && c.source === "skill")
                  .map(c => c.name.replace("android-", ""))
                  .join(", ") || "none";
                
                extensions = commands
                  .filter(c => c && c.source === "extension")
                  .map(c => c.name)
                  .join(", ") || "none";
              }
            } catch (e) {
              skills = "loading...";
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
          } catch (err) {
            return ["", "Header Error: " + (err as Error).message, ""];
          }
        },
          invalidate() {},
        };
      });
    }
  });
}
