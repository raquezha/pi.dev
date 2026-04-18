import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("clean-repo", {
    description:
      "Reset workspace — checkout main, pull, prune, delete merged branches",
    handler: async (_args, ctx) => {
      const steps: { name: string; result: string }[] = [];
      const deletedBranches: string[] = [];
      const keptBranches: { name: string; status: string }[] = [];

      // Step 1: Check uncommitted changes
      const status = await pi.exec("git", ["status", "--porcelain"], {
        timeout: 10_000,
      });

      if (status.code !== 0) {
        ctx.ui.notify(
          "Not a git repository or git not available",
          "error",
        );
        return;
      }

      const hasChanges = status.stdout.trim().length > 0;
      steps.push({
        name: "Uncommitted changes",
        result: hasChanges ? "⚠️ Found" : "✅ None",
      });

      if (hasChanges) {
        const proceed = await ctx.ui.confirm(
          "Uncommitted Changes",
          "You have uncommitted changes. Continue anyway?",
        );
        if (!proceed) {
          ctx.ui.notify("Cleanup cancelled", "warning");
          return;
        }
      }

      // Step 2: Determine main branch name
      const mainCheck = await pi.exec(
        "git",
        ["rev-parse", "--verify", "main"],
        { timeout: 5_000 },
      );
      const mainBranch = mainCheck.code === 0 ? "main" : "master";

      // Step 3: Checkout main/master
      const checkout = await pi.exec("git", ["checkout", mainBranch], {
        timeout: 10_000,
      });
      if (checkout.code === 0) {
        steps.push({ name: "Checkout", result: `✅ ${mainBranch}` });
      } else {
        steps.push({
          name: "Checkout",
          result: `❌ Failed: ${checkout.stderr.trim()}`,
        });
        showResult(pi, steps, deletedBranches, keptBranches);
        return;
      }

      // Step 4: Pull latest
      const pull = await pi.exec("git", ["pull"], { timeout: 30_000 });
      if (pull.code === 0) {
        const stdout = pull.stdout;
        if (stdout.includes("Already up to date")) {
          steps.push({ name: "Pull", result: "✅ Already up to date" });
        } else {
          const match = stdout.match(/(\d+) files? changed/);
          steps.push({
            name: "Pull",
            result: match ? `✅ Updated (${match[0]})` : "✅ Updated",
          });
        }
      } else {
        steps.push({
          name: "Pull",
          result: `❌ Failed: ${pull.stderr.trim()}`,
        });
      }

      // Step 5: Prune stale remote refs
      const prune = await pi.exec("git", ["fetch", "--prune"], {
        timeout: 15_000,
      });
      if (prune.code === 0) {
        const pruned = prune.stderr
          .split("\n")
          .filter((l) => l.includes("[deleted]")).length;
        steps.push({
          name: "Prune remotes",
          result:
            pruned > 0
              ? `✅ ${pruned} stale ref${pruned > 1 ? "s" : ""} removed`
              : "✅ Nothing to prune",
        });
      } else {
        steps.push({
          name: "Prune remotes",
          result: `❌ ${prune.stderr.trim()}`,
        });
      }

      // Step 6: Find merged branches
      const merged = await pi.exec(
        "git",
        ["branch", "--merged", mainBranch],
        { timeout: 5_000 },
      );
      const mergedBranches = merged.stdout
        .split("\n")
        .map((b) => b.trim().replace(/^\* /, ""))
        .filter(
          (b) => b.length > 0 && b !== "main" && b !== "master",
        );

      // Find ALL local branches for kept/unmerged list
      const allResult = await pi.exec("git", ["branch"], {
        timeout: 5_000,
      });
      const allLocal = allResult.stdout
        .split("\n")
        .map((b) => b.trim().replace(/^\* /, ""))
        .filter(
          (b) => b.length > 0 && b !== "main" && b !== "master",
        );
      const unmergedBranches = allLocal.filter(
        (b) => !mergedBranches.includes(b),
      );

      // Confirm before deleting
      if (mergedBranches.length > 0) {
        const confirmDelete = await ctx.ui.confirm(
          "Delete Merged Branches",
          `Delete ${mergedBranches.length} merged branch(es)?\n\n${mergedBranches.map((b) => `  • ${b}`).join("\n")}`,
        );

        if (confirmDelete) {
          for (const branch of mergedBranches) {
            const del = await pi.exec("git", ["branch", "-d", branch], {
              timeout: 5_000,
            });
            if (del.code === 0) {
              deletedBranches.push(branch);
            }
          }
          steps.push({
            name: "Delete merged branches",
            result: `✅ ${deletedBranches.length} deleted`,
          });
        } else {
          steps.push({
            name: "Delete merged branches",
            result: "⏭️ Skipped by user",
          });
        }
      } else {
        steps.push({
          name: "Delete merged branches",
          result: "✅ None to delete",
        });
      }

      // Gather info on kept (unmerged) branches
      for (const branch of unmergedBranches) {
        const ahead = await pi.exec(
          "git",
          ["rev-list", "--count", `${mainBranch}..${branch}`],
          { timeout: 5_000 },
        );
        keptBranches.push({
          name: branch,
          status: `${ahead.stdout.trim()} commits ahead`,
        });
      }

      showResult(pi, steps, deletedBranches, keptBranches);
    },
  });
}

function showResult(
  pi: ExtensionAPI,
  steps: { name: string; result: string }[],
  deleted: string[],
  kept: { name: string; status: string }[],
) {
  let md = "## 🧹 Cleanup Complete\n\n";
  md += "| Step | Result |\n|---|---|\n";
  for (const s of steps) {
    md += `| ${s.name} | ${s.result} |\n`;
  }

  if (deleted.length > 0) {
    md += "\n### Deleted Branches\n";
    md += "| Branch | Status |\n|---|---|\n";
    for (const b of deleted) {
      md += `| \`${b}\` | Merged, deleted |\n`;
    }
  }

  if (kept.length > 0) {
    md += "\n### Kept (unmerged)\n";
    md += "| Branch | Status |\n|---|---|\n";
    for (const b of kept) {
      md += `| \`${b.name}\` | ${b.status} |\n`;
    }
  }

  md += "\n---\n✅ **Ready.** Clean slate — start your new task!";

  pi.sendMessage({
    customType: "clean-repo",
    content: md,
    display: true,
  });
}
