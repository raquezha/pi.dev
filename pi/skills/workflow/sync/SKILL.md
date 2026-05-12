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
- NEVER: post duplicate status comments to Jira/GitHub/GitLab if the factual progress (slices, commits, results) remains unchanged.
- NEVER: overwrite or update a Jira comment if a human has replied since the last sync.
- NEVER: close tickets automatically; leave final closure to the human.
- NEVER: sync secrets, private tokens, or raw hidden context.

## Workflow
1. **Context Discovery**:
   - For **GitHub/GitLab**: Get the remote URL or project ID: `git remote get-url origin`.
   - For **Jira**: Confirm the issue ID (e.g., `S3-6156`).
2. **Read Local State**:
   - Load `.workflow/active_task.json` to confirm the source and ID.
   - Read `WORK.md`. Extract: **Slices** (from `[PLAN]`), **Status** (latest `[LOG]` entries), and **Artifacts** (PR links or commit hashes).
3. **Draft Sync Message**:
   Use the "Dual-Audience" structure:
   ### 🟢 Stakeholder Summary (PM/Product)
   - **The Fix**: [1 sentence summary]
   - **The Result**: [Outcome/Impact]
   ### 🔍 How to Verify (QA/Manual)
   - **Scenario**: [Exact steps]
   - **Safety**: [Side-effects checked]
   ### 🛠 Technical Evidence (Dev-to-Dev)
   - **Vertical Slices**: [List from WORK.md]
   - **Commit/MR**: [Hash and Link]
   - **Automated Tests**: [Results]
   ---
   🤖 *Synced by pi (AI assistant) on behalf of the developer.*
   <!-- pi-sync-marker -->

4. **Publish (Platform-Specific Safety)**:

   ### Jira (Official ACLI)
   - **Logic**: Only update if Pi owns the *absolute newest* comment. If a human replied, create a new comment to avoid stomping on the conversation.
   - **Action**: `echo "body" | ./pi/skills/workflow/sync/jira_smart_sync.sh <id>`
   - **Mechanism**: The script parses Atlassian Document Format (ADF) JSON to find the signature.

   ### GitHub (gh)
   - **Logic**: Search for `<!-- pi-sync-marker -->`. Update the specific comment if found, else create new.
   - **Find**: `gh issue view <id> --json comments --jq '.comments[] | select(.body | contains("<!-- pi-sync-marker -->")) | .id'` (replace `issue` with `pr` if needed).
   - **Update**: `gh api -X PATCH /repos/{owner}/{repo}/issues/comments/<comment_id> -f body="<new_body>"`
   - **Create**: `gh issue comment <id> --body "<new_body>"`

   ### GitLab (glab)
   - **Logic**: Search for `<!-- pi-sync-marker -->` in notes. Update if found, else create.
   - **Update**: `glab api -X PUT projects/:id/merge_requests/:iid/notes/:note_id -f body="<new_body>"`
   - **Create**: `glab mr note <iid> -m "<new_body>"`

5. **Update Local Log**: Append `Synced to <tracker>: <description>` to `WORK.md` `[LOG]`.

## Output contract
End with:
- **Tracker**: jira/github/gitlab/local
- **Synced**: comments/subtasks/status/local log
- **Human action needed**
- **Next step**
