#!/bin/bash
# Claude Code status line: model | context + prompt cache | session limit | weekly limit | scratchpad | project git:(branch) changes | MR

input=$(cat)

# A cold cache that would re-cache fewer tokens than this is cheap, so its state stays hidden.
CACHE_MIN_TOKENS=20000
# The countdown appears only this close to the cache going cold.
CACHE_WARN_SECONDS=900
# How old the cached MR pipeline status may get before glab is asked again.
CI_TTL_SECONDS=60

E=$'\033'
RESET="$E[0m" BOLD="$E[1m" DIM="$E[2m" RED="$E[31m" GREEN="$E[32m" YELLOW="$E[33m" BLUE="$E[34m" MAGENTA="$E[35m" CYAN="$E[36m"
SEP=" ${DIM}|$RESET "
now=$(date +%s)

level_color() {
	if (($1 < 50)); then printf '%s' "$GREEN"; elif (($1 < 80)); then printf '%s' "$YELLOW"; else printf '%s' "$RED"; fi
}

link() {
	printf '%s]8;;%s%s\\%s%s]8;;%s\\' "$E" "$1" "$E" "$2" "$E" "$E"
}

duration() {
	local s=$1
	if ((s >= 86400)); then
		printf '%dd %dh' $((s / 86400)) $((s % 86400 / 3600))
	else
		printf '%d:%02d' $((s / 3600)) $((s % 3600 / 60))
	fi
}

IFS=$'\x1f' read -r model ctx_pct cache_warm cache_expires cache_tokens project cwd scratchpad worktree h5_pct h5_reset d7_pct d7_reset pr_number pr_url pr_state pr_kind <<<"$(jq -r '
	def limit: [
		(if .used_percentage == null then "" else .used_percentage | floor end),
		(.resets_at // "" | if type == "number" then floor else . end)
	];
	(.context_window // {}) as $c
	| (($c.current_usage // {}) | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) as $tokens
	| (.prompt_cache // {}) as $p
	| [
		(.model.display_name // .model.id // "Claude"),
		($c.used_percentage // (if ($c.context_window_size // 0) > 0 then $tokens * 100 / $c.context_window_size else 0 end) | floor),
		($p.warm // ""),
		($p.expires_at // ""),
		($p.recache_tokens_if_cold // $tokens),
		(.workspace.project_dir // .workspace.current_dir // .cwd // ""),
		(.workspace.current_dir // .cwd // ""),
		(.scratchpad_dir // ""),
		(.worktree.name // .workspace.git_worktree // ""),
		((.rate_limits.five_hour // {}) | limit)[],
		((.rate_limits.seven_day // {}) | limit)[],
		(.pr.number // ""),
		(.pr.url // ""),
		(.pr.review_state // ""),
		(.pr.kind // "")
	] | map(tostring | gsub("[[:cntrl:]]"; " ")) | join("\u001f")
' <<<"$input" 2>/dev/null)"

out="${model:-Claude}"

# Context: green up to 50 %, yellow up to 80 %, then red.
ctx_pct=${ctx_pct:-0}
out+="${SEP}Context: $(level_color "$ctx_pct")$ctx_pct%$RESET"

# Prompt cache, only when going cold would be expensive: a countdown shortly before it expires, then cold.
# The clock decides rather than the warm flag, which can lag right at the moment of expiry.
if [[ $cache_expires =~ ^[0-9]+$ ]] && ((${cache_tokens%.*} >= CACHE_MIN_TOKENS)); then
	left=$((cache_expires - now))
	if [[ $cache_warm == true ]] && ((left > 0)); then
		if ((left <= CACHE_WARN_SECONDS)); then
			ccolor=$YELLOW
			((left < 300)) && ccolor=$RED
			out+=" ${ccolor}⧗ $(((left + 59) / 60)) min$RESET"
		fi
	else
		out+=" ${BLUE}⧗ cold$RESET"
	fi
fi

# Usage limits with the time left until the reset; the arrow means usage runs ahead of time.
limit() {
	local label=$1 pct=$2 reset=$3 window=$4 left="" ahead=""
	[[ -n $pct ]] || return 0
	if [[ $reset =~ ^[0-9]+$ ]]; then
		left=$((reset - now))
		((left < 0)) && left=0
		((pct > (window - left) * 100 / window)) && ahead="↑"
	fi
	out+="$SEP$label: $(level_color "$pct")$pct%$ahead$RESET${left:+ $(duration "$left")}"
}
limit Session "$h5_pct" "$h5_reset" 18000
limit 7d "$d7_pct" "$d7_reset" 604800

# Claude's scratchpad of this session: only when something is in it, clickable.
if [[ -n $scratchpad && -d $scratchpad && -n $(ls -A "$scratchpad" 2>/dev/null) ]]; then
	out+="$SEP$DIM$(link "file://$scratchpad" scratch)$RESET"
fi

git_in() {
	git -C "$cwd" --no-optional-locks "$@" 2>/dev/null
}

# Project: the last two path components, clickable, bold cyan like the directory in the shell prompt.
repo=""
[[ -n $project ]] && repo="${BOLD}${CYAN}$(link "file://$project" "$(basename "$(dirname "$project")")/$(basename "$project")")$RESET"

# Git the way the shell prompt shows it: git:(branch), the worktree name inside a linked worktree,
# the short hash on a detached HEAD. ✗ anything uncommitted, ↑ commits not pushed yet,
# ↓ commits behind origin/main (a fast-forward merge needs a rebase), ● stashes,
# then lines added and removed against HEAD.
branch="" name=""
if [[ -n $cwd ]]; then
	branch=$(git_in branch --show-current)
	[[ -z $branch ]] && name=$(git_in rev-parse --short=8 HEAD)
fi
if [[ -n $branch ]]; then
	name=$branch
	((${#name} > 32)) && name="${name:0:31}…"
fi
[[ -n $worktree ]] && name=$worktree
if [[ -n $name ]]; then
	segment="${BOLD}${BLUE}git:(${RED}$name${BLUE})"
	[[ -n $(git_in status --porcelain --untracked-files=normal) ]] && segment+=" ${YELLOW}✗"
	if [[ -n $branch ]]; then
		base=origin/main
		git_in rev-parse -q --verify "$base" >/dev/null || base=origin/master
		remote=origin/$branch
		git_in rev-parse -q --verify "$remote" >/dev/null || remote=$base
		unpushed=$(git_in rev-list --count "$remote..HEAD")
		behind=$(git_in rev-list --count "HEAD..$base")
		((${unpushed:-0} > 0)) && segment+=" ${CYAN}↑$unpushed"
		((${behind:-0} > 0)) && segment+=" ${CYAN}↓$behind"
	fi
	stashes=$(git_in rev-list --walk-reflogs --count refs/stash)
	((${stashes:-0} > 0)) && segment+=" ${MAGENTA}●$stashes"
	segment+=$RESET
	stat=$(git_in diff HEAD --shortstat)
	[[ $stat =~ ([0-9]+)\ insertion ]] && segment+=" ${GREEN}+${BASH_REMATCH[1]}$RESET"
	[[ $stat =~ ([0-9]+)\ deletion ]] && segment+=" ${RED}-${BASH_REMATCH[1]}$RESET"
	repo+="${repo:+ }$segment"
fi
[[ -n $repo ]] && out+="$SEP$repo"

# Pipeline status of a GitLab MR. glab runs in the background at most once a minute, the line shows the cached result.
ci_status() {
	local url=$1 dir="${TMPDIR:-/tmp}/claude-statusline" file host project iid
	[[ $url =~ ^https?://([^/]+)/(.+)/-/merge_requests/([0-9]+) ]] || return
	host=${BASH_REMATCH[1]} project=${BASH_REMATCH[2]} iid=${BASH_REMATCH[3]}
	mkdir -p "$dir"
	file="$dir/ci-${host}-${project//\//_}-$iid"
	[[ -d $file.lock && $((now - $(stat -f %m "$file.lock"))) -gt 120 ]] && rmdir "$file.lock" 2>/dev/null
	if [[ ! -f $file || $((now - $(stat -f %m "$file"))) -ge CI_TTL_SECONDS ]] && mkdir "$file.lock" 2>/dev/null; then
		(
			if status=$(glab api --hostname "$host" "projects/${project//\//%2F}/merge_requests/$iid" | jq -er '.head_pipeline.status // ""'); then
				printf '%s' "$status" >"$file.tmp" && mv "$file.tmp" "$file"
			else
				touch "$file"
			fi
			rmdir "$file.lock"
		) &>/dev/null &
		disown
	fi
	[[ -f $file ]] && printf '%s' "$(<"$file")"
}

# Open MR or PR of the branch, clickable, coloured by its review state, with the pipeline status.
if [[ -n $pr_number ]]; then
	case $pr_state in
		approved) pcolor=$GREEN ;;
		changes_requested) pcolor=$RED ;;
		draft) pcolor=$DIM ;;
		*) pcolor="" ;;
	esac
	label="#$pr_number"
	[[ $pr_kind == mr ]] && label="!$pr_number"
	if [[ -n $pr_url ]]; then label=$(link "$pr_url" "$label"); fi
	ci=""
	if [[ $pr_kind == mr && -n $pr_url ]]; then
		case $(ci_status "$pr_url") in
			success) ci=" ${GREEN}✓$RESET" ;;
			failed) ci=" ${RED}✗$RESET" ;;
			running | pending | created | preparing | waiting_for_resource | scheduled) ci=" ${YELLOW}●$RESET" ;;
			canceled | skipped) ci=" ${DIM}⊘$RESET" ;;
			manual) ci=" ${DIM}▶$RESET" ;;
		esac
	fi
	out+="$SEP$pcolor$label$RESET$ci"
fi

printf '%s' "$out"
