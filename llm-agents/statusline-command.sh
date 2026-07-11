#!/bin/bash
# Claude Code status line.
# Left: CWD + git branch (dirty-state colored)
# Right: model + effort + context window token count
input=$(cat)

dir=$(echo "$input" | jq -r '.cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

RST='\033[0m'

# --- Left side: CWD + git branch ---

cwd="${dir/#$HOME/~}"

left=$(printf '\033[38;5;30m%s%s' "$cwd" "$RST")

if [ -n "$dir" ] && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null ||
           git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  if [ -n "$branch" ]; then
    if ! git -C "$dir" --no-optional-locks diff-files --quiet --ignore-submodules 2>/dev/null; then
      bc='\033[38;5;124m'  # dark red: unstaged changes
    elif ! git -C "$dir" --no-optional-locks diff-index --quiet --ignore-submodules --cached HEAD 2>/dev/null; then
      bc='\033[38;5;130m'  # dark yellow/amber: staged changes
    else
      bc='\033[38;5;28m'   # dark green: clean
    fi
    left="${left}$(printf '\033[2m:%s%b%s%s' "$RST" "$bc" "$branch" "$RST")"
  fi
fi

# --- Right side: model + effort + tokens + cost ---

COL_MODEL='\033[38;5;25m'   # dark blue
COL_EFFORT='\033[38;5;22m'  # forest green
COL_TOKENS='\033[38;5;130m' # brown
COL_COST='\033[38;5;22m'    # forest green

right=""

if [ -n "$model" ]; then
  right=$(printf '%b%s%s' "$COL_MODEL" "$model" "$RST")
fi

if [ -n "$effort" ] && [ "$effort" != "null" ]; then
  right="${right} $(printf '%b[%s]%s' "$COL_EFFORT" "$effort" "$RST")"
fi

right="${right}        "

if [ -n "$total_input" ] && [ "$total_input" != "null" ]; then
  token_display=$(awk -v t="$total_input" -v p="${used_pct:-}" '
    function fmt(n) {
      n = int(n)
      s = ""
      while (n >= 1000) { s = sprintf(" %03d%s", n % 1000, s); n = int(n / 1000) }
      return n s
    }
    BEGIN {
      printf "%s tokens", fmt(t)
      if (p != "" && p != "null") printf " (%s%%)", int(p)
    }')
  right="${right} $(printf '%b%s%s' "$COL_TOKENS" "$token_display" "$RST")"
fi

if [ -n "$cost" ] && [ "$cost" != "null" ]; then
  cost_display=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')
  right="${right} $(printf '%b%s%s' "$COL_COST" "$cost_display" "$RST")"
fi

printf "%b  %b" "$left" "$right"
