#!/bin/sh
# Helpers for a stack of branches, one per PR, each built on the one below.
# A layer is any local branch between the stack base and HEAD, so run these from the top layer.
# `git stack-restack <base>` records the base in `git config stack.base` for the other commands;
# it defaults to master.
set -eu

base=$(git config stack.base || echo master)

die() {
	printf 'stack: %s\n' "$*" >&2
	exit 1
}

layers() {
	git for-each-ref --format='%(refname:short)' --merged HEAD --no-merged "$base" refs/heads/ |
		while read -r b; do
			printf '%s %s\n' "$(git rev-list --count "$base..$b")" "$b"
		done | sort -n | cut -d' ' -f2-
}

# Refs holding commits the stack lacks: a layer whose origin copy has commits you never had
# locally (a "Commit suggestion" on GitHub), or a branch that forked off a layer.
strays() {
	for b in "$@"; do
		remote=$(git rev-parse -q --verify "refs/remotes/origin/$b" || true)
		if [ -z "$remote" ] || git merge-base --is-ancestor "$remote" "$b"; then
			continue
		fi
		if ! git reflog show --format=%H "refs/heads/$b" | grep -qx "$remote"; then
			echo "origin/$b"
		fi
	done
	oldest=$(git rev-list --reverse "$base..HEAD" | head -n 1)
	if [ -n "$oldest" ]; then
		git for-each-ref --format='%(refname:short)' --contains "$oldest" --no-merged HEAD refs/heads/
	fi
}

worktree_of() {
	git worktree list --porcelain |
		awk -v ref="branch refs/heads/$1" '/^worktree /{w = substr($0, 10)} $0 == ref {print w}'
}

# Commits in $1 the stack lacks: not reachable from the other arguments and not patch-equivalent
# to a commit in HEAD.
missing() {
	from=$1
	shift
	unapplied=$(git cherry HEAD "$from" | sed -n 's/^+ //p')
	git rev-list --reverse --no-merges "$from" --not "$@" | grep -Fx -e "$unapplied" | tr '\n' ' ' || true
}

# --force-if-includes only lets stack-push replace a remote tip that appears in the layer's
# reflog, so record it there and put the layer back where it was.
record() {
	tip=$(git rev-parse "refs/heads/$1")
	git update-ref -m "stack-$cmd: integrated $3" "refs/heads/$1" "$2"
	git update-ref -m "stack-$cmd: back on the stack" "refs/heads/$1" "$tip"
}

# Refuse anything that would flatten history or leave a layer pointing at the old commits.
guard() {
	if [ -n "$(git rev-list --merges "$base..HEAD")" ]; then
		die "merge commits between $base and HEAD; a rebase would flatten them"
	fi
	above=$(git for-each-ref --format='%(refname:short)' --contains HEAD --no-merged HEAD refs/heads/)
	if [ -n "$above" ]; then
		die "layers sit above HEAD; switch to the top first:" $above
	fi
	current=$(git branch --show-current)
	for b in $(layers); do
		if [ "$b" = "$current" ]; then
			continue
		fi
		worktree=$(worktree_of "$b")
		if [ -n "$worktree" ]; then
			die "$b is checked out in $worktree, so a rebase would skip it; run: git -C \"$worktree\" switch --detach"
		fi
	done
}

# Every rewrite moves the layers further from a stray, so adopt strays before rewriting.
settled() {
	guard
	missing=$(strays $(layers))
	if [ -n "$missing" ]; then
		die "adopt these first or the rebase leaves their commits behind:" $missing
	fi
}

status() {
	stack=$(layers)
	prev=$base
	for b in $stack; do
		count=$(git rev-list --count "$prev..$b")
		if [ "$count" -eq 0 ]; then
			printf '%-48s same commit as %s\n' "$b" "$prev"
		else
			size=$(git diff --numstat "$prev" "$b" | awk '{a += $1; d += $2} END {printf "+%d -%d", a, d}')
			printf '%-48s %4d commits  %s\n' "$b" "$count" "$size"
		fi
		prev=$b
	done
	for s in $(strays $stack); do
		printf '! %s has commits the stack is missing; run: git stack-adopt %s\n' "$s" "$s"
	done
}

restack() {
	if [ $# -ne 1 ]; then
		die "usage: git stack-restack <base> (stack.base is $base)"
	fi
	old=$base
	base=$1
	if [ "$base" = "$(git branch --show-current)" ]; then
		die "$base is checked out; pass the branch the stack sits on"
	fi
	if ! git show-ref -q --verify "refs/heads/$base"; then
		die "no local branch $base"
	fi
	# Fetch before any check: a stale local base still lacks the old base's merge, so it would
	# show the old base's history as part of the stack.
	git fetch origin
	if ! git show-ref -q --verify "refs/remotes/origin/$base"; then
		die "origin has no branch $base"
	fi
	# git fetch refuses to write a branch checked out in any worktree, even with no change.
	local_base=$(git rev-parse "refs/heads/$base")
	origin_base=$(git rev-parse "refs/remotes/origin/$base")
	if [ "$local_base" != "$origin_base" ]; then
		if ! git merge-base --is-ancestor "$local_base" "$origin_base"; then
			die "$base has commits origin/$base lacks; push $base first"
		fi
		worktree=$(worktree_of "$base")
		if [ -n "$worktree" ]; then
			die "$base is checked out in $worktree, so fast-forward it there: git -C \"$worktree\" merge --ff-only origin/$base"
		fi
		git fetch -q . "refs/remotes/origin/$base:refs/heads/$base" ||
			die "could not fast-forward $base to origin/$base"
	fi
	# The origin copy stands in once the old base is deleted locally. Full refs, because a tag
	# with the same name would make a short name mean the tag.
	old_ref=$(git rev-parse -q --verify "refs/heads/$old" || git rev-parse -q --verify "refs/remotes/origin/$old" || true)
	if [ -n "$old_ref" ] && git merge-base --is-ancestor "$old_ref" HEAD &&
		! git merge-base --is-ancestor "$old_ref" "refs/heads/$base"; then
		die "$old is not merged into $base yet, so the rebase would rewrite its commits into the stack and stack-push would force-push them; restack onto $old until it merges. If $old is one of your own layers, run: git config stack.base $base"
	fi
	guard
	# Merging a PR in a GitHub stack rebases the open PRs above it onto the merge. Those copies
	# hold nothing new once $base is counted, so adopt them here; real new commits still stop below.
	for stray in $(strays $(layers)); do
		layer=${stray#origin/}
		if [ "$layer" = "$stray" ]; then
			continue
		fi
		if [ -z "$(missing "$stray" HEAD "refs/heads/$base" $(git reflog show --format=%H "refs/heads/$layer"))" ]; then
			record "$layer" "$(git rev-parse "$stray")" "$stray"
			echo "stack: adopted $stray, which only changed SHAs"
		fi
	done
	settled
	if git rebase --update-refs "$base"; then
		git config stack.base "$base"
	elif [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; then
		# Saved now so the other commands already use the new base while you resolve.
		git config stack.base "$base"
		die "resolve, then git rebase --continue; to back out: git rebase --abort && git config stack.base $old"
	else
		die "the rebase did not start, so stack.base is still $old"
	fi
	status
}

push() {
	stack=$(layers)
	if [ -z "$stack" ]; then
		die "no layers between $base and HEAD"
	fi
	git push -u --atomic --force-with-lease --force-if-includes "$@" origin $stack
}

fixup() {
	if [ $# -ne 1 ]; then
		die "usage: git stack-fixup <layer>"
	fi
	if ! layers | grep -qxF "$1"; then
		die "$1 is not a layer between $base and HEAD"
	fi
	settled
	# A SHA rather than the subject, because the stack repeats subjects like "chore: migration".
	git commit -m "fixup! $(git rev-parse "$1")"
	git rebase --update-refs --autosquash "$base"
}

absorb() {
	if ! command -v git-absorb >/dev/null; then
		die "git-absorb is not installed: brew install git-absorb"
	fi
	if [ "$(git config --type=bool absorb.fixupTargetAlwaysSHA || echo false)" != true ]; then
		die "run: git config --global absorb.fixupTargetAlwaysSHA true (repeated subjects send fixups to the wrong commit)"
	fi
	settled
	git absorb --base "$base" --force-author --and-rebase "$@" -- --update-refs
}

adopt() {
	if [ $# -ne 1 ]; then
		die "usage: git stack-adopt <branch | origin/branch>"
	fi
	rev=$(git rev-parse --verify "$1^{commit}")
	name=${1#origin/}
	if ! git show-ref -q --verify "refs/heads/$name"; then
		die "no local branch $name"
	fi
	guard
	had=HEAD
	if [ "$name" != "$1" ]; then
		# Skip every version of the layer you have had, leaving only what a reviewer added on top.
		had="HEAD $(git reflog show --format=%H "refs/heads/$name")"
	fi
	picks=$(missing "$rev" $had)
	if [ -n "$picks" ] && [ "$name" = "$(git branch --show-current)" ]; then
		git cherry-pick --ff $picks || die "resolve, git cherry-pick --continue, then rerun: git stack-adopt $1"
	elif [ -n "$picks" ]; then
		if layers | grep -qxF "$name"; then
			anchor=$(git rev-parse "$name")
		else
			anchor=$(git merge-base "$rev" HEAD)
			if git merge-base --is-ancestor "$anchor" "$base"; then
				die "$1 did not fork from a layer"
			fi
		fi
		STACK_ANCHOR=$anchor STACK_LAYER=$name STACK_PICKS=$picks GIT_SEQUENCE_EDITOR="sh '$0' _insert" \
			git rebase -i --update-refs "$base" ||
			die "resolve, git rebase --continue, then rerun: git stack-adopt $1"
	fi
	if git merge-base --is-ancestor "$rev" "$name" || git reflog show --format=%H "refs/heads/$name" | grep -qx "$rev"; then
		if [ -z "$picks" ]; then
			die "the stack already has everything in $1"
		fi
		return
	fi
	record "$name" "$rev" "$1"
	echo "stack: $name now carries the commits from $1"
}

# Sequence editor for adopt: put the picks and the layer's ref right after the anchor commit.
# They go after the anchor's own update-ref lines too, or the layer the branch forked from would
# move up onto the adopted commits.
_insert() {
	awk -v anchor="$STACK_ANCHOR" -v ref="update-ref refs/heads/$STACK_LAYER" -v picks="$STACK_PICKS" '
		function flush() {
			n = split(picks, p, " ")
			for (i = 1; i <= n; i++) print "pick " p[i]
			print ref
			pending = 0
		}
		$0 == ref { next }
		pending && $1 != "update-ref" { flush() }
		{ print }
		$1 == "pick" && length($2) >= 7 && index(anchor, $2) == 1 {
			pending = 1
			found = 1
		}
		END {
			if (pending) flush()
			if (!found) exit 1
		}
	' "$1" >"$1.new"
	mv "$1.new" "$1"
}

cmd=${1:-status}
if [ $# -gt 0 ]; then
	shift
fi
case $cmd in
status | restack | push | fixup | absorb | adopt | _insert) "$cmd" "$@" ;;
*) die "unknown command: $cmd" ;;
esac
