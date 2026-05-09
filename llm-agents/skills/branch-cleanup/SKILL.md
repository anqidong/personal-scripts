# Review and delete merged local branches

Review and delete local branches whose work has landed in the main branch.

## Steps

### 1. Fetch and collect branch state

```bash
git fetch --prune
BASE=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
git checkout origin/$BASE --detach 2>/dev/null || true  # ensure HEAD is at remote tip
git branch -v
git branch --merged HEAD
```

Tell the user the detected base branch (e.g. "Using `origin/main` as base").

If HEAD is not at `origin/$BASE`, note it and proceed anyway using `origin/$BASE` explicitly for merge checks.

[CHECKPOINT] Confirm with the user that the correct origin and branch are being used.

### 2. Classify all local branches

For each local branch, assign it to one of these tiers:

**Tier 1 — Exact hash merged** (`git branch --merged HEAD` or `git branch --merged origin/$BASE`)
The branch tip is a reachable ancestor of the base. Safe to delete.

**Tier 2 — Remote gone, tip message in log**
Branch shows `[gone]` and the tip commit message appears in `git log origin/$BASE --oneline` (possibly with a different hash due to rebase). Show the matching log commit so the user can verify. Note if the message match is imprecise (e.g. different Jira ticket prefix).

**Tier 3 — Remote gone, tip message NOT in log**
Branch shows `[gone]` but no message match found. Flag for manual review.

**Tier 4 — No remote tracking, tip message in log**
Branch was never pushed (or remote ref already removed), but content landed. Show matching commit.

**Tier 5 — No remote tracking, tip message NOT in log**
May be WIP or abandoned local work. List with last commit message for the user to decide.

**Tier 6 — Active remote with local work**
Shows `[ahead N]` or `[ahead N, behind M]`. Keep — do not include in deletion prompts.

### 3. Present groups and checkpoint

Present each tier as a table with branch name, tip hash, and evidence (matching log commit).
Ask: "Delete all N in this group?"

Present tiers 1 and 2 together if both present (highest confidence). Present tiers 3 and 5 separately since they need more scrutiny. Skip tier 6 entirely.

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
