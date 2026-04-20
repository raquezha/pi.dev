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
                           theme.fg("dim", ` - hello raquezha - today is `) + 
                           theme.fg("success", `${dateStr} | ${timeStr}`);

            // Get skills and extensions
            const commands = pi.getCommands();
            const skills = commands
              .filter(c => c.source === "skill")
              .map(c => c.name.replace("android-", ""))
              .join(", ");
            
            const extensions = pi.getCommands()
              .filter(c => c.source === "extension")
              .map(c => c.name)
              .join(", ");

            // Simple "table" format
            const lines = [
              "",
              header,
              theme.fg("dim", "─".repeat(width)),
              `${theme.fg("accent", "Skills     ")} ${theme.fg("text", skills || "none")}`,
              `${theme.fg("accent", "Extensions ")} ${theme.fg("text", extensions || "none")}`,
              `${theme.fg("accent", "Theme      ")} ${theme.fg("text", "Darcula")}`,
              theme.fg("dim", "─".repeat(width)),
              theme.fg("dim", "escape interrupt · ctrl+c/ctrl+d clear/exit · / commands · ! bash · ctrl+o more"),
              theme.fg("dim", "Press ctrl+o to show full startup help and loaded resources."),
              "",
              theme.fg("muted", "Pi can explain its own features and look up its docs. Ask it how to use or extend Pi."),
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
