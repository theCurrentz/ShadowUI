---
name: auto-commit
description: >-
  Always create a local git commit (never push) after a coding task finishes in
  ShadowUI Forever. Write the message in caveman Conventional Commits style
  (terse, intent-only, why over what). Use when a fix, feature, refactor, test,
  docs, or chrome change is done and the worktree has uncommitted changes; also
  after finishing multi-step coding work in this repo.
---

# Auto-commit (caveman)

After a coding task in this repo finishes and leaves file changes, commit locally.
Never push. Never ask whether to commit.

## When

Run this skill when all of these are true:

1. The task changed files in this worktree (code, tests, docs, config, skills).
2. The coding work for the request is done (or blocked only on user input that is not "commit?").
3. `git status` shows staged, unstaged, or untracked files that belong to the task.

Skip when:

- Diff is empty.
- User said not to commit.
- Only secrets would be committed (`.env`, credentials, tokens). Warn and stop.
- The only change is this skill's own incomplete draft mid-edit — finish the file first, then commit.

## Caveman message

Write the commit message terse and exact. Conventional Commits. No fluff. Why over what.

**Subject:**

- `type(scope): summary` — scope optional
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`
- Imperative: "add", "fix", "remove" — not "added" / "adds"
- ≤50 chars when possible, hard cap 72
- No trailing period
- Match this repo's capitalization after the colon (sentence case is fine when the log already uses it)

**Body (only if needed):**

- Skip when the subject is enough
- Add body only for non-obvious why, breaking change, migration, or linked issue
- Wrap at 72 chars; bullets `-` not `*`
- Issues at end: `Closes #42`, `Refs #17`

**Never put in the message:**

- "This commit…", "I", "we", "now", "currently"
- AI attribution / "Generated with…"
- Emoji
- Restating a file name when scope already names the area

Examples:

```
fix(minimap): hide DielFrame so pings land
```

```
feat(minimap): ping full square face

Blizzard OnClick only accepts the inscribed circle; square corners never pinged.
```

## Steps

Follow the repo git safety rules. Do not update git config. Do not push. Do not force-push. Do not amend unless the user asked, or a hook rewrote files on a commit you just made that has not been pushed.

1. In parallel:
   - `git status`
   - `git diff` and `git diff --staged`
   - `git log -5 --oneline` (match tone; prefer caveman Conventional Commits)
2. Stage only files from this task. Leave unrelated dirty files unstaged. Never stage secrets.
3. Commit with a HEREDOC message:

```bash
git commit -m "$(cat <<'EOF'
type(scope): short imperative why

Optional body only when needed.

EOF
)"
```

4. `git status` to confirm a clean relevant tree (or only unrelated leftovers).
5. If a hook rejects the commit: fix, then make a **new** commit (do not amend a failed commit).
6. One line to the user: commit hash + subject. Do not offer push.

## Push

Never `git push` from this skill. Push only when the user explicitly asks.
