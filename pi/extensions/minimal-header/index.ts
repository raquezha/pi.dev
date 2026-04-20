import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.setHeader((_tui, _theme) => {
        return {
          render(width: number): string[] {
            const separator = "-".repeat(Math.max(0, width));
            return [
              "",
              "pi v0.67.68 | documentation mode",
              separator,
              "Skills: loading...",
              "Exts:   loading...",
              "Help:   ctrl+c exit | / commands | ! bash",
              separator,
              "",
            ];
          },
          invalidate() {},
        };
      });
    }
  });
}
