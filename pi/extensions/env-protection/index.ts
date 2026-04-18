import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import * as path from "node:path";
import * as os from "node:os";

/**
 * env-protection extension
 *
 * Blocks pi (and any LLM) from reading, writing, grepping, or listing
 * sensitive files: .env, private keys, credentials, and the ~/.pi-secrets
 * directory. Protects against accidental secret exposure to AI models.
 *
 * Safe operations like `source ~/.pi-secrets/.env` in setup scripts
 * are unaffected — they run outside pi.
 */
export default function (pi: ExtensionAPI) {
  // ── File-name patterns (matched against basename + full path) ──────
  const blockedFilePatterns = [
    ".env",
    ".env.",
    "credentials",
    ".pem",
    ".key",
    "id_rsa",
    "id_ed25519",
    "id_ecdsa",
    "id_dsa",
    ".p12",
    ".pfx",
    ".keystore",
    ".jks",
    "auth.json",
  ];

  // ── Directory patterns (always blocked regardless of file name) ────
  const blockedDirPatterns = [
    ".secrets",
    ".pi-secrets",
    ".ssh",
  ];

  // ── Resolved absolute paths that are always blocked ────────────────
  const blockedAbsolutePaths = [
    path.join(os.homedir(), ".pi-secrets"),
    path.join(os.homedir(), ".ssh"),
    path.join(os.homedir(), ".pi", "agent", "auth.json"),
  ];

  // ── Helpers ────────────────────────────────────────────────────────

  function checkPath(filePath: string): string | undefined {
    if (!filePath) return undefined;

    const resolved = path.resolve(filePath);
    const lower = resolved.toLowerCase();
    const basename = path.basename(filePath).toLowerCase();

    // Check absolute blocked paths
    for (const bp of blockedAbsolutePaths) {
      if (resolved.startsWith(bp) || resolved === bp) {
        return `path is under protected location "${bp}"`;
      }
    }

    // Check directory patterns anywhere in the path
    for (const dp of blockedDirPatterns) {
      if (lower.includes(`/${dp}/`) || lower.includes(`/${dp}`) || lower.endsWith(`/${dp}`)) {
        return `path contains protected directory "${dp}"`;
      }
    }

    // Check file-name patterns
    for (const fp of blockedFilePatterns) {
      if (basename === fp || basename.startsWith(fp)) {
        return `file matches blocked pattern "${fp}"`;
      }
    }

    return undefined;
  }

  function checkBashCommand(command: string): string | undefined {
    const cmd = command.toLowerCase();

    // Always block commands referencing protected directories
    for (const dp of blockedDirPatterns) {
      if (cmd.includes(dp)) {
        return `command references protected directory "${dp}"`;
      }
    }

    // Block commands referencing absolute protected paths
    for (const bp of blockedAbsolutePaths) {
      if (cmd.includes(bp.toLowerCase())) {
        return `command references protected path "${bp}"`;
      }
    }

    // Block read-type commands that target sensitive file patterns
    const readPrefixes = [
      "cat ", "less ", "more ", "head ", "tail ",
      "grep ", "egrep ", "fgrep ", "rg ",
      "sed ", "awk ",
      "cp ", "mv ", "scp ",
      "vi ", "vim ", "nvim ", "nano ", "code ",
      "open ", "bat ", "source ", ". ",
      "base64 ", "xxd ", "hexdump ",
      "curl -d @", "curl --data @",
    ];

    for (const fp of blockedFilePatterns) {
      if (!cmd.includes(fp)) continue;
      // Only block if it looks like a read/access command
      for (const prefix of readPrefixes) {
        if (cmd.includes(prefix)) {
          return `command appears to read sensitive file matching "${fp}"`;
        }
      }
    }

    return undefined;
  }

  // ── Intercept tool calls ───────────────────────────────────────────

  pi.on("tool_call", async (event, _ctx) => {
    // Block read on sensitive files
    if (isToolCallEventType("read", event)) {
      const reason = checkPath(event.input.path);
      if (reason) {
        return { block: true, reason: `🔒 Blocked: ${reason}` };
      }
    }

    // Block write to sensitive files
    if (isToolCallEventType("write", event)) {
      const reason = checkPath(event.input.path);
      if (reason) {
        return { block: true, reason: `🔒 Blocked: ${reason}` };
      }
    }

    // Block edit on sensitive files
    if (isToolCallEventType("edit", event)) {
      const reason = checkPath(event.input.path);
      if (reason) {
        return { block: true, reason: `🔒 Blocked: ${reason}` };
      }
    }

    // Block bash commands that reference sensitive files
    if (isToolCallEventType("bash", event)) {
      const reason = checkBashCommand(event.input.command);
      if (reason) {
        return { block: true, reason: `🔒 Blocked: ${reason}` };
      }
    }

    // Block grep/find/ls on sensitive paths
    const pathTools = ["grep", "multi_grep", "find", "ls"];
    if (pathTools.includes(event.toolName)) {
      const pathArg = (event.input as Record<string, unknown>).path as string | undefined;
      if (pathArg) {
        const reason = checkPath(pathArg);
        if (reason) {
          return { block: true, reason: `🔒 Blocked: ${reason}` };
        }
      }
    }

    return undefined;
  });

  // ── Startup notification ───────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.notify("🔒 env-protection active — secrets are guarded", "info");
    }
  });
}
