import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * custom-footer extension
 * 
 * Replaces the default technical footer with clean, colored badges.
 * Uses ( ) for a rounded look without needing special Nerd Fonts.
 */
export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      return {
        render(width: number): string[] {
          const stats = footerData.getStats();
          const branch = footerData.getGitBranch() || "main";
          const model = ctx.model?.id || "gemini";
          
          const kFormat = (num: number) => (num / 1000).toFixed(1) + "k";
          
          // Left side: Path and Branch
          const leftPart = theme.fg("accent", " ~/Developer/pi.dev ") + theme.fg("dim", `(${branch})`);

          // Badge Creator: ( text ) with background colors
          const makeBadge = (label: string, value: string, bgColor: string, fgColor: string) => {
            const open = theme.fg(bgColor, "(");
            const content = theme.bg(bgColor, theme.fg(fgColor, `${label}${value}`));
            const close = theme.fg(bgColor, ")");
            return `${open}${content}${close}`;
          };

          const inputBadge = makeBadge("↑", kFormat(stats.inputTokens), "userMessageBg", "accent");
          const outputBadge = makeBadge("↓", kFormat(stats.outputTokens), "toolSuccessBg", "toolTitle");
          const costBadge = makeBadge("$", stats.cost.toFixed(3), "customMessageBg", "warning");

          const badges = `${inputBadge} ${outputBadge} ${costBadge}`;
          const rightPart = theme.fg("dim", ` ${model} `);

          // Calculate space
          const rawLength = ` ~/Developer/pi.dev (${branch})  (↑00.0k) (↓0.0k) ($0.000)  ${model} `.length;
          const padding = " ".repeat(Math.max(0, width - rawLength));

          return [
            leftPart + padding + badges + rightPart
          ];
        },
        invalidate() {},
        dispose: footerData.onBranchChange(() => tui.requestRender()),
      };
    });
  });
}
