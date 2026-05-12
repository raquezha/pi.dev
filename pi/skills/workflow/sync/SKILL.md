---
name: sync
description: Sync active WORK.md status to the configured tracker. Use after /plan to publish implementation slices, and after /verify to report verified progress to Jira, GitHub, GitLab, or local logs.
---

# Skill: sync

Bridge the local RPIV workspace and the external tracker without duplicating workflow skills per platform.

## Guardrails
- READ: `.workflow/active_task.json` and active `WORK.md` `[PLAN]` and `[LOG]`.
- WRITE: remote tracker comments/subtasks/status, or append local sync note to `[LOG]` for `local` tasks.
- NEVER: modify `[BRIEF]` or `[GRILL]`.
- NEVER: close tickets automatically; leave final closure to the human.
- NEVER: sync secrets, private tokens, or raw hidden context.

## Workflow
1. Detect source from `.workflow/active_task.json`:
   - `jira` -> use `jira` CLI.
   - `github` -> use `gh` CLI.
   - `gitlab` -> use `glab` CLI.
   - `local` -> no remote; append a local sync note.
2. **Draft Sync Message**:
   Use the following "Dual-Audience" structure to avoid technical clutter:

   ### 🟢 Stakeholder Summary (PM/Product)
   - **The Fix**: [1 sentence in plain English: "Corrected total amount calculation for orders with fees."]
   - **The Result**: [What happens now? "No more 'red dots' during sync; data is now 100% accurate."]

   ### 🔍 How to Verify (QA/Manual)
   - **Scenario**: [Exact steps: "Create order with 50 fee -> confirm total is 911 -> sync."]
   - **Safety**: [What else was checked: "Verified that daily trip summaries still match."]

   ### 🛠 Technical Evidence (Dev-to-Dev)
   - **Vertical Slices**: [List from WORK.md]
   - **Commit/MR**: [Hash and Link]
   - **Automated Tests**: [Test names/results]

   ---
   🤖 *Synced by pi (AI assistant) on behalf of the developer.*
   <!-- pi-sync-marker -->

3. **Publish & Anti-Bloat (Factual State Checking)**:
   - **Authentication Reality Check**: You run under the *human's* user account. Using simple flags like `--edit-last` is dangerous because you might overwrite a human's recent comment.
   - **The Anchor Strategy**: 
     - **GitHub & GitLab**: Always include `<!-- pi-sync-marker -->` at the very bottom of your sync comment. This is the industry-standard bot tracking method.
     - **Jira**: Jira's rich text editor strips HTML comments. Rely strictly on the exact visible signature `🤖 *Synced by pi (AI assistant)*` as your anchor.
   - **Smart Sync / Diffing**: Fetch existing comments first using your anchor. Read its contents. Compare it to your planned message. **If the core facts (Slices, PR link, Test status) are identical, DO NOTHING.** Only proceed if there is a factual change.
   - For **GitHub** (`gh`): 
     1. Fetch comments: `gh issue view <id> --json comments` or `gh pr view <id> --json comments`.
     2. Find the comment body containing `<!-- pi-sync-marker -->`.
     3. If facts changed, update it: `gh api -X PATCH <endpoint>` (do NOT use `--edit-last`).
     4. If missing, create new.
   - For **GitLab** (`glab`): 
     1. Fetch notes via `glab api /projects/:id/merge_requests/:iid/notes`.
     2. Find the note containing `<!-- pi-sync-marker -->`.
     3. If facts changed, update via `PUT`. If missing, create new.
   - For **Jira**: 
     1. Fetch comments via `jira issue view <id>`. 
     2. Look for the `🤖 *Synced by pi` signature. Read the factual state.
     3. Since native Jira CLI lacks edit, only post a *new* comment if the facts have significantly progressed (e.g., from Plan to PR merged). Otherwise, abort locally.
4. Use tracker-specific status names only when configured or confirmed.
5. Report what was synced and what still needs human action.

## Output contract
End with:
- **Tracker**: jira/github/gitlab/local
- **Synced**: comments/subtasks/status/local log
- **Human action needed**
- **Next step**
