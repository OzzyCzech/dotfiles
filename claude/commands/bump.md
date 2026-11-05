---
description: Full dependency and toolchain bump — deps to latest major, Node pins, GitHub Actions, audit, validate, commit
disable-model-invocation: true
---

# Bump

Run full dependency and toolchain bump on the current branch. Do not switch branches.

## Summary

- Update all project dependencies (both dependencies and devDependencies) to the latest stable versions.
- Install, then fix any breaking changes.
- Ensure the project still builds, lints, typechecks and passes tests.

## Policies

- **Package manager:** use `ni` (<https://github.com/antfu-collective/ni>).
  Commands: `ni` install, `nr <script>` run, `nlx <cmd>` one-off, `nup` update,
  `nci` clean install, `nd` dedupe. Fall back to the native PM if `ni` is
  missing.
- **TypeScript:** in all TS projects, use `@ozzyczech/tsconfig` as the shared
  base config (<https://github.com/OzzyCzech/tsconfig>).
- **Never push.** The run ends with a local commit.

## Steps

### 1. Preflight

- If the working directory is not a git repo but contains several, ask which
  to bump. Run each repo separately, in dependency order, and keep
  `packageManager` on the same version across related repos.
- Abort if working tree is dirty. Untracked agent worktrees under `.claude/`
  don't count — but never stage them.
- `git fetch`; if the upstream is ahead, fast-forward first (abort if
  diverged). Bumping a stale branch guarantees lockfile conflicts.
- Record: branch, HEAD SHA, start timestamp.

### 2. Baseline validation

Run each if the script exists; abort the whole task if any fails:
`nr build`, `nr typecheck` (or `type-check`), `nr lint`, `nr test`.

Also run the checks CI runs that are not scripts — read
`.github/workflows/*` (e.g. `biome ci .`, a docs build). Otherwise a
regression only shows up in CI.

### 3. Dependency updates

Bump everything to the **latest major**. Dry-run first and review the list:

~~~bash
nlx taze major --include-locked            # review
nlx taze major --include-locked --write --install
# monorepo: add -r
~~~

- Without `--include-locked`, taze silently skips exact-pinned deps. Keep exact
  pins that are intentional (e.g. sibling packages pinned exactly), bump the
  accidental ones.
- Hold back a package blocked by a peer cap (e.g. a tool that caps the
  TypeScript version) with `--exclude <pkg>` and list it in the report. In zsh
  spell the flag out — an unquoted `$var` holding `--exclude pkg` is not
  word-split and taze fails.
- taze also rewrites the targets of `overrides` (`pnpm-workspace.yaml` /
  `package.json`). Those are security floors, not deps: revert them
  (`git checkout -- pnpm-workspace.yaml`) and reinstall.
- A `0.x` minor bump (`0.27 → 0.30`) is a major by semver: read the changelog
  for the APIs the project calls, and smoke-test them (dry run) when the tests
  don't reach them.

Majors may introduce breaking changes — the retry + revert policy in step 10
handles regressions. Review changelogs for any package that ends up reverted.

After install: `nd` to dedupe lockfile.

### 4. Node.js pin

Check `.nvmrc`, `.node-version`, `.tool-versions`, `engines.node`.
Resolve active LTS: `nlx node-versions-info` (run it inside a project — outside
one, `nlx` prompts for a package manager). Fallback:
`https://raw.githubusercontent.com/nodejs/Release/main/schedule.json` (phases)
and `https://nodejs.org/dist/index.json` (latest release per major).
Update pins older than active LTS. **Preserve existing pinning style**
(exact / major / range).

Raising `engines.node` in a published package drops a possibly still
maintained LTS and changes the tarball, so it needs a release — call it out in
the report.

### 5. GitHub Actions

For each `uses:` in `.github/workflows/*`:

~~~bash
gh api repos/{owner}/{action}/releases/latest --jq '.tag_name' \
  || gh api repos/{owner}/{action}/tags --jq '.[0].name'
~~~

- Tag-pinned (`@v4`) → bump tag. A major-tag pin changes only when a new major
  exists (latest `v7.0.1` → keep `@v7`).
- SHA-pinned → resolve new tag to SHA; update SHA and trailing comment.
- For `pnpm/action-setup`: ensure `packageManager` in `package.json` or
  explicit `version:` in the workflow.

### 6. Node in CI

In workflows using `actions/setup-node`:

- Matrix: keep all active LTS, add `current` if missing. Drop versions below
  the (new) `engines.node` floor. While the next major is still alpha/rc,
  `current` equals the active LTS and the jobs duplicate — acceptable.
- Single version: latest LTS (or `current` if clearly intended).

Reuse LTS data from step 4.

### 7. Mid-run validation

Re-run step 2 checks. Fix regressions per step 10 policy **before** audit.

Formatter/linter minors can start covering new file types or rules (Biome
2.6 began formatting YAML and code blocks in Markdown). Fix with the project's
format script (`nr format`) and check the diff is only cosmetic.

### 8. Vulnerability audit

- npm: `npm audit fix`
- pnpm: `pnpm audit --fix`
- yarn v1: `yarn audit` (manual; `resolutions` if needed)
- yarn v2+: `yarn npm audit`
- bun: `bun audit`

The fix adds overrides — check each target against the range the dependent
declares:

- Within the range → keep.
- Crosses a major the dependent declares (`minimatch ^11` under `^10`) →
  keep only if the dependent demonstrably still works (run it).
- Only fixed in a major the dependent can't use (`zod 4` under `^3`) → don't
  override; record as remaining with the reason.

Match the existing override style (quoting, ranged selectors
`'pkg@<1.2.3': '>=1.2.3'`). Record remaining advisories (id, severity,
package, path).

### 9. Dependabot

Skip if no `gh` or non-GitHub repo.

~~~bash
gh api /repos/{owner}/{repo}/dependabot/alerts \
  --jq '[.[] | select(.state=="open")]'
gh pr list --author "dependabot[bot]" --state open
~~~

Close superseded Dependabot PRs. List remaining alerts. HTTP 403 "Dependabot
alerts are disabled" → report as disabled, not as a failure.

### 10. Final validation + retry policy

Re-run step 2 checks.

**On failure:**

- *Attempt* = diagnose + fix + re-run.
- **Max 3 attempts** per distinct failure.
- On attempt 3 failing: revert the **specific change** that caused it (one
  package pin, one workflow bump) — not the whole run. Mark unresolved with
  root cause.
- If the cause can't be isolated: revert the last group of changes (e.g. all
  of step 3).

Tree must be green before step 11.

### 11. Commit

**Only if step 10 is green.** If anything is unresolved, skip commit and
continue to report.

Stage tracked changes only (`git add -u` — includes the lockfile; never
untracked tool dirs).

~~~text
chore: bump YYYY-MM-DD
~~~

Then verify the commit on a clean checkout: `git archive HEAD | tar -x -C <tmp>`,
`nci` (frozen lockfile), step 2 checks. With a populated `node_modules`, pnpm's
"Already up to date" fast path skips the lockfile and override checks that CI
runs. On failure: fix, amend, re-verify.

### 12. Report

- Start / end / duration
- SHA before → after (or "uncommitted")
- Package manager + lockfile
- Dependency updates (name, old → new, bump level)
- Held-back packages (excluded + why)
- Node updates (pin file, old → new)
- GitHub Actions updates (workflow, action, old → new, pin style)
- Breaking changes fixed (files)
- Reverted changes (what + why)
- Vulnerabilities: fixed / remaining (severity, why not fixed)
- Dependabot: closed PRs, remaining alerts
- Results: build / typecheck / lint / test (baseline / mid / final / clean checkout)
- Release impact (libraries): does the published artifact change (`dist`,
  `dependencies`, `engines`)? Dev-only bumps don't need a release.
- Unresolved issues with root cause
