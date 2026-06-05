#!/usr/bin/env python3
"""whisper-watch: meeting recording pipeline.

Transcribes .m4a → moves SRT to Obsidian AI/Summaries → eval-transcript
summary alongside it → ensures meeting note has front-matter, #has-voice-memo
tag, and ![[inclusion]] link.

Drop folder contains only .m4a and .mp3.
All text files (.srt, -summary.md) live in the vault under AI/Summaries.
"""

import hashlib
import json
import logging
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

SCRIPT_DIR = Path(__file__).parent.resolve()
DOTFILES_DIR = SCRIPT_DIR.parent.parent
DEFAULT_CONFIG_PATH = Path.home() / ".whisper-watch-config.json"
REQUIRED_KEYS = [
    "drop_folder",
    "obsidian_vault_root",
    "obsidian_meetings_subdir",
    "obsidian_summaries_subdir",
]
HAS_VOICE_MEMO_TAG = "has-voice-memo"

# ── Config ────────────────────────────────────────────────────────────────────

def load_config(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(
            f"Config not found: {path} — run whisper/install.sh first"
        )
    with path.open() as f:
        try:
            cfg = json.load(f)
        except json.JSONDecodeError as exc:
            raise ValueError(f"Config is not valid JSON: {exc}") from exc
    missing = [k for k in REQUIRED_KEYS if not cfg.get(k)]
    if missing:
        raise ValueError(f"Config missing required keys: {', '.join(missing)}")
    return cfg

# ── Logging ───────────────────────────────────────────────────────────────────

def setup_logging(
    log_dir: Path,
    level_name: str,
    retention_days: int,
    error_retention_days: int,
) -> tuple[logging.Logger, Path]:
    log_dir.mkdir(parents=True, exist_ok=True)
    level = getattr(logging, level_name.upper(), logging.INFO)
    log_file = log_dir / f"{datetime.now().strftime('%Y%m%d')}.txt"
    error_log = log_dir / "errors.log"
    fmt = logging.Formatter(
        "[%(asctime)s] [%(levelname)-5s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    logger = logging.getLogger("whisper_watch")
    logger.setLevel(logging.DEBUG)
    for h in logger.handlers[:]:
        h.close()
        logger.removeHandler(h)

    fh = logging.FileHandler(log_file, encoding="utf-8")
    fh.setLevel(level)
    fh.setFormatter(fmt)
    logger.addHandler(fh)

    eh = logging.FileHandler(error_log, encoding="utf-8")
    eh.setLevel(logging.ERROR)
    eh.setFormatter(fmt)
    logger.addHandler(eh)

    if sys.stderr.isatty():
        ch = logging.StreamHandler()
        ch.setLevel(level)
        ch.setFormatter(fmt)
        logger.addHandler(ch)

    _rotate_logs(log_dir, retention_days, error_retention_days)
    return logger, log_file


def _rotate_logs(log_dir: Path, retention_days: int, error_retention_days: int) -> None:
    cutoff = datetime.now() - timedelta(days=retention_days)
    for f in log_dir.glob("????????.txt"):
        try:
            if datetime.strptime(f.stem, "%Y%m%d") < cutoff:
                f.unlink()
        except ValueError:
            pass
    error_log = log_dir / "errors.log"
    if error_log.exists():
        age = (datetime.now() - datetime.fromtimestamp(error_log.stat().st_mtime)).days
        if age > error_retention_days:
            error_log.write_text("", encoding="utf-8")

# ── Front-matter ──────────────────────────────────────────────────────────────

_FM_RE = re.compile(r"^---[ \t]*\n(.*?)\n---[ \t]*\n", re.DOTALL)


def has_frontmatter(text: str) -> bool:
    return bool(_FM_RE.match(text))


def get_frontmatter_value(text: str, key: str) -> Optional[str]:
    m = _FM_RE.match(text)
    if not m:
        return None
    for line in m.group(1).splitlines():
        if re.match(rf"^{re.escape(key)}\s*:", line):
            _, _, v = line.partition(":")
            return v.strip()
    return None


def remove_frontmatter_key(text: str, key: str) -> str:
    """Remove all lines matching `key:` from front-matter. Body is never touched.

    If the key is the only item in front-matter, the result has empty (but valid)
    front-matter `---\\n---\\n`. Never produces an empty string on non-empty input.
    """
    m = _FM_RE.match(text)
    if not m:
        return text
    kept = [
        ln for ln in m.group(1).splitlines()
        if not re.match(rf"^{re.escape(key)}\s*:", ln)
    ]
    fm_body = "\n".join(kept)
    return f"---\n{fm_body}\n---\n{text[m.end():]}"


def ensure_frontmatter(text: str) -> str:
    """Prepend empty front-matter block if none present.

    Uses `---\\n\\n---\\n\\n` (blank line between delimiters) so that _FM_RE,
    which requires `\\n` immediately before the closing `---`, can parse it.
    `---\\n---\\n` (no blank line) is NOT parseable by _FM_RE.
    """
    if has_frontmatter(text):
        return text
    return f"---\n\n---\n\n{text}"


def _tag_present(fm_text: str, tag: str) -> bool:
    """True if tag is present as a standalone YAML value — not as a substring.

    Handles:
    - List item form: "  - tagname"
    - Inline value:   "tags: tagname"
    - Flow sequence:  "tags: [tagname, other]"
    """
    for line in fm_text.splitlines():
        stripped = line.strip()
        # List item: "- tagname" (with optional extra spaces handled by strip)
        if re.match(rf"^-\s+{re.escape(tag)}\s*$", stripped):
            return True
        # Inline scalar or flow sequence on the tags: line
        if re.match(r"^tags\s*:", stripped):
            value = re.sub(r"^tags\s*:\s*", "", stripped)
            tokens = re.split(r"[\s,\[\]]+", value)
            if tag in tokens:
                return True
    return False


def ensure_tag(text: str, tag: str) -> str:
    """Add tag to the front-matter tags list if not already present.

    Uses _tag_present for precise matching — never matches a tag that merely
    contains the target as a substring (e.g., 'not-has-voice-memo').
    """
    m = _FM_RE.match(text)
    if not m:
        return text
    fm = m.group(1)
    body = text[m.end():]

    if _tag_present(fm, tag):
        return text

    # Find existing `tags:` line with no inline value (array form)
    tags_blank = re.search(r"^(tags\s*:)([ \t]*)$", fm, re.MULTILINE)
    if tags_blank:
        insert_pos = tags_blank.end()
        new_fm = fm[:insert_pos] + f"\n  - {tag}" + fm[insert_pos:]
    else:
        new_fm = fm + f"\ntags:\n  - {tag}"

    return f"---\n{new_fm}\n---\n{body}"

# ── Safe file operations ──────────────────────────────────────────────────────

def write_safe(path: Path, content: str) -> None:
    """Write to a sibling .tmp then atomically replace path.

    Guarantees:
    - Refuses empty content — original file is never replaced with nothing.
    - The .tmp file is cleaned up even on failure.
    - `Path.replace()` is atomic on the same filesystem (POSIX rename(2)).
    """
    if not content:
        raise ValueError(f"Refusing to write empty content to {path}")
    tmp = path.with_suffix(".tmp")
    try:
        tmp.write_text(content, encoding="utf-8")
        if tmp.stat().st_size == 0:
            raise RuntimeError(f"Tmp file is zero bytes after write: {path}")
        tmp.replace(path)
    except Exception:
        tmp.unlink(missing_ok=True)
        raise


def _file_hash(path: Path) -> str:
    h = hashlib.md5()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _move_srt_to_vault(src: Path, dst: Path, log: logging.Logger) -> None:
    """Copy-verify-delete: move SRT from drop folder to vault.

    Safer than shutil.move across filesystems (Google Drive is a separate mount).
    Verifies MD5 hash before removing source — if copy or verification fails,
    source is preserved intact and an exception is raised.
    """
    dst.parent.mkdir(parents=True, exist_ok=True)
    src_hash = _file_hash(src)
    try:
        shutil.copy2(str(src), str(dst))
    except Exception:
        dst.unlink(missing_ok=True)
        raise
    dst_hash = _file_hash(dst)
    if src_hash != dst_hash:
        dst.unlink(missing_ok=True)
        raise RuntimeError(
            f"SRT copy content mismatch (MD5 {src_hash} vs {dst_hash}) — "
            f"source preserved at {src}"
        )
    src.unlink()
    log.info("Moved SRT to vault: %s", dst.name)

# ── External tools ────────────────────────────────────────────────────────────

def _claude_cmd_from_nvm(_nvm_dir: Optional[Path] = None) -> tuple[list[str], dict]:
    """Locate the claude binary directly in the nvm node installation.

    Bypasses nvm-exec so this works in launchd daemon context where NVM_DIR is
    unset. nvm-exec relies on NVM_DIR to source nvm.sh; when that env var is
    missing (as it is under launchd) nvm-exec cannot find installed versions even
    if they exist. Direct path lookup has no such dependency.

    _nvm_dir is a test seam — callers should omit it.
    """
    nvmrc = (DOTFILES_DIR / "claude" / ".nvmrc").read_text().strip()
    nvm_dir = _nvm_dir or (Path.home() / ".nvm")
    node_bin = nvm_dir / "versions" / "node" / nvmrc / "bin"
    claude = node_bin / "claude"
    if not (claude.is_file() and os.access(str(claude), os.X_OK)):
        raise FileNotFoundError(
            f"claude not found at {claude} — "
            f"run: nvm install {nvmrc} && npm install -g @anthropic-ai/claude-code"
        )
    path = f"{node_bin}:{os.environ.get('PATH', '')}"
    return [str(claude)], {**os.environ, "PATH": path}


def run_whisper(m4a: Path, log_file: Path, whisper_cmd: Optional[str] = None) -> None:
    cmd = [whisper_cmd or str(SCRIPT_DIR / "whisper"), str(m4a)]
    with log_file.open("ab") as lf:
        result = subprocess.run(cmd, stdout=lf, stderr=lf)
    if result.returncode != 0:
        raise RuntimeError(f"whisper exited with code {result.returncode}")


def run_claude(
    srt: Path,
    meeting_note: Path,
    log_file: Path,
    claude_cmd: Optional[str] = None,
    vault_root: Optional[Path] = None,
) -> str:
    """Run eval-transcript skill and return the generated markdown content.

    The skill is instructed to output only the markdown evaluation to stdout
    and NOT write any file — Claude Code's Write tool cannot be granted
    permission in a non-interactive subprocess. The caller writes the content
    to the summary file using write_safe().
    """
    # --add-dir is variadic and would consume a positional prompt arg; send the
    # prompt via stdin instead so --add-dir only gets the vault root.
    prompt = f"/eval-transcript {srt} {meeting_note}\n"
    vault_dir = str(vault_root) if vault_root else str(srt.parent)
    if claude_cmd:
        cmd = [claude_cmd, "--print", "--dangerously-skip-permissions",
               "--add-dir", vault_dir]
        env = None
    else:
        cmd_prefix, env = _claude_cmd_from_nvm()
        cmd = cmd_prefix + ["--print", "--dangerously-skip-permissions",
                            "--add-dir", vault_dir]
    result = subprocess.run(cmd, input=prompt.encode("utf-8"),
                            capture_output=True, env=env)
    with log_file.open("ab") as lf:
        lf.write(result.stdout)
        lf.write(result.stderr)
    if result.returncode != 0:
        raise RuntimeError(f"claude exited with code {result.returncode}")
    content = result.stdout.decode("utf-8", errors="replace").strip()
    if not content:
        raise RuntimeError("claude produced no output")
    return content

# ── Doctor ────────────────────────────────────────────────────────────────────

def doctor(config_path: Path) -> int:
    results: list[tuple[bool, str]] = []

    def _ok(cond: bool, msg: str = "failed") -> None:
        if not cond:
            raise AssertionError(msg)

    def check(label: str, fn) -> None:
        try:
            fn()
            results.append((True, label))
        except Exception as exc:
            results.append((False, f"{label} — {exc}"))

    print("whisper-watch --doctor\n")
    print("Config")
    check(f"config exists ({config_path})", lambda: _ok(config_path.exists(), "not found"))
    if config_path.exists():
        check("config is valid JSON", lambda: load_config(config_path))
        try:
            cfg = load_config(config_path)
            vault = Path(cfg["obsidian_vault_root"])
            meetings = vault / cfg["obsidian_meetings_subdir"]
            drop = Path(cfg["drop_folder"])
            check("drop_folder exists", lambda: _ok(drop.is_dir()))
            check("obsidian_vault_root exists", lambda: _ok(vault.is_dir()))
            check("meetings folder exists", lambda: _ok(meetings.is_dir()))
        except Exception:
            pass

    print("\nDependencies")
    for tool in ["jq", "fswatch", "ffmpeg"]:
        check(f"{tool} in PATH", lambda tool=tool: _ok(
            subprocess.run(["which", tool], capture_output=True).returncode == 0
        ))

    def _check_claude() -> None:
        cmd, env = _claude_cmd_from_nvm()
        result = subprocess.run(cmd + ["--version"], env=env, capture_output=True)
        _ok(result.returncode == 0, f"claude --version exited {result.returncode}")

    check("claude accessible", _check_claude)

    print("\nWhisper")
    venv = SCRIPT_DIR.parent / "venv"
    python = venv / "bin" / "python"
    check("venv exists", lambda: _ok(venv.is_dir()))
    check("mlx_whisper installed", lambda: _ok(
        subprocess.run([str(python), "-c", "import mlx_whisper"],
                       capture_output=True).returncode == 0
    ))
    check("whisperx installed", lambda: _ok(
        subprocess.run([str(python), "-c", "import whisperx"],
                       capture_output=True).returncode == 0
    ))
    check("models installed", lambda: _ok((venv / ".models_installed").exists()))

    print("\nLaunchd")
    check("agent loaded", lambda: _ok(
        "com.rtimmons.whisper-watch" in subprocess.run(
            ["launchctl", "list"], capture_output=True, text=True
        ).stdout
    ))

    print()
    for ok, label in results:
        print(f"  {'OK  ' if ok else 'FAIL'} {label}")
    print()
    failed = [label for ok, label in results if not ok]
    if failed:
        print(f"{len(failed)} check(s) failed.")
        return 1
    print("All checks passed.")
    return 0

# ── Internal processing helpers ───────────────────────────────────────────────

def _update_meeting_note(
    meeting_note: Path,
    inclusion_line: str,
    log: logging.Logger,
) -> None:
    """Ensure the meeting note has front-matter, has-voice-memo tag, and inclusion link.

    Always runs — never skipped — so a crash between summary creation and note
    update is repaired on the next run. Idempotent: reads current state and
    writes only if something is missing. Uses write_safe for atomic replacement.
    """
    if not meeting_note.exists():
        return

    original = meeting_note.read_text(encoding="utf-8")
    updated = original

    updated = ensure_frontmatter(updated)
    updated = ensure_tag(updated, HAS_VOICE_MEMO_TAG)

    if inclusion_line not in updated:
        updated = updated.rstrip("\n") + f"\n\n{inclusion_line}\n"

    if updated != original:
        write_safe(meeting_note, updated)
        log.info("Updated meeting note (front-matter / tag / inclusion link)")

# ── Main processing ───────────────────────────────────────────────────────────

def process(
    m4a: Path,
    config: dict,
    log: logging.Logger,
    log_file: Path,
    whisper_cmd: Optional[str] = None,
    claude_cmd: Optional[str] = None,
) -> None:
    """Process one .m4a file end-to-end.

    Outcome after successful completion:
      drop/            {name}.m4a  {name}.mp3
      vault/summaries/ {name}.srt  {name}-summary.md
      vault/meetings/  {name}.md   (front-matter, has-voice-memo tag, inclusion link)

    Safe to call multiple times — idempotent at each step.
    The meeting note (user data) is never deleted. write_safe is used for every
    mutation so partial writes cannot occur.
    """
    vault_root = Path(config["obsidian_vault_root"])
    meetings_path = vault_root / config["obsidian_meetings_subdir"]
    summaries_path = vault_root / config["obsidian_summaries_subdir"]
    summaries_rel = config["obsidian_summaries_subdir"].rstrip("/")

    filename = m4a.stem
    srt_drop = m4a.with_suffix(".srt")
    srt_vault = summaries_path / f"{filename}.srt"
    summary_vault = summaries_path / f"{filename}-summary.md"
    meeting_note = meetings_path / f"{filename}.md"
    inclusion_line = f"![[{summaries_rel}/{filename}-summary]]"

    log.info("=== Processing: %s ===", filename)
    log.debug("m4a:       %s", m4a)
    log.debug("meeting:   %s", meeting_note)
    log.debug("summary:   %s", summary_vault)

    # Step 1: Handle redo.
    # Strip the flag BEFORE any subprocess call so the vault watcher cannot
    # re-trigger during the long-running whisper/claude steps. Only auto-generated
    # files are deleted — the meeting note is never deleted.
    if meeting_note.exists():
        note_text = meeting_note.read_text(encoding="utf-8")
        if get_frontmatter_value(note_text, "redo") == "true":
            log.info("Redo flag detected — clearing: %s", filename)
            new_text = remove_frontmatter_key(note_text, "redo")
            write_safe(meeting_note, new_text)
            summary_vault.unlink(missing_ok=True)
            srt_vault.unlink(missing_ok=True)
            srt_drop.unlink(missing_ok=True)

    # Ensure the meeting note exists. Created here if user hasn't made it yet;
    # the write_text is not wrapped in write_safe because there is no prior
    # content to protect — the file does not exist yet.
    if not meeting_note.exists():
        meetings_path.mkdir(parents=True, exist_ok=True)
        meeting_note.write_text(
            f"---\ntags:\n  - {HAS_VOICE_MEMO_TAG}\n---\n"
            f"# {filename}\n\n*Automatically created by whisper-watch — add notes here.*\n",
            encoding="utf-8",
        )
        log.info("Created meeting note: %s", meeting_note)

    # Steps 2–3: Transcribe and summarize.
    # Skipped as a unit when both outputs are already in the vault, but
    # _update_meeting_note always runs below to repair any crash between
    # summary creation and note update.
    if srt_vault.exists() and summary_vault.exists():
        log.info("Transcript and summary exist, skipping pipeline: %s", filename)
    else:
        # Step 2: Transcribe → vault (copy-verify-delete for cross-fs safety)
        if srt_vault.exists():
            log.info("SRT in vault, skipping whisper: %s", srt_vault.name)
        elif srt_drop.exists():
            _move_srt_to_vault(srt_drop, srt_vault, log)
        else:
            log.info("Running whisper...")
            run_whisper(m4a, log_file, whisper_cmd)
            if not srt_drop.exists():
                raise RuntimeError(f"Whisper ran but SRT not found: {srt_drop}")
            _move_srt_to_vault(srt_drop, srt_vault, log)
            log.info("Transcription done: %s", srt_vault.name)

        # Step 3: Summarize — Claude reads vault SRT + meeting note for context,
        # outputs markdown to stdout; we write it to vault using write_safe().
        if summary_vault.exists():
            log.info("Summary exists, skipping Claude")
        else:
            log.info("Running eval-transcript...")
            content = run_claude(srt_vault, meeting_note, log_file, claude_cmd,
                                 vault_root=vault_root)
            write_safe(summary_vault, content + "\n")
            log.info("Summary done: %s", summary_vault.name)

    # Step 4: Always ensure meeting note metadata is complete.
    # Runs even when the pipeline was skipped, repairing any crash between
    # summary creation and note update.
    _update_meeting_note(meeting_note, inclusion_line, log)

    log.info("=== Done: %s ===", filename)

# ── Backfill ──────────────────────────────────────────────────────────────────

def backfill(
    config: dict,
    log: logging.Logger,
    log_file: Path,
    whisper_cmd: Optional[str] = None,
    claude_cmd: Optional[str] = None,
) -> int:
    """Process all unprocessed .m4a files in the drop folder."""
    drop = Path(config["drop_folder"])
    m4a_files = sorted(drop.glob("*.m4a")) + sorted(drop.glob("*.M4A"))
    if not m4a_files:
        log.info("Backfill: no .m4a files found in %s", drop)
        return 0
    log.info("Backfill: %d .m4a file(s) found", len(m4a_files))
    errors = 0
    for m4a in m4a_files:
        try:
            process(m4a, config, log, log_file, whisper_cmd, claude_cmd)
        except Exception as exc:
            log.error("Backfill failed for %s: %s", m4a.name, exc)
            errors += 1
    if errors:
        log.error("Backfill completed with %d error(s)", errors)
        return 1
    log.info("Backfill complete")
    return 0

# ── CLI ───────────────────────────────────────────────────────────────────────

def main() -> int:
    config_path = Path(
        os.environ.get("WHISPER_WATCH_CONFIG", str(DEFAULT_CONFIG_PATH))
    )

    args = sys.argv[1:]

    if args == ["--doctor"]:
        return doctor(config_path)

    try:
        config = load_config(config_path)
    except (FileNotFoundError, ValueError) as exc:
        print(f"Config error: {exc}", file=sys.stderr)
        return 1

    log_dir = SCRIPT_DIR.parent / "logs"
    log, log_file = setup_logging(
        log_dir,
        os.environ.get("WHISPER_WATCH_LOG_LEVEL", config.get("log_level", "info")),
        int(config.get("log_retention_days", 7)),
        int(config.get("error_log_retention_days", 30)),
    )

    whisper_cmd = os.environ.get("WHISPER_CMD") or None
    claude_cmd = os.environ.get("CLAUDE_CMD") or None

    if args == ["--backfill"]:
        return backfill(config, log, log_file, whisper_cmd, claude_cmd)

    if len(args) != 1:
        print("Usage: whisper-watch <file.m4a> | --backfill | --doctor", file=sys.stderr)
        return 1

    m4a = Path(args[0]).resolve()
    if not m4a.exists():
        print(f"File not found: {m4a}", file=sys.stderr)
        return 1
    if m4a.suffix.lower() != ".m4a":
        print(f"Not an .m4a file: {m4a}", file=sys.stderr)
        return 1

    try:
        process(m4a, config, log, log_file, whisper_cmd, claude_cmd)
        return 0
    except Exception as exc:
        log.error("%s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())