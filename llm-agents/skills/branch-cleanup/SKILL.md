# Review and delete merged local branches

Review and delete local branches whose work has landed in the main branch.

## Steps

### 1. Fetch and collect branch state

```bash
git fetch --prune
BASE=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
git branch -v
git branch --merged origin/$BASE
```

Tell the user the detected base branch (e.g. "Using `origin/main` as base").

All merge checks below use `origin/$BASE` directly — do not move HEAD. If HEAD happens to be on a branch under review, that's fine: `git branch --merged origin/$BASE` evaluates ancestry against the remote tip regardless of where HEAD points.

[CHECKPOINT] Confirm with the user that the correct origin and branch are being used.

### 2. Classify all local branches

For each local branch, assign it to one of these tiers. **Classify in order — the first matching tier wins.** Tier 1 catches anything whose tip is already an ancestor of the base; Tiers 2–5 are for branches whose tip diverged (different SHA, typically because work was rebased or squashed on the way in).

**Tier 1 — Tip is an ancestor of base** (`git branch --merged origin/$BASE`)
The branch tip is a reachable ancestor of `origin/$BASE`. Covers two sub-cases that git alone can't fully distinguish:

- **Tier 1A — Merged work.** The branch had unique commits that landed via fast-forward or a merge commit that preserved the tip SHA. Safe to delete.
- **Tier 1B — Likely placeholder.** The branch was probably created with `git checkout -b` and never committed to. The tip is whatever commit HEAD happened to be at, typically a few commits behind `origin/$BASE` HEAD. These are often reminders to implement something later, or scratch space another agent is using for analysis.

Tells for 1B (not conclusive, but strong signals when combined):
- Tip commit author isn't the user (it's some arbitrary commit on main by someone else).
- Branch name has no lexical overlap with the tip commit's subject.
- Tip sits noticeably behind `origin/$BASE` HEAD.

Present 1A and 1B separately. Default 1A to safe-to-delete; for 1B, list each branch with name, tip subject, tip author, and how far behind base, and ask explicitly before deleting.

**Tier 2 — Remote gone, tip message in log**
Branch shows `[gone]` and the tip commit message appears in `git log origin/$BASE --oneline` (possibly with a different hash due to rebase). Show the matching log commit so the user can verify. Note if the message match is imprecise (e.g. different Jira ticket prefix). Then verify content matches — see "Verifying patch content" below.

**Tier 3 — Remote gone, tip message NOT in log**
Branch shows `[gone]` but no message match found. Flag for manual review.

**Tier 4 — No remote tracking, tip message in log**
Branch was never pushed (or remote ref already removed), but content landed. Show matching commit. Then verify content matches — see "Verifying patch content" below.

**Tier 5 — No remote tracking, tip message NOT in log**
May be WIP or abandoned local work. List with last commit message for the user to decide.

**Tier 6 — Active remote with local work**
Shows `[ahead N]` or `[ahead N, behind M]`. Keep — do not include in deletion prompts.

#### Verifying patch content (Tiers 2 and 4)

A subject-line match isn't proof — verify the patch content before promoting a branch into the safe-to-delete group.

**Single-commit branch (the easy case):** compare the patches directly. This is eyeball-friendly and easy to reproduce manually:

```bash
diff <(git show <local_tip>) <(git show <landed>)
```

The output should be just cosmetic noise: differing commit hashes, parent blob hashes (`index abc..def`), and possibly hunk-header line numbers (`@@ -88` vs `@@ -91`) when the upstream was rebased onto a slightly newer parent. If `+`/`-` lines differ, the patches diverged — kick to manual review.

**Multi-commit branch:** comparing `git show <tip>` on each side only checks the top commit and silently skips the rest. Use `git cherry` instead, which compares each local commit against upstream by patch-id (ignores SHA drift, line numbers, and metadata):

```bash
git cherry origin/$BASE <local_tip>
```

One line per local commit. `-` prefix means the patch-id is already upstream (landed); `+` means it isn't. If every line is `-` (or output is empty), the branch's work is fully landed.

`git cherry` covers both fast-forward and rebase-and-fast-forward, which is the common shape here. **Squash merges** are the exception: a squash combines N original patches into one new patch with a fresh patch-id, so `git cherry` will report `+` for every local commit even though the work landed. When you've subject-matched a known squash commit, fall back to comparing cumulative diffs:

```bash
MB=$(git merge-base <local_tip> origin/$BASE)
diff <(git diff $MB..<local_tip>) <(git diff <squash>^..<squash>)
```

Using `git diff` on both sides keeps the comparison symmetric — neither side carries a commit-message preamble, so the only differences should be blob hashes and hunk-header line numbers.

**Sandbox prompt fatigue (open question).** If your environment runs commands through a sandbox that prompts for approval per subshell, verifying many branches in a row with `<(...)` process substitution can get cumbersome. There's no known-good fix yet — `mktemp -d` paths under `/tmp` may not dodge prompts either, since the sandbox likely treats `/tmp` writes the same regardless of who created the path. Options worth trying, in order of plausibility — ask the user which they'd like to attempt before applying:

- Stick with `<(...)` and accept the prompts. Fine for a handful of branches.
- Try `mktemp -d` and `diff` once, accepting that the sandbox may still prompt.
- Try a ramdisk if the system has one set up (very uncertain; platform-dependent).

For the `mktemp` form:

```bash
SCRATCH=$(mktemp -d)
git show <local_tip>  > $SCRATCH/local.patch
git show <landed>     > $SCRATCH/landed.patch
diff $SCRATCH/local.patch $SCRATCH/landed.patch
```

### 3. Present groups and checkpoint

Present each tier as a table with branch name, tip hash, and evidence (matching log commit).
Ask: "Delete all N in this group?"

Present tiers 1A and 2 together if both present (highest confidence). Present 1B on its own with the placeholder framing and the per-branch detail (tip subject, author, distance behind base). Present tiers 3 and 5 separately since they need more scrutiny. Skip tier 6 entirely.

[CHECKPOINT] Wait for confirmation on each group before deleting.

### 4. Delete confirmed branches

Prefer `git branch -d` (safe; refuses unless the tip is merged into its
upstream or HEAD) and only fall back to `-D` for branches git refuses to
delete that way. Rebased branches fall into this category — their content
landed but the local tip isn't a literal ancestor of the base. Apply `-D`
only to the branches `-d` refused, not the whole set.

```bash
git branch -d <branch1> <branch2> ...
# for any that -d refused (rebased branches whose content is verified merged):
git branch -D <refused1> <refused2> ...
```
