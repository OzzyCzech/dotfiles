Rebase the current branch.

Arguments: $ARGUMENTS

Behavior:

- No arguments: rebase on local main
- "origin": fetch origin, rebase on origin/main
- "origin/branch": fetch origin, rebase on origin/branch
- "branch": rebase on local branch

Steps:

1. Check for uncommitted changes:
   - Run `git status --porcelain`
   - If there are changes, run `git stash push -m "rebase-temp"`
   - Remember to pop the stash after rebase completes
2. Parse arguments:
   - No args → target is "main", no fetch
   - Contains "/" (e.g., "origin/develop") → split into remote and branch, fetch
     remote, target is remote/branch
   - Just "origin" → fetch origin, target is "origin/main"
   - Anything else → target is that branch name, no fetch
3. If fetching, run: `git fetch <remote>`
4. Run: `git rebase <target>`
5. If conflicts occur, handle them carefully (see below)
6. Continue until rebase is complete
7. If changes were stashed in step 1, run `git stash pop`

Handling conflicts:

- BEFORE resolving any conflict, understand what changes were made to each
  conflicting file in the target branch
- For each conflicting file, run `git log -p -n 3 <target> -- <file>` to see
  recent changes to that file in the target branch
- The goal is to preserve BOTH the changes from the target branch AND our
  branch's changes
- After resolving each conflict, stage the file and continue with
  `git rebase --continue`
- If a conflict is too complex or unclear, ask for guidance before proceeding
