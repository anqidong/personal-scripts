#!/usr/bin/env python3
"""Extract /btw messages from input history that aren't in session transcripts.

Outputs JSON lines: one object per orphaned /btw entry with
{display, timestamp, sessionId, project, content, orphaned: true}.

Usage:
    extract_btw.py [--since YYYY-MM-DD] [--session ID] [--history PATH]
"""

import json, sys, argparse, re
from pathlib import Path
from datetime import datetime, timezone


def find_session_file(session_id):
    """Locate the session transcript JSONL under ~/.claude/projects/."""
    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        return None
    for match in projects_dir.rglob(f"{session_id}.jsonl"):
        return match
    return None


def content_in_transcript(content, session_file):
    """Check whether the first 60 chars of content appear in the transcript."""
    search_key = content[:60]
    if not search_key:
        return False
    try:
        text = session_file.read_text(errors="replace")
        return search_key in text
    except OSError:
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--since", help="Start date (YYYY-MM-DD)")
    parser.add_argument("--session", help="Filter to a specific session ID")
    parser.add_argument(
        "--history",
        default=Path.home() / ".claude" / "history.jsonl",
        type=Path,
        help="Path to history.jsonl",
    )
    args = parser.parse_args()

    if not args.history.exists():
        print(f"History file not found: {args.history}", file=sys.stderr)
        sys.exit(1)

    since_ts = None
    if args.since:
        since_dt = datetime.strptime(args.since, "%Y-%m-%d").replace(tzinfo=timezone.utc)
        since_ts = int(since_dt.timestamp() * 1000)

    btw_re = re.compile(r"^/btw\s+", re.IGNORECASE)

    # Cache session file lookups.
    transcript_cache = {}

    with open(args.history) as f:
        for raw in f:
            try:
                entry = json.loads(raw)
            except json.JSONDecodeError:
                continue

            display = entry.get("display", "")
            if not btw_re.match(display):
                continue

            sid = entry.get("sessionId", "")
            if args.session and sid != args.session:
                continue

            ts = entry.get("timestamp", 0)
            if since_ts and ts < since_ts:
                continue

            content = btw_re.sub("", display)

            # Check if it made it into the transcript.
            if sid not in transcript_cache:
                transcript_cache[sid] = find_session_file(sid)

            session_file = transcript_cache[sid]
            if session_file and content_in_transcript(content, session_file):
                continue

            result = {
                "content": content,
                "timestamp": ts,
                "sessionId": sid,
                "project": entry.get("project", ""),
                "orphaned": True,
            }
            print(json.dumps(result))


if __name__ == "__main__":
    main()
