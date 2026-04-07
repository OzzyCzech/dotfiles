# Update Dependencies

Perform a complete update of all project dependencies to the latest versions including major updates. Automatically fix all breaking changes.

## 1. Detect Package Manager

Determine which package manager the project uses based on the lock file:
- `bun.lockb` or `bun.lock` → bun
- `yarn.lock` → yarn
- `pnpm-lock.yaml` → pnpm
- `package-lock.json` → npm

Adapt all subsequent commands to the detected package manager. Referred to as `$PM` below.

## 2. Prepare Git State

- Verify a clean git state (no uncommitted changes). If there are any, create a stash or commit.
- Create a new git branch `chore/update-deps-YYYY-MM-DD` from the current branch.

## 3. Update All Packages with taze

Use `taze` to detect and write updates. Run via `npx taze` (works universally regardless of package manager):

```
npx taze major --write --install
```

If the project is a monorepo (contains workspaces), use recursive mode:

```
npx taze major --write --install -r
```

Flags:
- `major` — update to latest versions including major (breaking) changes
- `--write` (`-w`) — write changes directly to package.json
- `--install` (`-i`) — automatically run install after updating (taze detects the package manager on its own)
- `-r` — recursive mode for monorepos
- `--include-locked` (`-l`) — include locked (fixed) versions without ^ or ~

## 4. Remove Unused Packages

Run `npx knip` to detect unused dependencies, exports, and files.
- If knip finds unused dependencies or devDependencies, remove them (`$PM remove <package>`).
- Only log unused exports and files in the summary, do not delete them automatically.

## 5. Update Node.js Version

Check if the project defines a Node.js version in any of these files:
- `.nvmrc`
- `.node-version`
- `engines.node` in `package.json`

If so:
1. Determine the current Node.js LTS version (from https://nodejs.org or via `npx node-lts`).
2. If the defined version is older than the current LTS, update it to the latest LTS.
3. Preserve the format (if it was `>=18`, update to `>=22`; if it was `18.17.0`, update to the specific LTS version).

## 6. Audit and Fix Vulnerabilities

Run audit based on the package manager:
- npm: `npm audit fix`
- pnpm: `pnpm audit --fix`
- yarn: `yarn npm audit` (yarn v2+) or `yarn audit` (yarn v1)
- bun: `bun pm trust` (if relevant)

## 7. Check Dependabot Alerts (GitHub)

If `gh` CLI is available and the project is hosted on GitHub:

1. Check open Dependabot security alerts:
   ```
   gh api /repos/{owner}/{repo}/dependabot/alerts --jq '[.[] | select(.state=="open")]'
   ```
2. Check open Dependabot PRs:
   ```
   gh pr list --author "app/dependabot" --state open
   ```
3. If there are open Dependabot PRs for packages already updated in step 3, close them with a comment that they were resolved by the manual update.
4. Log remaining open alerts and PRs in the summary.

If `gh` is not available or the project is not on GitHub, skip this step.

## 8. Build, Tests, Lint, Typecheck

Run all scripts from package.json sequentially, if they exist (detect from package.json `scripts`):

1. `$PM run build`
2. `$PM run typecheck` (or `type-check`)
3. `$PM run lint`
4. `$PM run test`

## 9. Automatic Error Fixing

If anything from step 8 fails:

1. Analyze the error messages.
2. Fix breaking changes in the code — update imports, API calls, types, configurations, deprecated functions, whatever is needed.
3. After each fix, re-run the failing step.
4. Repeat until everything passes, up to 10 iterations per problem.
5. If a problem cannot be resolved after 10 attempts, log it in the summary as unresolved and move on.

## 10. Commit, Merge, and Cleanup

1. Commit all changes with message:
   ```
   chore(deps): update all packages YYYY-MM-DD
   ```
2. Switch back to the original branch and merge the update branch into it.
3. Delete the update branch `chore/update-deps-YYYY-MM-DD`.

## 11. Summary

At the end, provide a clear summary:
- Detected package manager
- List of updated packages (old version → new version)
- Removed unused packages
- Node.js version update (if performed)
- Fixed breaking changes and what was modified in the code
- Fixed vulnerabilities
- Dependabot alerts and closed PRs
- Result of build / typecheck / lint / test
- Any unresolved issues
