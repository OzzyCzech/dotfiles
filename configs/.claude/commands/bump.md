# Bump

Manual-only command: invoke this command only when explicitly requested by the user. Never auto-run it proactively.

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

## Steps

### 1. Preflight

- Abort if working tree is dirty.
- Record: branch, HEAD SHA, start timestamp.

### 2. Baseline validation

Run each if the script exists; abort the whole task if any fails:
`nr build`, `nr typecheck` (or `type-check`), `nr lint`, `nr test`.

### 3. Dependency updates

Bump everything to the **latest major**:

~~~bash
nlx taze major --write --install
# monorepo: add -r
~~~

Majors may introduce breaking changes — the retry + revert policy in step 10
handles regressions. Review changelogs for any package that ends up reverted.

After install: `nd` to dedupe lockfile.

### 4. Node.js pin

Check `.nvmrc`, `.node-version`, `.tool-versions`, `engines.node`.
Resolve active LTS: `nlx node-versions-info`.
Update pins older than active LTS. **Preserve existing pinning style**
(exact / major / range).

### 5. GitHub Actions

For each `uses:` in `.github/workflows/*`:

~~~bash
gh api repos/{owner}/{action}/releases/latest --jq '.tag_name' \
  || gh api repos/{owner}/{action}/tags --jq '.[0].name'
~~~

- Tag-pinned (`@v4`) → bump tag.
- SHA-pinned → resolve new tag to SHA; update SHA and trailing comment.
- For `pnpm/action-setup`: ensure `packageManager` in `package.json` or
  explicit `version:` in the workflow.

### 6. Node in CI

In workflows using `actions/setup-node`:

- Matrix: keep all active LTS, add `current` if missing.
- Single version: latest LTS (or `current` if clearly intended).

Reuse LTS data from step 4.

### 7. Mid-run validation

Re-run step 2 checks. Fix regressions per step 10 policy **before** audit.

### 8. Vulnerability audit

- npm: `npm audit fix`
- pnpm: `pnpm audit --fix`
- yarn v1: `yarn audit` (manual; `resolutions` if needed)
- yarn v2+: `yarn npm audit`
- bun: `bun audit`

Record remaining advisories (id, severity, package, path).

### 9. Dependabot

Skip if no `gh` or non-GitHub repo.

~~~bash
gh api /repos/{owner}/{repo}/dependabot/alerts \
  --jq '[.[] | select(.state=="open")]'
gh pr list --author "dependabot[bot]" --state open
~~~

Close superseded Dependabot PRs. List remaining alerts.

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

~~~text
chore: bump YYYY-MM-DD
~~~

### 12. Report

- Start / end / duration
- SHA before → after (or "uncommitted")
- Package manager + lockfile
- Dependency updates (name, old → new, bump level)
- Node updates (pin file, old → new)
- GitHub Actions updates (workflow, action, old → new, pin style)
- Breaking changes fixed (files)
- Reverted changes (what + why)
- Vulnerabilities: fixed / remaining (severity)
- Dependabot: closed PRs, remaining alerts
- Results: build / typecheck / lint / test (baseline / mid / final)
- Unresolved issues with root cause