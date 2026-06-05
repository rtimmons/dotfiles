# whisper-watch

Automatically transcribes Voice Memo recordings, generates meeting summaries,
and imports everything into Obsidian.

## File layout

```
Drop folder (Voice Memos):
  recording.m4a          ← you drop this here
  recording.mp3          ← whisper produces this (left in place)

Vault/Meetings/:
  recording.md           ← your notes; gets front-matter, tag, inclusion link

Vault/Meetings/AI/Summaries/:
  recording.srt          ← transcript (moved from drop folder)
  recording-summary.md   ← AI summary (produced by eval-transcript skill)
```

## Setup

### 1. Install

```bash
just install   # or: bash whisper/install.sh
```

Installs `ffmpeg`, `jq`, `fswatch`, Python transcription dependencies,
and registers the launchd agent.

### 2. Configure

Edit `~/.whisper-watch-config.json` (created by install with defaults):

```json
{
  "drop_folder": "/path/to/Voice Memos",
  "obsidian_vault_root": "/path/to/vault",
  "obsidian_meetings_subdir": "Meetings",
  "obsidian_summaries_subdir": "AI/Summaries",
  "log_level": "info",
  "log_retention_days": 7,
  "error_log_retention_days": 30
}
```

### 3. Install whisper models (one-time)

```bash
HUGGING_FACE_TOKEN=<your-token> bash whisper/install_models.sh
```

## Normal workflow

1. Create your Obsidian meeting note before the meeting (`Meetings/2026-06-05-meeting.md`)
2. Record the meeting with Voice Memos; take notes in the Obsidian note
3. Rename the `.m4a` to match the note basename (`2026-06-05-meeting.m4a`)
4. Drop the `.m4a` into the configured drop folder
5. The daemon detects it, runs the pipeline, and adds the summary inclusion to your note

## Idempotency

The pipeline is safe to re-run. It skips each step based on what already exists:

| Vault summary exists? | redo: true? | Action |
|---|---|---|
| Yes | No | Skip entirely |
| Yes | Yes | Delete summary + SRT, re-run from whisper |
| No | — | Run full pipeline |

## Re-processing with corrections

If a summary is inaccurate, add corrections to your meeting note above the
`![[...]]` inclusion line, then set `redo: true` in the front-matter:

```yaml
---
redo: true
tags:
  - has-voice-memo
---
# 2026-06-05 Design Review

Correction: the speaker called "SPEAKER_01" is Alice, not Bob.

![[Meetings/AI/Summaries/2026-06-05-meeting-summary]]
```

Save the file. The daemon detects the change (30-second debounce), finds the
matching `.m4a` in the drop folder, strips `redo: true`, and re-runs the
pipeline incorporating your corrections.

To trigger manually: `whisper-watch 2026-06-05-meeting.m4a`

## Backfill

To process all existing `.m4a` files in the drop folder:

```bash
whisper-watch --backfill
```

Skips anything already fully processed.

## Diagnostics

```bash
whisper-watch --doctor
```

Checks config, dependencies, whisper models, and launchd agent.

## Logs

```
whisper/logs/YYYYMMDD.txt   — daily processing log (rotated per log_retention_days)
whisper/logs/errors.log     — accumulated errors (rotated per error_log_retention_days)
whisper/logs/daemon.log     — daemon stdout
whisper/logs/daemon-error.log — daemon stderr
```

## Tests

```bash
bash whisper/tests/run-tests.sh
```

Uses Python `unittest` with mocked subprocesses — no models or API keys needed.