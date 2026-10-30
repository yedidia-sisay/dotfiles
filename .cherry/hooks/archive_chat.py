#!/usr/bin/env python3
"""Save Codex session transcripts and whole-chat reports independently."""

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


def load_transcript(path: Path) -> list[tuple[str, str]]:
    messages: list[tuple[str, str]] = []
    with path.open(encoding="utf-8", errors="replace") as transcript:
        for line in transcript:
            try:
                collect_messages(json.loads(line), messages)
            except json.JSONDecodeError:
                continue
    return messages


def settings_path() -> Path:
    codex_home = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
    return codex_home / "chat-archive.json"


def read_settings() -> dict[str, bool]:
    try:
        settings = json.loads(settings_path().read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        settings = {}
    if not isinstance(settings, dict):
        settings = {}
    return {
        "transcript": bool(settings.get("transcript", True)),
        "summary": bool(settings.get("summary", True)),
    }


def write_transcript(root: Path, timestamp: str, transcript: Path | None, messages: list[tuple[str, str]]) -> None:
    lines = [f"# Chat transcript — {timestamp} Africa/Addis_Ababa", ""]
    if messages:
        for role, text in messages:
            lines.extend([f"## {role.title()}", "", text, ""])
    elif transcript:
        lines.extend([
            "The transcript format could not be rendered as Markdown. The complete raw transcript is saved alongside this file as JSONL.",
            "",
        ])
    atomic_write(root / ".cherry" / "chats" / f"chat_{timestamp}.md", "\n".join(lines))
    if transcript and transcript.is_file():
        raw_path = root / ".cherry" / "chats" / f"chat_{timestamp}.jsonl"
        raw_path.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile("wb", dir=raw_path.parent, delete=False) as temp:
            with transcript.open("rb") as source:
                shutil.copyfileobj(source, temp)
            temp_path = Path(temp.name)
        os.replace(temp_path, raw_path)


def write_summary(root: Path, timestamp: str, session_id: str, messages: list[tuple[str, str]]) -> None:
    final_message = next((text for role, text in reversed(messages) if role == "assistant"), None)
    if not final_message:
        return
    report = (
        f"# Session report — {timestamp} Africa/Addis_Ababa\n\n"
        f"Session: `{session_id}`\n\n"
        f"{final_message.strip()}\n"
    )
    atomic_write(root / ".cherry" / "sessions" / f"report_{timestamp}.md", report)


def update_setting(name: str, enabled: bool) -> int:
    if name not in {"transcript", "summary"}:
        print("Choose 'transcript' or 'summary'.", file=sys.stderr)
        return 2
    path = settings_path()
    settings = read_settings()
    settings[name] = enabled
    atomic_write(path, json.dumps(settings, indent=2, sort_keys=True) + "\n")
    print(json.dumps(settings, indent=2, sort_keys=True))
    return 0


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
    args = sys.argv[1:]
    if args == ["status"]:
        print(json.dumps(read_settings(), indent=2, sort_keys=True))
        return 0
    if len(args) == 2 and args[0] in {"enable", "disable"}:
        return update_setting(args[1], args[0] == "enable")
    if len(args) != 1 or args[0] not in {"transcript", "summary"}:
        print(
            "Usage: archive_chat.py {transcript|summary} | status | enable {transcript|summary} | disable {transcript|summary}",
            file=sys.stderr,
        )
        return 2
    action = args[0]
    if not read_settings().get(action, False):
        print("{}")
        return 0

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
        messages = load_transcript(transcript)

    if action == "transcript":
        write_transcript(root, timestamp, transcript, messages)
    else:
        write_summary(root, timestamp, session_id, messages)

    print("{}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
