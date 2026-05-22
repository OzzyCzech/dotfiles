## Pre-flight check

Before starting any non-trivial implementation task:
- Run `git fetch --all && git log --oneline HEAD..@{u}` and report if origin is ahead. If so, summarize the diverging commits so the user can decide whether to rebase or stash.
- For work tied to an issue, briefly scan recently merged MRs/PRs for semantic overlap — the fix may already be on main.

## Language

- Use the language the user writes in (Czech → Czech, English → English).
- Code, commits, and GitLab/GitHub issues/MRs/PRs always in English regardless of conversation language.

## Plan Mode

- In plan mode, prepare textual content (issue descriptions, specs, MR bodies) directly in the response. Do NOT create implementation plan files unless explicitly asked.
