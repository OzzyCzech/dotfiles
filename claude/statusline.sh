#!/bin/bash
# Claude Code status line: model | context + cache countdown | usage limit | project | branch | MR | scratchpad

input=$(cat)

# A cold cache that would re-cache fewer tokens than this is cheap, so the countdown stays hidden.
CACHE_MIN_TOKENS=20000
# The countdown appears only this close to the cache going cold.
CACHE_WARN_SECONDS=900
# How old the cached MR pipeline status may get before glab is asked again.
CI_TTL_SECONDS=60

E=$'\033'
RESET="$E[0m" DIM="$E[2m" GREEN="$E[32m" YELLOW="$E[33m" RED="$E[31m"
SEP=" $DIM|$RESET "
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

IFS=$'\x1f' read -r model ctx_pct cache_expires cache_tokens project cwd session worktree limit_pct limit_reset limit_window pr_number pr_url pr_state pr_kind <<<"$(jq -r '
	(.context_window // {}) as $c
	| (($c.current_usage // {}) | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) as $tokens
	| (.prompt_cache // {}) as $p
	| ([(.rate_limits // {}) | to_entries[] | select(.value.used_percentage? != null)] | max_by(.value.used_percentage)) as $limit
	| [
		(.model.display_name // .model.id // "Claude"),
		($c.used_percentage // (if ($c.context_window_size // 0) > 0 then $tokens * 100 / $c.context_window_size else 0 end) | floor),
		(if $p.warm == true then $p.expires_at // "" else "" end),
		($p.recache_tokens_if_cold // $tokens),
		(.workspace.project_dir // .workspace.current_dir // .cwd // ""),
		(.workspace.current_dir // .cwd // ""),
		(.session_id // ""),
		(.worktree.name // .workspace.git_worktree // ""),
		(if $limit then $limit.value.used_percentage | floor else "" end),
		(if $limit then $limit.value.resets_at // "" else "" end),
		(if $limit then (if $limit.key == "five_hour" then 18000 else 604800 end) else "" end),
		(.pr.number // ""),
		(.pr.url // ""),
		(.pr.review_state // ""),
		(.pr.kind // "")
	] | map(tostring) | join("\u001f")
' <<<"$input" 2>/dev/null)"

out="${model:-Claude}"

# Context: green up to 50 %, yellow up to 80 %, then red.
ctx_pct=${ctx_pct:-0}
filled=$(((ctx_pct + 5) / 10))
((filled > 10)) && filled=10
bar=""
for ((i = 0; i < 10; i++)); do
	if ((i < filled)); then bar+="█"; else bar+="░"; fi
done
color=$(level_color "$ctx_pct")
out+="$SEP$color${bar:0:filled}$DIM${bar:filled}$RESET $ctx_pct%"

# Prompt cache countdown: only while it is warm and going cold would be expensive.
if [[ $cache_expires =~ ^[0-9]+$ ]] && ((${cache_tokens%.*} >= CACHE_MIN_TOKENS)); then
	left=$((cache_expires - now))
	if ((left > 0 && left <= CACHE_WARN_SECONDS)); then
		ccolor=$YELLOW
		((left < 300)) && ccolor=$RED
		out+=" $ccolor⧗ $(((left + 59) / 60)) min$RESET"
	fi
fi

# Usage limit: the window closest to its limit. The arrow means usage runs ahead of time.
if [[ -n $limit_pct ]]; then
	segment="$(level_color "$limit_pct")$limit_pct%"
	if [[ $limit_reset =~ ^[0-9]+ ]]; then
		left=$((${limit_reset%.*} - now))
		((left < 0)) && left=0
		elapsed_pct=$(((limit_window - left) * 100 / limit_window))
		((limit_pct > elapsed_pct)) && segment+="↑"
		segment+="$RESET $(duration "$left")"
	else
		segment+="$RESET"
	fi
	out+="$SEP$segment"
fi

# Project: the last two path components, clickable.
if [[ -n $project ]]; then
	out+="$SEP$(link "file://$project" "$(basename "$(dirname "$project")")/$(basename "$project")")"
fi

git_in() {
	git -C "$cwd" --no-optional-locks "$@" 2>/dev/null
}

# Branch: the worktree name inside a linked worktree, otherwise only a branch other than main, in yellow.
# ↓ commits behind origin/main (a fast-forward merge needs a rebase), ↑ commits not pushed yet.
branch=""
[[ -n $cwd ]] && branch=$(git_in branch --show-current)
if [[ -n $worktree || ( -n $branch && $branch != main && $branch != master ) ]]; then
	if [[ -n $worktree ]]; then
		name=$worktree
	else
		name=$branch
		((${#name} > 32)) && name="${name:0:31}…"
		name="$YELLOW$name$RESET"
	fi
	sync=""
	if [[ -n $branch ]]; then
		base=origin/main
		git_in rev-parse -q --verify "$base" >/dev/null || base=origin/master
		remote=origin/$branch
		git_in rev-parse -q --verify "$remote" >/dev/null || remote=$base
		behind=$(git_in rev-list --count "HEAD..$base")
		unpushed=$(git_in rev-list --count "$remote..HEAD")
		((${behind:-0} > 0)) && sync+=" $YELLOW↓$behind$RESET"
		((${unpushed:-0} > 0)) && sync+=" $YELLOW↑$unpushed$RESET"
	fi
	out+="$SEP🌿 $name$sync"
fi

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
			success) ci=" $GREEN✓$RESET" ;;
			failed) ci=" $RED✗$RESET" ;;
			running | pending | created | preparing | waiting_for_resource | scheduled) ci=" $YELLOW●$RESET" ;;
			canceled | skipped) ci=" $DIM⊘$RESET" ;;
			manual) ci=" $DIM▶$RESET" ;;
		esac
	fi
	out+="$SEP$pcolor$label$RESET$ci"
fi

# Claude's scratchpad of this session: only when something is in it, clickable.
if [[ -n $session ]]; then
	for dir in /private/tmp/claude-"$(id -u)"/*/"$session"/scratchpad; do
		if [[ -d $dir && -n $(ls -A "$dir" 2>/dev/null) ]]; then
			out+="$SEP📁 $(link "file://$dir" scratch)"
			break
		fi
	done
fi

printf '%s' "$out"
