# Generate a work journal from conversation history

Generate a day-by-day work journal from Claude Code conversation history.

## Parameters

- **since** (optional): Start date in YYYY-MM-DD format. Default: start of the current week (Monday).
- **project** (optional): Filter to a specific project directory substring.

## Steps

### 1. Preprocess transcripts

Create a timestamped output directory: `/tmp/claude/journal/<YYYYMMDD-HHMMSS>/`.

Run the bundled preprocessing script @journal_slim_transcripts.py :

```bash
find ~/.claude/projects -name "*.jsonl" -not -path "*/subagents/*"
```

Filter to files with modification dates on or after the **since** date. Use `stat` + `awk` to filter, then pipe through `xargs` to pass as separate arguments:

```bash
find ~/.claude/projects -name "*.jsonl" -not -path "*/subagents/*" -print0 \
  | xargs -0 stat -f '%Sm %N' -t '%Y-%m-%d' \
  | awk '$1 >= "<since-date>" {print $2}' \
  | grep -v "<current-session-id>" \
  | xargs python3 <skill-dir>/journal_slim_transcripts.py --output-dir <timestamped-dir>
```

The script splits multi-day sessions at midnight boundaries, so a session that started Tuesday evening and continued Wednesday gets two manifest entries. Output lands in the timestamped directory with a `_manifest.json` index.

### 2. Fan out subagents for summarization

Group transcripts by date from the manifest. Spawn parallel subagents (use `sonnet` model), targeting ~5-6 transcripts per agent (scale agent count up as needed to cover all sessions). Each subagent should:

- Read ALL assigned slimmed transcript files — do not stop early or skip files. Use chunked reads for long files.
- Produce 2-4 bullet points per session (starting point: under 25 words each). This should be dynamic based on the length of the session: short summary for simple sessions; more bullet points for long or complex or wide-ranging sessions.
- **Name identifying details**: keep tool/framework names, bug tracker numbers, PR numbers. Drop commit hashes, file paths, and implementation details — this is a work summary, not a changelog.
- **Distinguish outcomes from investigations**: use "investigated" or "explored" for sessions that end without resolution. Do not promote hypotheses into conclusions — if the session ended with an unconfirmed theory, say "hypothesized X" or "investigated X; unresolved" rather than "identified X" or "found X."
- Label each session with its project name
- Group output by date

### 3. Collate and present

Combine all subagent summaries into a single chronological journal. Present to the user with this format:

```
## YYYY-MM-DD (Day of Week)
### project-name
- bullet
- bullet

### project-name
- bullet
```

**Day-of-week labels must be verified** using a deterministic tool call (e.g. `date -j -f '%Y-%m-%d' '<date>' '+%A'`) — do not guess or calculate them mentally.

## Notes

- The preprocessing script is critical for staying within context limits. Raw JSONL transcripts contain massive tool outputs that would overwhelm any context window.
- Sonnet is the recommended model for summarization. Haiku over-compresses and promotes hypotheses into conclusions; Opus is marginally better but ~2x slower for negligible quality gain.
- Scale agent count to keep ~5-6 transcripts per agent. For a full month (~100 sessions), that's ~16-20 agents.
- Skip the current session's transcript (it will be incomplete/in-progress).
- The user's default shell may be fish. Use `xargs` pipelines rather than bash variable expansion to pass file lists, and avoid bash-specific syntax like `[[ ]]` in inline commands.

## Known shortcomings

- **File modification date vs session date**: Files are filtered by `stat` modification date, but the actual session may have started earlier. A session started Friday that was last touched Monday will be included when filtering for Monday, but may also contain Friday/Saturday/Sunday content. The day-splitting in the script handles attribution correctly, but the initial file filter could miss sessions that started before the `since` date and continued past it, if the file was last modified before `since`.
- **Timezone handling**: JSONL timestamps are UTC. The midnight-split uses UTC date boundaries, which may not align with the user's local day boundaries. Late-night local work could be attributed to the next calendar day.
- **Project name parsing**: The project name is derived from the directory path encoding, which can produce artifacts like `foo/bar//a` for worktree-based sessions. (User uses --a suffix for worktrees.)
