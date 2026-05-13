# LLM agent skills

Coding agent instructions and custom skills. Only tested with Claude Code.

## Setup for Claude Code

1. **Import `AGENTS.md` from your global `CLAUDE.md`** using Claude Code's
   `@`-import syntax (resolved recursively at session start, max depth 5):

   ```markdown
   @~/git/personal-scripts/llm-agents/AGENTS.md
   ```

   Save this at `~/.claude/CLAUDE.md`. Claude Code shows a one-time approval
   dialog the first time it sees external imports. Additional AGENTS.md files
   from sibling repos can be imported the same way if needed.

2. **Symlink the skills folder** into `~/.claude/` so every skill here is
   available as a top-level slash command, and new ones appear automatically:

   ```bash
   ln -sfn ~/git/personal-scripts/llm-agents/skills ~/.claude/skills
   ```

   `-n` is important: without it, if `~/.claude/skills` already exists as a
   directory, `ln -sf` will create the link *inside* it instead of replacing
   it.
