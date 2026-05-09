#!/usr/bin/env python3
"""Slim down Claude Code JSONL transcripts for summarization.

Keeps: user text messages, assistant text responses, tool names (not results).
Strips: tool results, progress events, file snapshots, system reminders.

Sessions spanning multiple days are split into per-day segments so work is
attributed to the day it actually happened.
"""

import json, sys, os, argparse
from pathlib import Path
from collections import defaultdict

def extract_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        texts = []
        for item in content:
            if isinstance(item, dict):
                if item.get("type") == "text":
                    text = item.get("text", "")
                    if "<system-reminder>" in text:
                        continue
                    if len(text) > 500:
                        text = text[:500] + "...[truncated]"
                    texts.append(text)
                elif item.get("type") == "tool_use":
                    texts.append(f"[tool: {item.get('name', '?')}]")
        return "\n".join(texts) if texts else None
    return None

def process(filepath):
    """Parse a JSONL transcript into per-day message buckets."""
    project = None
    parts = str(filepath).split("/projects/")
    if len(parts) > 1:
        home_encoded = str(Path.home()).replace("/", "-").lstrip("-")
        project = parts[1].split("/")[0].replace(home_encoded, "~").replace("-", "/")

    # Collect messages with their timestamps
    messages = []
    with open(filepath) as f:
        for raw in f:
            try:
                obj = json.loads(raw)
            except json.JSONDecodeError:
                continue
            ts = obj.get("timestamp", "")
            date = ts[:10] if ts else None
            if obj.get("type") == "user":
                t = extract_text(obj.get("message", {}).get("content"))
                if t:
                    messages.append((date, f"USER: {t}"))
            elif obj.get("type") == "assistant":
                t = extract_text(obj.get("message", {}).get("content"))
                if t and t.strip():
                    messages.append((date, f"ASSISTANT: {t}"))

    # Group by date — messages without timestamps inherit the last known date
    by_day = defaultdict(list)
    current_date = None
    for date, text in messages:
        if date:
            current_date = date
        if current_date:
            by_day[current_date].append(text)

    return {"project": project, "days": dict(by_day)}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()
    out_dir = args.output_dir
    os.makedirs(out_dir, exist_ok=True)
    manifest = []
    for filepath in args.files:
        r = process(filepath)
        session_id = Path(filepath).stem
        for date, lines in sorted(r["days"].items()):
            if not lines:
                continue
            suffix = f"_{date}" if len(r["days"]) > 1 else ""
            out_path = os.path.join(out_dir, f"{session_id}{suffix}.txt")
            conversation = "\n\n".join(lines)
            with open(out_path, "w") as f:
                f.write(f"Project: {r['project']}\nDate: {date}\nMessages: {len(lines)}\n---\n\n{conversation}")
            manifest.append({"file": out_path, "project": r["project"], "date": date, "messages": len(lines)})
    manifest.sort(key=lambda x: x["date"] or "")
    with open(os.path.join(out_dir, "_manifest.json"), "w") as f:
        json.dump(manifest, f, indent=2)
    print(json.dumps(manifest, indent=2))

if __name__ == "__main__":
    main()
