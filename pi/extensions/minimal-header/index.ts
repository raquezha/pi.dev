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

            // Define the rows as [label, content, color]
            const rows = [
              ["Skills", skills, "text"],
              ["Exts", extensions, "text"],
              ["Help", "ctrl+c exit · / commands · ! bash · ctrl+o more", "dim"]
            ];

            // 1. Calculate the maximum label width
            const maxLabelWidth = Math.max(...rows.map(r => r[0].length));

            // 2. Construct the table lines with dynamic padding
            const tableLines = [
              header,
              separator,
              ...rows.map(([label, content, color]) => {
                const paddedLabel = theme.fg("accent", label.padEnd(maxLabelWidth + 2));
                const styledContent = theme.fg(color as any, content);
                return paddedLabel + styledContent;
              }),
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
