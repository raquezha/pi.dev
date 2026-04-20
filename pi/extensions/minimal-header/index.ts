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

            // Define the core table lines
            const labelSkills = theme.fg("accent", "Skills ");
            const labelExts   = theme.fg("accent", "Exts   ");
            const labelHelp   = theme.fg("accent", "Help   ");
            const helpContent = theme.fg("dim", "ctrl+c exit · / commands · ! bash · ctrl+o more");

            const tableLines = [
              header,
              separator,
              `${labelSkills} ${theme.fg("text", skills)}`,
              `${labelExts}   ${theme.fg("text", extensions)}`,
              `${labelHelp}   ${helpContent}`,
              separator,
            ];

            // 1. Truncate lines to width first
            const truncatedLines = tableLines.map(l => truncateToWidth(l, width));

            // 2. Find the widest line in the block to determine block width
            const blockWidth = Math.max(...truncatedLines.map(l => visibleWidth(l)));

            // 3. Calculate left padding to center the entire block
            const leftPadding = " ".repeat(Math.floor(Math.max(0, width - blockWidth) / 2));

            // 4. Final assembly
            return ["", ...truncatedLines.map(l => leftPadding + l), ""];
          },
          invalidate() {},
        };
      });
    }
  });
}
