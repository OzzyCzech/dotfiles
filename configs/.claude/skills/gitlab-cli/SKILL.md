---
name: gitlab-cli
description: Reference guide for GitLab CLI (glab) commands. Use when running glab commands for issues, merge requests, pipelines, releases, or CI/CD operations, or when the user asks about GitLab CLI syntax.
---

# GitLab CLI (glab) Assistant

You have access to the glab CLI for GitLab operations. $ARGUMENTS

## Authentication

If there are authentication related errors, run: `glab auth status`

## Command Reference

### Issues

- `glab issue list [--assignee=@me] [--label=X] [--milestone=X] [--state=opened|closed|all]`
- `glab issue view <id> --comments`
- `glab issue create --title "X" --description "X" [--label=X] [--assignee=X]`
- `glab issue close <id>`
- `glab issue update <id> [--title=X] [--description=X] [--label=X] [--assignee=X]`
- `glab issue note <id> --message "X"` (add comment)

### Merge Requests

- `glab mr list [--assignee=@me] [--reviewer=@me] [--state=opened|merged|closed|all] [--label=X]`
- `glab mr view <id> --comments`
- `glab mr diff <id>` (view changes)
- `glab mr create --title "X" --description "X" [--source-branch=X] [--target-branch=X] [--related-issue=X]`
- `glab mr update <id> [--title=X] [--description=X] [--label=X] [--draft] [--ready]`
- `glab mr close <id>`
- `glab mr checkout <id>` (switch to MR branch locally)
- `glab mr approve <id>`
- `glab mr merge <id> [--squash] [--remove-source-branch]`
- `glab mr note <id> --message "X"` (add comment)

### CI/CD Pipelines

- `glab ci list` (list recent pipelines)
- `glab ci view [branch]` (interactive pipeline viewer)
- `glab ci status` (current branch pipeline status)
- `glab ci trace [job-id]` (view job logs)
- `glab pipeline run --branch <branch>` (trigger pipeline)
- `glab ci retry <job-id>`
- `glab ci cancel pipeline <id>`
- `glab ci cancel job <id>`

### Releases & Tags

- `glab release list`
- `glab release view <tag>`
- `glab release create <tag> --notes "X"`

### Labels & Milestones

- `glab label list [-F json]`
- `glab milestone list [--state=active|closed]`

### Repository Info

- `glab repo view` (project metadata)
- `glab api projects/:id/repository/commits` (recent commits via API)

### Raw API Access

- `glab api <endpoint> --method GET|POST|PUT|DELETE`
- `glab api graphql --field query='...'`

## Key Flags

- `-R owner/repo` or `--repo` - target different repository (supports GROUP/NAMESPACE/REPO format)
- `--hostname` - target specific GitLab instance
- `-F json` or `--output json` - machine-readable output (prefer this for parsing)
- `-w` or `--web` - open in browser
- `--per-page N` - control result count (default 30)
- `--page N` - pagination

## Workflow Patterns

### Summarize Feature/Epic Status

1. Find related issues: `glab issue list --label=<feature-label> -F json`
2. Find related MRs: `glab mr list --label=<feature-label> -F json`
3. For each open MR, check pipeline: `glab ci status --branch <source-branch>`
4. Optionally review code: `glab mr diff <id>` or checkout and read files

### Review an MR Thoroughly

1. `glab mr view <id> --comments` (understand context and discussion)
2. `glab mr diff <id>` (see all changes)
3. `glab mr checkout <id>` (get code locally)
4. Check CI: `glab ci status`
5. Add feedback: `glab mr note <id> --message "..."`

### Debug Failed Pipeline

1. `glab ci list -F json` (find failed pipeline)
2. `glab ci view` (identify failed job)
3. `glab ci trace <job-id>` (read full logs)
4. Suggest fix or create issue

### Prepare Release Summary

1. `glab release list` (find previous tag)
2. `glab api projects/:id/repository/compare?from=<old>&to=<new>` (commits between)
3. `glab mr list --state=merged --updated-after=<date> -F json`
4. `glab issue list --state=closed --updated-after=<date> -F json`

### Triage My Work

1. `glab issue list --assignee=@me --state=opened -F json`
2. `glab mr list --assignee=@me --state=opened -F json`
3. `glab mr list --reviewer=@me --state=opened -F json`

### Review Tickets Workflow

When reviewing ticket status against codebase:

1. List open issues: `glab issue list --assignee=@me --state=opened -F json`
2. For each issue, search git history: `git log --oneline --grep="<issue-id>"`
3. Check if related MRs are merged: `glab mr list --state=merged | grep "<issue-id>"`
4. Update issue status or add comments as needed

## Important Notes

- Always use `-F json` when you need to parse output programmatically
- Pipeline status: passed, failed, running, pending, canceled, skipped
- The `glab api` command can access any GitLab REST endpoint for advanced queries
- Rate limits apply; batch operations thoughtfully
