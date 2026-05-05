# Publish

Manual-only command: invoke this command only when explicitly requested by the user. Never auto-run it proactively.

Releases a new package version based on existing git tags and changes since the last release. Auto-detects the project ecosystem (Node.js, PHP, Rust, Python, Go) and publishes a GitHub Release alongside the package registry publish.

## Goal

- Detect the project type and its package manager.
- Find the latest semver tag (`vX.Y.Z` or `X.Y.Z`, including pre-releases like `vX.Y.Z-rc.1`).
- Evaluate changes since the last tag and propose the next version:
  - **major**: BC break / breaking change
  - **minor**: new features without BC break
  - **patch**: bugfixes, minor tweaks
- Ask the user which version to release (with a pre-filled suggestion).
- Create a release commit, tag, publish the package, and create a GitHub Release.

## Flags (optional)

- `--dry-run` — walks through all steps without writing anything (no commit, tag, publish, or GitHub Release). Prints what would happen.
- `--bump=<major|minor|patch|prerelease>` — skips interactive bump selection.
- `--version=<X.Y.Z>` — explicitly chosen version (skips suggestion and bump).
- `--pre=<rc|beta|alpha>` — pre-release identifier (creates e.g. `1.2.0-rc.1`).
- `--no-publish` — creates commit, tag, and GitHub Release, but does not publish to the registry.
- `--no-github-release` — skips the GitHub Release step.
- `--draft` — creates the GitHub Release as a draft.
- `--prerelease` — marks the GitHub Release as pre-release (auto-detected from version, but can be forced).
- `--yes` — non-interactive mode, confirms the recommended suggestion without prompting (only with `--bump` or `--version`).

## Steps

### 1. Preflight

- Verify you are in a git repository (`git rev-parse --git-dir`).
- Verify a clean working tree: `git status --porcelain`. If the tree is dirty, stop and ask the user to commit/stash.
- Verify you are on the expected branch (typically `main` / `master` / `trunk`). If not, **warn and require confirmation**.
- Verify the local branch is in sync with remote: `git fetch && git status -sb`. If `ahead`/`behind`, warn.
- Verify remote `origin` exists (or equivalent): `git remote -v`.
- Verify GitHub CLI availability if GitHub Release is enabled: `gh auth status`. If `gh` is missing or unauthenticated, stop and inform the user (or fall back with `--no-github-release`).
- Detect the package manager (see step 2).
- If publish is enabled, verify registry authentication:
  - npm/pnpm/yarn/bun: `npm whoami` (resp. `pnpm whoami` / `yarn npm whoami` / `bun pm whoami`)
  - Composer: check `auth.json` or Packagist access
  - Cargo: `cargo login` status (or existence of `~/.cargo/credentials.toml`)
  - Python: check `~/.pypirc` or `UV_PUBLISH_TOKEN`
- If authentication is missing, **stop before publish** and inform the user.

### 2. Ecosystem detection

Detect based on the presence of manifest files (in priority order):

- **Node.js**: `package.json`
  - lockfile → manager: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lockb` → bun, `package-lock.json` → npm
  - detect `"private": true` → skip registry publish (tag and GitHub Release only)
  - detect monorepo: `workspaces` in `package.json`, `pnpm-workspace.yaml` → see *Monorepo* section
- **PHP**: `composer.json` → Composer (publish is usually via Packagist = just pushing the tag)
- **Rust**: `Cargo.toml` → Cargo (`cargo publish`)
- **Python**: `pyproject.toml` → detect backend (Poetry, uv, Hatch, setuptools); `setup.py` → setuptools
- **Go**: `go.mod` → Go modules (publish = just tag push, no registry)

If multiple manifests are detected, ask the user which is primary.

### 3. Detect the latest version

- Fetch tags: `git fetch --tags --prune`.
- Find the latest semver tag (prefer highest semver version, not most recent date):
  - `git tag --list | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'` and sort semver-aware.
- Compare with the version in the manifest (e.g. `package.json`). If they differ, warn about the mismatch.
- If no tag exists:
  - use default starting point `0.1.0` (not `0.0.0` — that's an empty project)
  - ask if this is the first release.

### 4. Analyze changes since the last tag

- Get commits: `git log <last-tag>..HEAD --pretty=format:'%H%x09%s%x09%b' --no-merges`.
- If there are 0 commits, stop — nothing to release.
- Bump type heuristic (evaluate in this order):
  1. **major**, if at least one of:
     - `BREAKING CHANGE:` or `BREAKING-CHANGE:` in the commit footer
     - `!` in the Conventional Commit type (e.g. `feat!:`, `refactor!:`, `fix!:`)
     - explicit text: `bc break`, `backward incompatible`, `breaking change`
  2. **minor**, if at least one `feat:` / `feat(scope):` commit
  3. **patch** otherwise (incl. `fix:`, `perf:`, `refactor:`, `chore:` etc.)
- **Special rule for `0.x.y`**: per SemVer spec, 0.x is unstable. Suggest what would otherwise be `major` as `minor` (bump `0.X → 0.X+1.0`), and what would be `minor` as `patch`. Warn the user about this behavior and offer to switch to `1.0.0`.
- Print a brief rationale for the suggestion (e.g. *"Found 3× feat, 5× fix, no breaking → minor"*).
- Also list breaking changes, if any (from `BREAKING CHANGE:` footers).

### 5. Propose a concrete version (let me choose interactively)

- From the last version, compute candidates:
  - major: `X+1.0.0`
  - minor: `X.Y+1.0`
  - patch: `X.Y.Z+1`
  - prerelease (if `--pre` or current tag is already pre-release): `X.Y.Z-<pre>.N+1`
- Show an interactive prompt with:
  - the recommended bump and target version,
  - all alternative candidates,
  - a commit summary (counts by type)
- Let me select or edit the version interactively before proceeding.

### 6. Interactive confirmation

Ask the user (unless `--yes`):
- confirm the recommended version,
- pick a different bump,
- enter a custom version manually (validate semver regex),
- choose a pre-release variant.

Before proceeding, always explicitly confirm the final version and show the plan:
- which version
- which commit message
- which tag
- whether publish / GitHub Release will happen
- where publish goes (registry URL)

### 7. Changelog

- Detect existing changelog: `CHANGELOG.md`, `CHANGES.md`, `HISTORY.md`, or `.changeset/`.
- If it exists:
  - respect the format (Keep a Changelog, changesets, etc.)
  - generate a new section per Conventional Commits:
    - `### Breaking Changes` — from `!` and `BREAKING CHANGE:`
    - `### Features` — from `feat:`
    - `### Bug Fixes` — from `fix:`
    - `### Performance` — from `perf:`
    - `### Other` — remaining relevant entries
- If it doesn't exist, **ask** the user whether to create one (don't default to yes — some projects don't want it).
- Show the changelog diff for approval before committing.
- Keep the generated section content — it's reused in step 10 as the GitHub Release body.

### 8. Monorepo (if detected)

- Ask whether the release is for the **entire workspace** or a **specific package**.
- If a package:
  - tag format `<package-name>@vX.Y.Z` (npm/changesets convention)
  - bump only in that `package.json`
  - publish only that package
  - GitHub Release title: `<package-name> vX.Y.Z`
- For complex monorepos, recommend using a dedicated tool (changesets, Nx release, Lerna) instead of this command.

### 9. Release

Execute in order:

1. **Update version in the manifest** (without the package manager creating a tag):
   - npm: `npm version <version> --no-git-tag-version`
   - pnpm: `pnpm version <version> --no-git-tag-version`
   - yarn: `yarn version --new-version <version> --no-git-tag-version`
   - bun: `bun pm version <version> --no-git-tag-version`
   - Composer: edit `composer.json` (if a version field exists; often not — then skip)
   - Cargo: edit `version = "..."` in `Cargo.toml`, then `cargo update --workspace`
   - Poetry: `poetry version <version>`
   - uv: edit `project.version` in `pyproject.toml`
   - Go: no manifest change
2. **Update changelog** (if approved in step 7).
3. **Commit**: `git commit -am "chore(release): v<version>"` (or the project's convention, if detected from history).
4. **Tag**: `git tag -a v<version> -m "Release v<version>"`.
   - **Never overwrite an existing tag.** If it exists, stop with an error.
5. **Push**: `git push origin <branch> && git push origin v<version>`.
6. **Publish** (unless `--no-publish` and the project supports it):
   - npm: `npm publish` (with `--access public` for scoped packages, if new)
   - pnpm: `pnpm publish`
   - yarn: `yarn npm publish`
   - bun: `bun publish`
   - Cargo: `cargo publish`
   - Python (Poetry): `poetry publish --build`
   - Python (uv): `uv build && uv publish`
   - Composer/Go: publish = tag push (done in step 5)
7. **Verify publish**: query the registry (e.g. `npm view <name>@<version> version`) to confirm the version is available.

### 10. GitHub Release

Unless `--no-github-release`:

- Generate the release body:
  - **Primary source**: the new changelog section from step 7.
  - **Fallback** (if no changelog): auto-generate from Conventional Commits using the same grouping (Breaking Changes / Features / Bug Fixes / Performance / Other) with commit hashes linked.
  - Append a compare link: `**Full changelog**: https://github.com/<owner>/<repo>/compare/<prev-tag>...v<version>`.
- Create the release via GitHub CLI:
```
  gh release create v<version> \
    --title "v<version>" \
    --notes-file <generated-notes>
```
- Apply flags as appropriate:
  - `--draft` → add `--draft`
  - `--prerelease` (or auto-detected from pre-release version) → add `--prerelease`
  - Monorepo: `--title "<package-name> v<version>"`
- If the release already exists (tag collision edge case), stop with an error.
- Show the release URL in the final output.

### 11. Output

Return a structured report:

- Detected ecosystem and package manager
- Last tag
- Proposed bump and reasoning
- Chosen version
- Release commit hash
- Created tag
- Registry publish result (package URL, if applicable)
- GitHub Release URL
- Any warnings (0.x notice, missing changelog, auth issues, etc.)

## Safety rules

- Never run publish or create a GitHub Release without explicit user confirmation (except `--yes` mode with `--version` or `--bump`).
- Never overwrite an existing tag with the same name.
- Never force push or perform destructive actions on failure.
- Never publish a package marked as `private: true` (Node.js) or equivalent.
- If the user specifies a version lower than current, stop and require explicit confirmation (downgrade is usually a mistake).
- In `--dry-run` mode, no side-effectful command may run (no `git commit`, `git tag`, `git push`, `npm publish`, `gh release create`, etc.).