#!/usr/bin/env python3
"""Archive a Codex turn's transcript and final response in .cherry."""

from __future__ import annotations

import fcntl
import json
import os
import shutil
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo


TIMEZONE = ZoneInfo("Africa/Addis_Ababa")


def find_repo_root(cwd: str) -> Path | None:
    current = Path(cwd).resolve()
    for candidate in (current, *current.parents):
        if (candidate / ".git").exists():
            return candidate
    # For non-Git Codex workspaces, archive at the session's working directory.
    return current if current.is_dir() else None


def extract_text(value: object) -> str:
    if isinstance(value, str):
        return value
    if isinstance(value, list):
        return "".join(extract_text(part) for part in value)
    if isinstance(value, dict):
        if isinstance(value.get("text"), str):
            return value["text"]
        return "".join(extract_text(part) for key, part in value.items() if key in {"content", "parts"})
    return ""


def collect_messages(value: object, messages: list[tuple[str, str]]) -> None:
    if isinstance(value, dict):
        role = value.get("role")
        if role in {"user", "assistant"} and "content" in value:
            text = extract_text(value["content"]).strip()
            if text:
                messages.append((role, text))
        for child in value.values():
            collect_messages(child, messages)
    elif isinstance(value, list):
        for child in value:
            collect_messages(child, messages)


def load_transcript(path: Path) -> tuple[list[tuple[str, str]], str]:
    messages: list[tuple[str, str]] = []
    raw = path.read_text(encoding="utf-8", errors="replace")
    for line in raw.splitlines():
        try:
            collect_messages(json.loads(line), messages)
        except json.JSONDecodeError:
            continue
    return messages, raw


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as temp:
        temp.write(content)
        temp_path = Path(temp.name)
    os.replace(temp_path, path)


def get_archive_timestamp(root: Path, session_id: str) -> str:
    index_path = root / ".cherry" / ".codex_archive_sessions.json"
    lock_path = root / ".cherry" / ".codex_archive_sessions.lock"
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    with lock_path.open("a+", encoding="utf-8") as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        try:
            index = json.loads(index_path.read_text(encoding="utf-8")) if index_path.exists() else {}
        except json.JSONDecodeError:
            index = {}
        timestamp = index.get(session_id)
        if not isinstance(timestamp, str):
            timestamp = datetime.now(TIMEZONE).strftime("%Y-%m-%d_%H-%M-%S")
            index[session_id] = timestamp
            atomic_write(index_path, json.dumps(index, indent=2, sort_keys=True) + "\n")
        return timestamp


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        print(json.dumps({"systemMessage": "Could not read Codex archive hook input."}))
        return 0

    root = find_repo_root(str(event.get("cwd") or os.getcwd()))
    session_id = event.get("session_id")
    transcript_path = event.get("transcript_path")
    if root is None or not isinstance(session_id, str) or not session_id:
        print("{}")
        return 0

    timestamp = get_archive_timestamp(root, session_id)
    transcript = Path(transcript_path) if isinstance(transcript_path, str) else None
    messages: list[tuple[str, str]] = []
    if transcript and transcript.is_file():
        messages, raw_transcript = load_transcript(transcript)
        # Keep the original event stream as a faithful fallback if the release
        # changes the transcript structure beyond this Markdown renderer.
        atomic_write(root / ".cherry" / "chats" / f"chat_{timestamp}.jsonl", raw_transcript)

    chat_lines = [f"# Chat transcript — {timestamp} Africa/Addis_Ababa", ""]
    if messages:
        for role, text in messages:
            chat_lines.extend([f"## {role.title()}", "", text, ""])
    elif transcript:
        chat_lines.extend([
            "The transcript format could not be rendered as Markdown. The complete raw transcript is saved alongside this file as JSONL.",
            "",
        ])
    atomic_write(root / ".cherry" / "chats" / f"chat_{timestamp}.md", "\n".join(chat_lines))

    final_message = event.get("last_assistant_message")
    if isinstance(final_message, str) and final_message.strip():
        report = (
            f"# Session report — {timestamp} Africa/Addis_Ababa\n\n"
            f"Session: `{session_id}`\n\n"
            f"{final_message.strip()}\n"
        )
        atomic_write(root / ".cherry" / "sessions" / f"report_{timestamp}.md", report)

    print("{}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
