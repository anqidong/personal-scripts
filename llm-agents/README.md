# LLM agent skills

Coding agent instructions and custom skills. Tested with Claude Code and Gemini
CLI.

## Setup for Claude Code

1. **Import `AGENTS.md` from your global `CLAUDE.md`** using Claude Code's
   `@`-import syntax (resolved recursively at session start, max depth 5):

   ```markdown
   @~/git/personal-scripts/llm-agents/AGENTS.md
   ```

   Save this at `~/.claude/CLAUDE.md`. Claude Code shows a one-time approval
   dialog the first time it sees external imports. Additional AGENTS.md files
   from sibling repos can be imported the same way if needed.

1. **Wire global memory recall.** Claude Code auto-loads a project's memory but
   *not* the global store at `~/.claude/memory/`. To pull the global memory
   index into every session, import it from `~/.claude/CLAUDE.md` with the same
   `@`-syntax:

   ```markdown
   @~/.claude/memory/MEMORY.md
   ```

   Only the index (`MEMORY.md`) loads; the individual memory files it links to
   are read on demand. Without this line, anything saved to global scope is
   written but never recalled. See the "Memory" section in `AGENTS.md` for the
   global-vs-project saving convention.

1. **Symlink the skills folder** into `~/.claude/` so every skill here is
   available as a top-level slash command, and new ones appear automatically:

   ```bash
   ln -sfn ~/git/personal-scripts/llm-agents/skills ~/.claude/skills
   ```

   `-n` is important: without it, if `~/.claude/skills` already exists as a
   directory, `ln -sf` will create the link *inside* it instead of replacing
   it.

1. **Allowlist ephemeral directories.** The instructions configured here
   direct Claude to use `~/.local/claude-state/` for persistent scratch
   and `/tmp/claude/` for throwaway artifacts (see the "Ephemeral state
   and caches" section in `AGENTS.md`). To avoid permission prompts, add
   these to the `permissions.allow` list in `~/.claude/settings.json`:

   ```
   Read(~/.local/claude-state/**)
   Edit(~/.local/claude-state/**)
   Read(//tmp/claude/**)
   Edit(//tmp/claude/**)
   ```

1. **Extend transcript retention.** Claude Code defaults to deleting transcripts
   after 30 days. To keep them indefinitely, set `cleanupPeriodDays` in
   `~/.claude/settings.json`:

   ```json
   "cleanupPeriodDays": 3650
   ```

## Setup for Gemini CLI

1. **Reference `AGENTS.md` from your global `GEMINI.md`**:

   Gemini CLI supports a global context file at `~/.gemini/GEMINI.md` that
   provides default instructions across all projects. It doesn't auto-load as
   aggressively as Claude Code, so we need to be more directed.

   Create or edit this file to include an explicit instruction to read your
   agent files. You can stack multiple files to combine personal and
   employer-specific rules (only include paths that actually exist on the
   machine):

   ```markdown
   # Global Gemini Instructions

   Please read and strictly adhere to the agent instructions defined in these files:
   - ~/git/personal-scripts/llm-agents/AGENTS.md
   - ~/git/work-scripts/llm-agents/AGENTS.md

   Always refer to these files for tone, guardrails, commit messages, and internal tooling guidelines.
   ```

1. **Symlink the skills folder** into `~/.gemini/` so every skill here is
   available, and new ones appear automatically:

   ```bash
   ln -sfn ~/git/personal-scripts/llm-agents/skills ~/.gemini/skills
   ```
