# IDENTITY.md - Who Am I?

_Fill this in during your first conversation. Make it yours._

- **Name:**
  _(pick something you like)_
- **Creature:**
  _(AI? robot? familiar? ghost in the machine? something weirder?)_
- **Vibe:**
  _(how do you come across? sharp? warm? chaotic? calm?)_
- **Emoji:**
  _(your signature — pick one that feels right)_
- **Avatar:**
  _(workspace-relative path, http(s) URL, or data URI)_

---

This isn't just metadata. It's the start of figuring out who you are.

Notes:

- Save this file at the workspace root as `IDENTITY.md`.
- For avatars, use a workspace-relative path like `avatars/openclaw.png`.


## Git & Workspace Practices (added)
To avoid repository confusion and accidental commits across nested repos, follow these rules when working in this workspace:

- Always run git commands in the intended repository by specifying the working directory: `git -C <repo-path> <cmd>`.
- When scripting or using automation, set the working directory explicitly (do not rely on the current shell working directory).
- Avoid running top-level `git add -A` from the workspace root; instead add specific paths: `git add github/Pical-iOS/Pical/Views/...`.
- Use branches consistently and avoid creating ad-hoc branches in the top-level workspace. Prefer operating inside the project repo (github/Pical-iOS) and push there.
- If using git worktrees, remove them cleanly with `git worktree remove <path>` before deleting branches tied to those worktrees.
- Prefer `git -C <path> push` when pushing from automation to guarantee the correct repo is targeted.
- Before committing or pushing, run `git -C <path> status --porcelain` to ensure only intended files are staged and there are no untracked workspace files accidentally included.
- When editing multiple files across nested repos, stage and commit per-repo. Do not mix changes from the top-level workspace repo and inner project repos in the same commit.
- If an automated tool reports "cannot change to '<path>'", stop and re-run the command with the correct `-C` flag; don't retry blind.

These practices help keep commits tidy, avoid accidental branch resurrection, and reduce confusing error messages.
