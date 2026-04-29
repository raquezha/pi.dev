# Platform CLI Mapping

This reference ensures the agent uses the correct commands for the project's remote.

### 1. Detection
- Check `git remote -v`.
- If it contains `github.com` -> **Use GitHub CLI (`gh`)**.
- If it contains `gitlab.com` -> **Use GitLab CLI (`glab`)**.

### 2. Branching & PR/MR Creation
| Action | GitHub (`gh`) | GitLab (`glab`) |
| :--- | :--- | :--- |
| **Check Auth** | `gh auth status` | `glab auth status` |
| **Create Draft** | `gh pr create --draft -t "[Title]" -b "[Body]"` | `glab mr create --draft -t "[Title]" -d "[Body]"` |
| **View Status** | `gh pr status` | `glab mr list` |
| **Push & Link** | `git push -u origin [branch]` | `git push -u origin [branch]` |

### 💡 Platform Tips:
- **GitLab (`glab`)**: When using `--draft`, GitLab automatically prepends "Draft:" to the title. **DO NOT** include "Draft" or "WIP" in your `-t` title string to avoid double-prefixing.
- **GitHub (`gh`)**: Does not prepend "Draft:" to the title; it uses a UI badge. Keep the title clean.
