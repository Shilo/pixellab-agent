#!/usr/bin/env python3
"""PixelLab Pip bark helper.

This helper is intentionally small and dependency-free. It keeps the bark
configuration portable with the skill first, then falls back to a user config
directory only when the installed skill directory is not writable.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import wave
from pathlib import Path
from typing import Any


ASSETS_DIR = Path(__file__).resolve().parent
SKILL_DIR = ASSETS_DIR.parent
SKILL_CONFIG = SKILL_DIR / "pixellab-pip.json"
BARK_WAV = ASSETS_DIR / "bark.wav"


def user_config_path() -> Path:
    system = platform.system().lower()
    home = Path.home()

    if system == "windows":
        root = os.environ.get("APPDATA")
        base = Path(root) if root else home / "AppData" / "Roaming"
    elif system == "darwin":
        base = home / "Library" / "Application Support"
    else:
        root = os.environ.get("XDG_CONFIG_HOME")
        base = Path(root) if root else home / ".config"

    return base / "pixellab-pip" / "pixellab-pip.json"


USER_CONFIG = user_config_path()


def read_json(path: Path) -> dict[str, Any] | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def normalize_bark(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    return True


def read_config() -> tuple[dict[str, Any], Path | None]:
    invalid_source: Path | None = None
    for path in (SKILL_CONFIG, USER_CONFIG):
        if path.exists():
            data = read_json(path)
            if isinstance(data, dict):
                return data, path
            if invalid_source is None:
                invalid_source = path
    return {"bark": True}, invalid_source


def bark_enabled() -> bool:
    data, _ = read_config()
    return normalize_bark(data.get("bark", True))


def write_config(enabled: bool) -> Path:
    existing, source = read_config()
    existing["bark"] = bool(enabled)
    content = json.dumps(existing, indent=2, sort_keys=True) + "\n"

    candidates = []
    if source == USER_CONFIG:
        candidates.append(USER_CONFIG)
        candidates.append(SKILL_CONFIG)
    else:
        candidates.append(SKILL_CONFIG)
        candidates.append(USER_CONFIG)

    errors: list[str] = []
    for path in candidates:
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
            return path
        except OSError as exc:
            errors.append(f"{path}: {exc}")

    raise RuntimeError("; ".join(errors) or "could not write config")


def playable_wav(path: Path) -> bool:
    try:
        with wave.open(str(path), "rb"):
            return True
    except (OSError, wave.Error):
        return False


def play_sound() -> bool:
    if not BARK_WAV.exists() or not playable_wav(BARK_WAV):
        return False

    system = platform.system().lower()

    if system == "windows":
        try:
            import winsound

            winsound.PlaySound(str(BARK_WAV), winsound.SND_FILENAME)
            return True
        except Exception:
            return False

    commands = []
    if system == "darwin":
        commands.append(["afplay", str(BARK_WAV)])
    else:
        commands.extend(
            [
                ["paplay", str(BARK_WAV)],
                ["pw-play", str(BARK_WAV)],
                ["aplay", "-q", str(BARK_WAV)],
                ["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", str(BARK_WAV)],
            ]
        )

    for command in commands:
        if shutil.which(command[0]) is None:
            continue
        try:
            completed = subprocess.run(
                command,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
                timeout=3,
            )
            if completed.returncode == 0:
                return True
        except (OSError, subprocess.TimeoutExpired):
            continue

    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="PixelLab Pip bark helper")
    parser.add_argument("command", choices=["status", "toggle", "on", "off", "play"])
    parser.add_argument("--json", action="store_true", help="print machine-readable output")
    args = parser.parse_args()

    result: dict[str, Any] = {
        "ok": True,
        "bark": bark_enabled(),
        "config": None,
        "played": False,
        "sound": str(BARK_WAV),
    }

    try:
        if args.command == "toggle":
            result["bark"] = not bark_enabled()
            result["config"] = str(write_config(bool(result["bark"])))
            if result["bark"]:
                result["played"] = play_sound()
        elif args.command == "on":
            result["bark"] = True
            result["config"] = str(write_config(True))
            result["played"] = play_sound()
        elif args.command == "off":
            result["bark"] = False
            result["config"] = str(write_config(False))
        elif args.command == "play":
            if bark_enabled():
                result["played"] = play_sound()
            result["bark"] = bark_enabled()
        elif args.command == "status":
            data, source = read_config()
            result["bark"] = normalize_bark(data.get("bark", True))
            result["config"] = str(source) if source else None
    except Exception as exc:
        result["ok"] = False
        result["error"] = str(exc)

    if args.json:
        print(json.dumps(result, sort_keys=True))
    else:
        if args.command in {"toggle", "on", "off"} and result["ok"]:
            print("Bark is on." if result["bark"] else "Bark is off.")
        elif args.command == "status":
            print("on" if result["bark"] else "off")
        elif args.command == "play" and result["ok"] and result["bark"] and not result["played"]:
            print("Bark sound did not play.")

    if not result["ok"]:
        return 1
    if args.command == "play" and result["bark"] and not result["played"]:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
