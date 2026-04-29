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
| **Create Draft** | `gh pr create --draft --title "[Title]" --body "[Body]"` | `glab mr create --draft --title "[Title]" --description "[Body]"` |
| **View Status** | `gh pr status` | `glab mr list` |
| **Push & Link** | `git push -u origin [branch]` | `git push -u origin [branch]` |

### 3. Commenting (Feedback Loop)
| Action | GitHub (`gh`) | GitLab (`glab`) |
| :--- | :--- | :--- |
| **Post Update** | `gh pr comment [ID] --body "[Status]"` | `glab mr note [ID] --message "[Status]"` |

*Note: If CLI is missing, the agent should perform local git operations and notify the user to manage the remote manually.*
