#!/bin/bash
# Claude Code status line:
# model effort | context + prompt cache | session limit | weekly limit | scratchpad
# | project + working dir git:(branch|operation) changes | MR or PR + pipeline + merge blockers
# It fits the width of the terminal: the least important parts go first, then the line breaks in two.

input=$(cat)

# A cold cache that would re-cache fewer tokens than this is cheap, so its state stays hidden.
CACHE_MIN_TOKENS=20000
# The countdown appears only this close to the cache going cold.
CACHE_WARN_SECONDS=900
# How old the cached pipeline and merge status of an MR or PR may get before glab or gh is asked again.
REVIEW_TTL_SECONDS=60
# Columns Claude Code takes beside the status line.
WIDTH_RESERVE=4

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

# Modification time of a file in epoch seconds, with GNU or BSD stat.
mtime() {
	stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

IFS=$'\x1f' read -r model effort fast ctx_pct cache_warm cache_expires cache_tokens project cwd scratchpad worktree worktree_path h5_pct h5_reset d7_pct d7_reset pr_number pr_url pr_state pr_kind <<<"$(jq -r '
	def limit: [
		(if .used_percentage == null then "" else .used_percentage | floor end),
		(.resets_at // "" | if type == "number" then floor else . end)
	];
	(.context_window // {}) as $c
	| (($c.current_usage // {}) | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) as $tokens
	| (.prompt_cache // {}) as $p
	| [
		(.model.display_name // .model.id // "Claude"),
		(.effort.level // ""),
		(.fast_mode // false),
		($c.used_percentage // (if ($c.context_window_size // 0) > 0 then $tokens * 100 / $c.context_window_size else 0 end) | floor),
		($p.warm // ""),
		($p.expires_at // ""),
		($p.recache_tokens_if_cold // $tokens),
		(.workspace.project_dir // .workspace.current_dir // .cwd // ""),
		(.workspace.current_dir // .cwd // ""),
		(.scratchpad_dir // ""),
		(.worktree.name // .workspace.git_worktree // ""),
		(.worktree.path // ""),
		((.rate_limits.five_hour // {}) | limit)[],
		((.rate_limits.seven_day // {}) | limit)[],
		(.pr.number // ""),
		(.pr.url // ""),
		(.pr.review_state // ""),
		(.pr.kind // "")
	] | map(tostring | gsub("[[:cntrl:]]"; " ")) | join("\u001f")
' <<<"$input" 2>/dev/null)"

# The parts of the line, each with the separator before it and the rank in which it goes when the line is too wide
# (0 stays). break_at is the part the second line starts with when dropping parts is not enough.
parts=() joins=() ranks=() break_at=""
add() {
	parts+=("$1")
	joins+=("${2-$SEP}")
	ranks+=("${3:-0}")
}

# Model with its effort level, fast mode spelled out.
segment=${model:-Claude}
[[ -n $effort ]] && segment+=" $DIM$effort$RESET"
[[ $fast == true ]] && segment+=" ${YELLOW}fast$RESET"
add "$segment"

# Context: green up to 50 %, yellow up to 80 %, then red.
ctx_pct=${ctx_pct:-0}
segment="Context: $(level_color "$ctx_pct")$ctx_pct%$RESET"

# Prompt cache, only when going cold would be expensive: a countdown shortly before it expires, then cold.
# The clock decides rather than the warm flag, which can lag right at the moment of expiry.
if [[ $cache_expires =~ ^[0-9]+$ ]] && ((${cache_tokens%.*} >= CACHE_MIN_TOKENS)); then
	left=$((cache_expires - now))
	if [[ $cache_warm == true ]] && ((left > 0)); then
		if ((left <= CACHE_WARN_SECONDS)); then
			ccolor=$YELLOW
			((left < 300)) && ccolor=$RED
			segment+=" ${ccolor}⧗ $(((left + 59) / 60)) min$RESET"
		fi
	else
		segment+=" ${BLUE}⧗ cold$RESET"
	fi
fi
add "$segment"

# Usage limits with the time left until the reset; the arrow means usage runs ahead of time.
# A limit at 80 % or more stays however narrow the terminal is.
limit() {
	local label=$1 pct=$2 reset=$3 window=$4 rank=${5:-0} left="" ahead=""
	[[ -n $pct ]] || return 0
	if [[ $reset =~ ^[0-9]+$ ]]; then
		left=$((reset - now))
		((left < 0)) && left=0
		((pct > (window - left) * 100 / window)) && ahead="↑"
	fi
	((pct >= 80)) && rank=0
	add "$label: $(level_color "$pct")$pct%$ahead$RESET${left:+ $(duration "$left")}" "$SEP" "$rank"
}
limit Session "$h5_pct" "$h5_reset" 18000
limit 7d "$d7_pct" "$d7_reset" 604800 2

# Claude's scratchpad of this session: only when something is in it, clickable.
if [[ -n $scratchpad && -d $scratchpad && -n $(ls -A "$scratchpad" 2>/dev/null) ]]; then
	add "$DIM$(link "file://$scratchpad" scratch)$RESET" "$SEP" 1
fi

# Git in the working directory, with messages in English whatever the locale.
git_in() {
	LC_ALL=C git -C "$cwd" --no-optional-locks "$@" 2>/dev/null
}

# The first line of a file, empty when it is missing.
file_line() {
	local line=""
	[[ -r $1 ]] && read -r line <"$1"
	printf '%s' "$line"
}

# The last two components of a path, the whole path right under the root.
short_path() {
	local parent=${1%/*}
	if [[ -z $parent || $parent == "$1" ]]; then printf '%s' "${1:-/}"; else printf '%s/%s' "${parent##*/}" "${1##*/}"; fi
}

# Project: the last two path components, clickable, bold cyan like the directory in the shell prompt.
# When Claude has moved elsewhere, the working directory follows, since the git status after it is its own:
# a subdirectory as a path relative to the project (or to the worktree of the session), a directory outside after an arrow.
break_at=${#parts[@]}
outside=""
if [[ -n $project ]]; then
	segment="${BOLD}${CYAN}$(link "file://$project" "$(short_path "$project")")$RESET"
	root=$project
	[[ -n $worktree_path && ($cwd == "$worktree_path" || $cwd == "$worktree_path"/*) ]] && root=$worktree_path
	if [[ -n $cwd && $cwd != "$root" ]]; then
		if [[ $cwd == "$root"/* ]]; then
			sub=${cwd#"$root"/}
			((${#sub} > 32)) && sub="…/${cwd##*/}"
			segment+="${CYAN}$(link "file://$cwd" "/$sub")$RESET"
		else
			outside=1
			segment+=" ${YELLOW}→$RESET ${BOLD}${CYAN}$(link "file://$cwd" "$(short_path "$cwd")")$RESET"
		fi
	fi
	add "$segment"
fi

# Git the way the shell prompt shows it: git:(branch), the worktree name inside a linked worktree,
# the short hash on a detached HEAD, the branch being rebased during a rebase. After a bar the operation
# in progress, with its step where git keeps one: REBASE 3/7, AM 1/2, MERGE, CHERRY-PICK, REVERT, BISECT.
# ✗ anything uncommitted, ⚠ files with conflicts, ↑ commits not pushed yet,
# ↓ commits behind the default branch of origin (a fast-forward merge needs a rebase), ● stashes,
# then lines added and removed against HEAD.
name=""
if [[ -n $cwd ]] && gitdir=$(git_in rev-parse --absolute-git-dir); then
	op="" step="" head=""
	if [[ -d $gitdir/rebase-merge ]]; then
		op=REBASE
		step="$(file_line "$gitdir/rebase-merge/msgnum")/$(file_line "$gitdir/rebase-merge/end")"
		head=$(file_line "$gitdir/rebase-merge/head-name")
	elif [[ -d $gitdir/rebase-apply ]]; then
		op=AM
		step="$(file_line "$gitdir/rebase-apply/next")/$(file_line "$gitdir/rebase-apply/last")"
		if [[ -f $gitdir/rebase-apply/rebasing ]]; then
			op=REBASE
			head=$(file_line "$gitdir/rebase-apply/head-name")
		fi
	elif [[ -f $gitdir/MERGE_HEAD ]]; then
		op=MERGE
	elif [[ -f $gitdir/CHERRY_PICK_HEAD ]]; then
		op=CHERRY-PICK
	elif [[ -f $gitdir/REVERT_HEAD ]]; then
		op=REVERT
	elif [[ -f $gitdir/BISECT_LOG ]]; then
		op=BISECT
	fi
	[[ $step =~ ^[0-9]+/[0-9]+$ ]] || step=""
	[[ $head == refs/heads/* ]] || head=""

	# One status for the branch, its upstream, the stashes, the changes and the conflicts.
	oid="" branch="" upstream="" ab="" stashes=0 changes="" conflicts=0
	while IFS= read -r line; do
		case $line in
			"# branch.oid "*) oid=${line#"# branch.oid "} ;;
			"# branch.head "*) branch=${line#"# branch.head "} ;;
			"# branch.upstream "*) upstream=${line#"# branch.upstream "} ;;
			"# branch.ab "*) ab=${line#"# branch.ab "} ;;
			"# stash "*) stashes=${line#"# stash "} ;;
			"#"*) ;;
			"u "*) changes=1 conflicts=$((conflicts + 1)) ;;
			?*) changes=1 ;;
		esac
	done < <(git_in status --porcelain=v2 --branch --show-stash --untracked-files=normal)
	[[ $branch == "(detached)" ]] && branch=""
	[[ $oid == "(initial)" ]] && oid=""

	name=${branch:-${head#refs/heads/}}
	[[ -z $name ]] && name=${oid:0:8}
	((${#name} > 32)) && name="${name:0:31}…"
	[[ -n $worktree && -n $name && -z $outside ]] && name=$worktree
fi
if [[ -n $name ]]; then
	segment="${BOLD}${BLUE}git:(${RED}$name"
	[[ -n $op ]] && segment+="${BLUE}|${YELLOW}$op${step:+ $step}"
	segment+="${BLUE})"
	[[ -n $changes ]] && segment+=" ${YELLOW}✗"
	((conflicts > 0)) && segment+=" ${RED}⚠$conflicts"
	if [[ -n $branch ]]; then
		base=$(git_in symbolic-ref -q --short refs/remotes/origin/HEAD)
		if [[ -z $base ]]; then
			base=origin/main
			git_in rev-parse -q --verify "$base" >/dev/null || base=origin/master
		fi
		# Not pushed means not on origin/<branch>, or not on the default branch before the first push.
		if [[ $upstream == "origin/$branch" && $ab =~ ^\+([0-9]+) ]]; then
			unpushed=${BASH_REMATCH[1]}
		else
			unpushed=$(git_in rev-list --count "origin/$branch..HEAD" || git_in rev-list --count "$base..HEAD")
		fi
		behind=$(git_in rev-list --count "HEAD..$base")
		((${unpushed:-0} > 0)) && segment+=" ${CYAN}↑$unpushed"
		((${behind:-0} > 0)) && segment+=" ${CYAN}↓$behind"
	fi
	((stashes > 0)) && segment+=" ${MAGENTA}●$stashes"
	add "$segment$RESET" " "

	stat=$(git_in diff HEAD --shortstat) diffstat=""
	[[ $stat =~ ([0-9]+)\ insertion ]] && diffstat+="${GREEN}+${BASH_REMATCH[1]}$RESET"
	[[ $stat =~ ([0-9]+)\ deletion ]] && diffstat+="${diffstat:+ }${RED}-${BASH_REMATCH[1]}$RESET"
	[[ -n $diffstat ]] && add "$diffstat" " " 3
fi

# Pipeline and merge status of the MR or PR at the URL in GitLab terms, separated by \x1f: the pipeline status,
# need_rebase when the branch must catch up with the target first, whether it has conflicts and whether its blocking
# threads are resolved (GitLab only). glab or gh runs in the background at most once a minute, the line shows the cached result.
review_status() {
	local url=$1 dir="${TMPDIR:-/tmp}/claude-statusline" file fetch filter
	if [[ $url =~ ^https?://([^/]+)/(.+)/-/merge_requests/([0-9]+) ]]; then
		fetch=(glab api --hostname "${BASH_REMATCH[1]}" "projects/${BASH_REMATCH[2]//\//%2F}/merge_requests/${BASH_REMATCH[3]}")
		filter='select(.iid)
			| [.head_pipeline.status // "", .detailed_merge_status // "", .has_conflicts, .blocking_discussions_resolved]'
	elif [[ $url =~ ^https?://[^/]+/[^/]+/[^/]+/pull/[0-9]+ ]]; then
		fetch=(gh pr view "$url" --json number,statusCheckRollup,mergeStateStatus,mergeable)
		filter='select(.number)
			| [.statusCheckRollup[]?
				| if .__typename == "StatusContext" then {SUCCESS: "success", FAILURE: "failed", ERROR: "failed"}[.state] // "running"
				elif .status != "COMPLETED" then "running"
				else {SUCCESS: "success", NEUTRAL: "success", SKIPPED: "skipped", STALE: "skipped", CANCELLED: "canceled"}[.conclusion] // "failed"
				end] as $checks
			| [
				(if any($checks[]; . == "failed") then "failed"
				elif any($checks[]; . == "running") then "running"
				elif any($checks[]; . == "success") then "success"
				else $checks[0] // "" end),
				(if .mergeStateStatus == "BEHIND" then "need_rebase" else "" end),
				.mergeable == "CONFLICTING",
				""
			]'
	else
		return
	fi
	mkdir -p "$dir"
	file="$dir/review-${url//[^A-Za-z0-9]/_}"
	[[ -d $file.lock && $((now - $(mtime "$file.lock"))) -gt 120 ]] && rmdir "$file.lock" 2>/dev/null
	if [[ ! -f $file || $((now - $(mtime "$file"))) -ge REVIEW_TTL_SECONDS ]] && mkdir "$file.lock" 2>/dev/null; then
		(
			if status=$("${fetch[@]}" | jq -er "$filter"' | map(tostring) | join("\u001f")'); then
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

# Open MR or PR of the branch, clickable, coloured by its review state, with the pipeline status
# and what still blocks the merge: conflicts, a rebase, unresolved blocking threads.
if [[ -n $pr_number ]]; then
	case $pr_state in
		approved) pcolor=$GREEN ;;
		changes_requested) pcolor=$RED ;;
		draft) pcolor=$DIM ;;
		*) pcolor="" ;;
	esac
	label="#$pr_number"
	[[ $pr_kind == mr ]] && label="!$pr_number"
	[[ -n $pr_url ]] && label=$(link "$pr_url" "$label")
	segment="$pcolor$label$RESET"
	if [[ -n $pr_url ]]; then
		IFS=$'\x1f' read -r pipeline merge_status conflicting resolved <<<"$(review_status "$pr_url")"
		case $pipeline in
			success) segment+=" ${GREEN}✓$RESET" ;;
			failed) segment+=" ${RED}✗$RESET" ;;
			running | pending | created | preparing | waiting_for_resource | scheduled) segment+=" ${YELLOW}●$RESET" ;;
			canceled | skipped) segment+=" ${DIM}⊘$RESET" ;;
			manual) segment+=" ${DIM}▶$RESET" ;;
		esac
		[[ $conflicting == true ]] && segment+=" ${RED}conflict$RESET"
		[[ $merge_status == need_rebase ]] && segment+=" ${YELLOW}rebase$RESET"
		[[ $resolved == false ]] && segment+=" ${YELLOW}threads$RESET"
	fi
	add "$segment"
fi

# Visible width of a text in characters: without colours and links, UTF-8 continuation bytes not counted.
visible_width() {
	local LC_ALL=C s=$1 re=$'\e(\\[[0-9;]*m|]8;;[^\e]*\e\\\\)'
	while [[ $s =~ $re ]]; do s=${s//"${BASH_REMATCH[0]}"/}; done
	s=${s//[$'\x80'-$'\xbf']/}
	REPLY=${#s}
}

# Whether the text fits the width of the terminal, always when the width is unknown.
fits() {
	((width == 0)) && return 0
	visible_width "$1"
	((REPLY <= width))
}

# The parts from $1 up to $2 joined into REPLY, without those of rank 1 to $3.
render() {
	local i line=""
	for ((i = $1; i < $2; i++)); do
		((ranks[i] > 0 && ranks[i] <= $3)) && continue
		line+="${line:+${joins[i]}}${parts[i]}"
	done
	REPLY=$line
}

# One line with as few parts dropped as it takes, otherwise two lines the same way, the second from the project on.
width=0
[[ $COLUMNS =~ ^[0-9]+$ ]] && ((COLUMNS > 20)) && width=$((COLUMNS - WIDTH_RESERVE))
count=${#parts[@]}
for drop in 0 1 2 3; do
	render 0 "$count" "$drop"
	line=$REPLY
	fits "$line" && printf '%s' "$line" && exit 0
done
for drop in 0 1 2 3; do
	render 0 "$break_at" "$drop"
	first=$REPLY
	render "$break_at" "$count" "$drop"
	second=$REPLY
	if { fits "$first" && fits "$second"; } || ((drop == 3)); then
		printf '%s%s%s' "$first" "${first:+${second:+$'\n'}}" "$second"
		exit 0
	fi
done
