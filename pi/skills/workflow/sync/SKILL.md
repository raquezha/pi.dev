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
1. **Context Discovery**:
   - For **GitHub/GitLab**: Get the remote URL or project ID if not known.
     - `git remote get-url origin`
     - `gh repo view --json nameWithOwner`
   - For **Jira**: Confirm the project key from the issue ID (e.g., `S3` from `S3-6156`).
2. **Read Local State**:
   - Load `.workflow/active_task.json` to confirm the source and ID.
   - Read `WORK.md`. Extract:
     - **Slices**: From `[PLAN]` (e.g., `- [ ] Slice 1`).
     - **Status**: From `[LOG]` (look for the latest entries).
     - **Artifacts**: Find PR links or commit hashes in `[LOG]`.
3. **Draft Sync Message**:
   Use the following "Dual-Audience" structure:

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
     1. Find existing comment: `gh issue view <id> --json comments --jq '.comments[] | select(.body | contains("<!-- pi-sync-marker -->")) | .id'` (replace `issue` with `pr` if applicable).
     2. If found, update: `gh api -X PATCH /repos/{owner}/{repo}/issues/comments/<comment_id> -f body="<new_body>"`.
     3. If not found, create: `gh issue comment <id> --body "<new_body>"`.
   - For **GitLab** (`glab`): 
     1. List notes: `glab api projects/:id/merge_requests/:iid/notes` or `/projects/:id/issues/:iid/notes`.
     2. Find note with `<!-- pi-sync-marker -->`.
     3. If found, update: `glab api -X PUT projects/:id/merge_requests/:iid/notes/:note_id -f body="<new_body>"`.
     4. If not found, create: `glab mr note <iid> -m "<new_body>"` (or `glab issue note`).
   - For **Jira**: 
     1. Fetch comments: `jira issue view <id> --comments 10 --plain`. 
     2. Look for the `🤖 *Synced by pi` signature. Read the factual state.
     3. Since native Jira CLI lacks edit, only post a *new* comment if the facts have significantly progressed (e.g., from Plan to PR merged). Otherwise, abort locally.
     4. Post new comment: `echo "body" | jira issue comment add <id> --template -`.
4. **Update Local Log**:
   - Always append a sync note to `WORK.md` `[LOG]` after a successful remote sync:
     - `Synced to <tracker>: <brief description of what was updated>`
5. Report what was synced and what still needs human action.

## Output contract
End with:
- **Tracker**: jira/github/gitlab/local
- **Synced**: comments/subtasks/status/local log
- **Human action needed**
- **Next step**
