#!/usr/bin/env python3
"""Serve the dotfiles pruning review and persist feedback to SQLite."""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
import webbrowser
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from threading import Timer
from typing import Any
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parent
DEFAULT_REVIEW = ROOT / "PRUNING_REVIEW.md"
DEFAULT_DATABASE = ROOT / "response.sqlite3"
VALID_DECISIONS = {"keep", "icebox", "delete", "local", "ask"}
SECTION_RECOMMENDATIONS = {
    "## Recommended keep": "keep",
    "## Recommended icebox": "icebox",
    "## Initial manual review": "decide",
    "## Local/generated directories": "local",
}


PAGE = r"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dotfiles pruning review</title>
  <style>
    :root {
      color-scheme: light dark;
      --page: light-dark(#f4f6f8, #111318);
      --surface: light-dark(#fff, #1a1d23);
      --raised: light-dark(#f9fafb, #20242c);
      --text: light-dark(#17191d, #f1f3f5);
      --muted: light-dark(#626a76, #aab1bc);
      --border: light-dark(#dfe3e8, #353a44);
      --accent: light-dark(#315fc4, #82a7ff);
      --accent-soft: light-dark(#eaf0ff, #1e2a49);
      --keep: light-dark(#1f7045, #79d49d);
      --keep-bg: light-dark(#e8f5ed, #153427);
      --icebox: light-dark(#8a4a0a, #f4b86c);
      --icebox-bg: light-dark(#fff2df, #3c2916);
      --decide: light-dark(#6e43a3, #c8a2f2);
      --decide-bg: light-dark(#f4eaff, #30233e);
      --local: light-dark(#476171, #9bc3d8);
      --local-bg: light-dark(#eaf2f6, #1d3039);
      font-family: ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--page);
      color: var(--text);
    }
    * { box-sizing: border-box; }
    body { margin: 0; min-width: 320px; }
    header {
      padding: 24px max(20px, calc((100vw - 1040px) / 2));
      background: var(--surface);
      border-bottom: 1px solid var(--border);
    }
    .title-row, .progress-row, .tools, .filters, .row-head, .decision-wrap {
      display: flex;
      align-items: center;
    }
    .title-row { justify-content: space-between; gap: 18px; }
    h1 { margin: 0; font-size: 24px; letter-spacing: -.025em; }
    .subtitle { margin: 6px 0 0; color: var(--muted); font-size: 13px; }
    .save-status { color: var(--muted); font-size: 12px; white-space: nowrap; }
    .save-status.error { color: light-dark(#a33a3a, #ef8f8f); }
    .progress-row { gap: 12px; margin-top: 18px; }
    .progress { height: 7px; background: var(--border); border-radius: 999px; overflow: hidden; flex: 1; }
    .progress span { display: block; width: 0; height: 100%; background: var(--accent); transition: width 150ms ease; }
    .progress-label { min-width: 108px; color: var(--muted); text-align: right; font-size: 12px; font-variant-numeric: tabular-nums; }
    .controls {
      position: sticky;
      top: 0;
      z-index: 2;
      padding: 13px max(20px, calc((100vw - 1040px) / 2));
      background: color-mix(in srgb, var(--surface) 94%, transparent);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid var(--border);
    }
    .tools { gap: 9px; }
    input[type="search"] {
      flex: 1;
      min-width: 180px;
      height: 37px;
      padding: 0 11px;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: var(--raised);
      color: var(--text);
      font: inherit;
      font-size: 13px;
      outline: none;
    }
    input[type="search"]:focus, textarea:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 2px var(--accent-soft);
    }
    button {
      height: 37px;
      padding: 0 12px;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: var(--raised);
      color: var(--text);
      font: inherit;
      font-size: 12px;
      cursor: pointer;
    }
    button:hover { border-color: var(--accent); }
    .filters { gap: 6px; flex-wrap: wrap; margin-top: 9px; }
    .filters button { height: 30px; padding: 0 9px; border: 0; background: transparent; color: var(--muted); }
    .filters button[aria-pressed="true"] { background: var(--accent-soft); color: var(--accent); font-weight: 700; }
    .unreviewed { margin-left: auto; display: inline-flex; align-items: center; gap: 7px; color: var(--muted); font-size: 12px; cursor: pointer; }
    input[type="checkbox"] { accent-color: var(--accent); }
    main { max-width: 1040px; margin: 0 auto; padding: 14px 20px 30px; }
    .list { display: grid; gap: 9px; }
    article {
      display: grid;
      grid-template-columns: minmax(220px, 1.1fr) minmax(220px, 1.4fr);
      gap: 12px 20px;
      padding: 14px;
      border: 1px solid var(--border);
      border-radius: 10px;
      background: var(--surface);
    }
    article[data-confirmed="true"] { border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); }
    .row-head { align-items: flex-start; gap: 9px; }
    .confirm { width: 17px; height: 17px; margin: 3px 0 0; flex: 0 0 auto; cursor: pointer; }
    h2 { margin: 0; font: 720 14px/1.3 ui-monospace, SFMono-Regular, Menlo, monospace; overflow-wrap: anywhere; }
    .role { margin-top: 4px; color: var(--muted); font-size: 12px; line-height: 1.4; }
    .badge { display: inline-block; margin-top: 9px; padding: 3px 6px; border-radius: 5px; font-size: 10px; font-weight: 750; letter-spacing: .04em; text-transform: uppercase; }
    .badge.keep { color: var(--keep); background: var(--keep-bg); }
    .badge.icebox { color: var(--icebox); background: var(--icebox-bg); }
    .badge.decide { color: var(--decide); background: var(--decide-bg); }
    .badge.local { color: var(--local); background: var(--local-bg); }
    .evidence { margin: 0; font-size: 12px; line-height: 1.5; }
    .edit { grid-column: 1 / -1; display: grid; grid-template-columns: minmax(390px, .9fr) 1fr; gap: 14px; align-items: start; padding-top: 10px; border-top: 1px solid var(--border); }
    .decision-wrap { display: block; }
    .decision-wrap label, .note-wrap label { color: var(--muted); font-size: 11px; font-weight: 650; white-space: nowrap; }
    .decision-buttons { display: flex; flex-wrap: wrap; gap: 5px; margin-top: 6px; }
    .decision-button { height: 30px; padding: 0 9px; color: var(--muted); }
    .decision-button[aria-pressed="true"] { border-color: var(--accent); background: var(--accent-soft); color: var(--accent); font-weight: 700; }
    .decision-button:focus-visible { outline: 2px solid var(--accent); outline-offset: 1px; }
    .research { display: inline-flex; align-items: center; gap: 7px; margin-top: 9px; color: var(--muted); font-size: 11px; cursor: pointer; }
    .research input { width: 15px; height: 15px; margin: 0; }
    .note-wrap { display: grid; grid-template-columns: auto 1fr; gap: 8px; align-items: start; }
    .note-wrap label { padding-top: 8px; }
    textarea {
      width: 100%;
      min-height: 32px;
      max-height: 120px;
      resize: vertical;
      padding: 7px 9px;
      border: 1px solid var(--border);
      border-radius: 7px;
      background: var(--raised);
      color: var(--text);
      font: inherit;
      font-size: 12px;
      line-height: 1.4;
      outline: none;
    }
    .empty { padding: 56px 20px; text-align: center; color: var(--muted); font-size: 13px; }
    @media (max-width: 640px) {
      .title-row, .tools { align-items: stretch; flex-direction: column; }
      article, .edit { grid-template-columns: 1fr; }
      .unreviewed { width: 100%; margin-left: 0; padding: 6px 8px; }
      .save-status { white-space: normal; }
    }
  </style>
</head>
<body>
  <header>
    <div class="title-row">
      <div>
        <h1>Dotfiles pruning review</h1>
        <p class="subtitle">Choose a disposition, add notes, then confirm each directory.</p>
      </div>
      <span class="save-status" aria-live="polite">Saved to response.sqlite3</span>
    </div>
    <div class="progress-row">
      <div class="progress" aria-hidden="true"><span></span></div>
      <div class="progress-label">0 of 98 reviewed</div>
    </div>
  </header>
  <section class="controls" aria-label="Review controls">
    <div class="tools">
      <input class="search" type="search" placeholder="Search directories, functions, or evidence…" aria-label="Search directories">
      <button class="copy" type="button">Copy reviewed</button>
    </div>
    <div class="filters" role="group" aria-label="Recommendation filter"></div>
  </section>
  <main><div class="list" aria-live="polite"></div></main>
  <script id="bootstrap" type="application/json">__BOOTSTRAP__</script>
  <script>
    (() => {
      const boot = JSON.parse(document.getElementById('bootstrap').textContent);
      const rows = boot.items;
      const state = boot.responses;
      const list = document.querySelector('.list');
      const search = document.querySelector('.search');
      const filters = document.querySelector('.filters');
      const progressBar = document.querySelector('.progress span');
      const progressLabel = document.querySelector('.progress-label');
      const saveStatus = document.querySelector('.save-status');
      const counts = rows.reduce((all, row) => ({...all, [row.recommendation]: (all[row.recommendation] || 0) + 1}), {});
      const labels = {all: 'All', keep: 'Keep', icebox: 'Icebox', decide: 'Decide', local: 'Local'};
      let filter = 'all';
      let onlyUnreviewed = false;
      let pendingSaves = 0;

      const escapeHtml = value => String(value)
        .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;').replaceAll("'", '&#039;');
      const clean = value => value.replaceAll('`', '').replaceAll('**', '');
      const decisionLabels = {keep: 'Keep', icebox: 'Icebox', delete: 'Delete', local: 'Local', ask: 'Need answer'};
      const decisionButton = (value, selected, name) => `<button type="button" class="decision-button" data-decision="${value}" aria-pressed="${value === selected}" aria-label="Set ${escapeHtml(name)} to ${decisionLabels[value]}">${decisionLabels[value]}</button>`;

      const setSaveStatus = (text, error = false) => {
        saveStatus.textContent = text;
        saveStatus.classList.toggle('error', error);
      };

      const persist = name => {
        state[name].revision += 1;
        const snapshot = {name, ...state[name]};
        pendingSaves += 1;
        setSaveStatus(pendingSaves === 1 ? 'Saving…' : `Saving ${pendingSaves} changes…`);
        fetch('/api/response', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify(snapshot),
        }).then(async response => {
          if (!response.ok) throw new Error(await response.text());
          pendingSaves -= 1;
          setSaveStatus(pendingSaves ? `Saving ${pendingSaves} changes…` : 'Saved to response.sqlite3');
        }).catch(error => {
          pendingSaves = Math.max(0, pendingSaves - 1);
          setSaveStatus(`Save failed: ${error.message}`, true);
        });
      };

      const updateProgress = () => {
        const reviewed = rows.filter(row => state[row.name].confirmed).length;
        progressBar.style.width = `${(reviewed / rows.length) * 100}%`;
        progressLabel.textContent = `${reviewed} of ${rows.length} reviewed`;
      };

      const matches = row => {
        const query = search.value.trim().toLowerCase();
        const haystack = `${row.name} ${row.role} ${row.evidence} ${state[row.name].note}`.toLowerCase();
        return (filter === 'all' || row.recommendation === filter)
          && (!onlyUnreviewed || !state[row.name].confirmed)
          && (!query || haystack.includes(query));
      };

      const render = () => {
        const visible = rows.filter(matches);
        if (!visible.length) {
          list.innerHTML = '<div class="empty">No directories match this view.</div>';
          updateProgress();
          return;
        }
        list.innerHTML = visible.map(row => {
          const item = state[row.name];
          const badge = row.recommendation === 'decide' ? 'needs decision' : `recommend ${row.recommendation}`;
          return `<article data-name="${escapeHtml(row.name)}" data-confirmed="${item.confirmed}">
            <div class="row-head">
              <input class="confirm" type="checkbox" aria-label="Confirm ${escapeHtml(row.name)}"${item.confirmed ? ' checked' : ''}>
              <div>
                <h2>${escapeHtml(row.name)}</h2>
                <div class="role">${escapeHtml(clean(row.role))}</div>
                <span class="badge ${row.recommendation}">${badge}</span>
              </div>
            </div>
            <p class="evidence">${escapeHtml(clean(row.evidence))}</p>
            <div class="edit">
              <div class="decision-wrap">
                <label>Disposition</label>
                <div class="decision-buttons" role="group" aria-label="Disposition for ${escapeHtml(row.name)}">
                  ${['keep', 'icebox', 'delete', 'local', 'ask'].map(value => decisionButton(value, item.decision, row.name)).join('')}
                </div>
                <label class="research"><input class="more-info" type="checkbox"${item.more_info ? ' checked' : ''}> Research / add more information</label>
              </div>
              <div class="note-wrap">
                <label>Your note</label>
                <textarea class="user-note" rows="1" aria-label="Note for ${escapeHtml(row.name)}" placeholder="Answer the question, record a caveat, or leave blank…">${escapeHtml(item.note)}</textarea>
              </div>
            </div>
          </article>`;
        }).join('');

        list.querySelectorAll('article').forEach(card => {
          const name = card.dataset.name;
          card.querySelector('.confirm').addEventListener('change', event => {
            state[name].confirmed = event.target.checked;
            card.dataset.confirmed = String(event.target.checked);
            persist(name);
            updateProgress();
            if (onlyUnreviewed && event.target.checked) render();
          });
          card.querySelectorAll('.decision-button').forEach(button => button.addEventListener('click', () => {
            state[name].decision = button.dataset.decision;
            state[name].confirmed = true;
            card.querySelector('.confirm').checked = true;
            card.dataset.confirmed = 'true';
            card.querySelectorAll('.decision-button').forEach(item => item.setAttribute('aria-pressed', String(item === button)));
            persist(name);
            updateProgress();
            if (onlyUnreviewed) render();
          }));
          card.querySelector('.more-info').addEventListener('change', event => {
            state[name].more_info = event.target.checked;
            persist(name);
          });
          card.querySelector('.user-note').addEventListener('input', event => {
            state[name].note = event.target.value;
            persist(name);
          });
        });
        updateProgress();
      };

      ['all', 'keep', 'icebox', 'decide', 'local'].forEach(kind => {
        const button = document.createElement('button');
        button.type = 'button';
        button.dataset.filter = kind;
        button.setAttribute('aria-pressed', String(kind === 'all'));
        button.textContent = `${labels[kind]} · ${kind === 'all' ? rows.length : counts[kind] || 0}`;
        button.addEventListener('click', () => {
          filter = kind;
          filters.querySelectorAll('button').forEach(item => item.setAttribute('aria-pressed', String(item === button)));
          render();
        });
        filters.appendChild(button);
      });
      const unreviewedLabel = document.createElement('label');
      unreviewedLabel.className = 'unreviewed';
      unreviewedLabel.innerHTML = '<input type="checkbox"> Unreviewed only';
      unreviewedLabel.querySelector('input').addEventListener('change', event => {
        onlyUnreviewed = event.target.checked;
        render();
      });
      filters.appendChild(unreviewedLabel);

      search.addEventListener('input', render);
      document.querySelector('.copy').addEventListener('click', async () => {
        const reviewed = rows.filter(row => state[row.name].confirmed);
        if (!reviewed.length) {
          setSaveStatus('Nothing reviewed yet');
          return;
        }
        const lines = reviewed.map(row => {
          const item = state[row.name];
          const research = item.more_info ? ' [research requested]' : '';
          return `- ${row.name}: ${item.decision}${research}${item.note.trim() ? ` — ${item.note.trim()}` : ''}`;
        });
        try {
          await navigator.clipboard.writeText(lines.join('\n'));
          setSaveStatus(`Copied ${reviewed.length} decisions`);
        } catch (error) {
          setSaveStatus(`Clipboard failed: ${error.message}`, true);
        }
      });
      render();
    })();
  </script>
</body>
</html>
"""


def parse_review(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(f"Review file not found: {path}")

    recommendation: str | None = None
    items: list[dict[str, str]] = []
    seen: set[str] = set()

    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            recommendation = next(
                (
                    value
                    for heading, value in SECTION_RECOMMENDATIONS.items()
                    if line.startswith(heading)
                ),
                None,
            )
            continue

        if recommendation is None or not line.startswith("| ["):
            continue

        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) not in {3, 4} or not re.fullmatch(r"\[[ xX]\]", cells[0]):
            continue

        name = cells[1].strip("`")
        if not name or name in seen:
            raise ValueError(f"Duplicate or empty directory in {path}: {name!r}")

        if len(cells) == 3:
            role = "Local/generated state"
            evidence = cells[2]
        else:
            role = cells[2]
            evidence = cells[3]

        seen.add(name)
        items.append(
            {
                "name": name,
                "recommendation": recommendation,
                "role": role,
                "evidence": evidence,
            }
        )

    if not items:
        raise ValueError(f"No review rows found in {path}")
    return items


def default_decision(recommendation: str) -> str:
    if recommendation == "decide":
        return "ask"
    return "local" if recommendation == "local" else recommendation


def open_database(path: Path, items: list[dict[str, str]]) -> sqlite3.Connection:
    path.parent.mkdir(parents=True, exist_ok=True)
    database = sqlite3.connect(path, timeout=5)
    database.row_factory = sqlite3.Row
    database.execute("PRAGMA journal_mode = WAL")
    database.execute("PRAGMA synchronous = FULL")
    database.execute(
        """
        CREATE TABLE IF NOT EXISTS responses (
            name TEXT PRIMARY KEY,
            decision TEXT NOT NULL CHECK (
                decision IN ('keep', 'icebox', 'delete', 'local', 'ask')
            ),
            confirmed INTEGER NOT NULL CHECK (confirmed IN (0, 1)),
            note TEXT NOT NULL,
            more_info INTEGER NOT NULL DEFAULT 0 CHECK (more_info IN (0, 1)),
            revision INTEGER NOT NULL CHECK (revision >= 0),
            updated_at TEXT NOT NULL
        )
        """
    )
    columns = {
        row["name"]
        for row in database.execute("PRAGMA table_info(responses)")
    }
    if "more_info" not in columns:
        database.execute(
            """
            ALTER TABLE responses
            ADD COLUMN more_info INTEGER NOT NULL DEFAULT 0
                CHECK (more_info IN (0, 1))
            """
        )
    now = datetime.now(timezone.utc).isoformat(timespec="milliseconds")
    defaults = [
        (
            item["name"],
            default_decision(item["recommendation"]),
            0,
            "",
            0,
            0,
            now,
        )
        for item in items
    ]
    with database:
        database.executemany(
            """
            INSERT OR IGNORE INTO responses
                (name, decision, confirmed, note, more_info, revision, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            defaults,
        )
    return database


def read_responses(
    database: sqlite3.Connection,
    items: list[dict[str, str]],
) -> dict[str, dict[str, Any]]:
    rows = {
        row["name"]: {
            "decision": row["decision"],
            "confirmed": bool(row["confirmed"]),
            "note": row["note"],
            "more_info": bool(row["more_info"]),
            "revision": row["revision"],
        }
        for row in database.execute(
            """
            SELECT name, decision, confirmed, note, more_info, revision
            FROM responses
            """
        )
    }
    return {item["name"]: rows[item["name"]] for item in items}


def response_payload(
    database: sqlite3.Connection,
    items: list[dict[str, str]],
) -> dict[str, Any]:
    updated_at = database.execute(
        "SELECT MAX(updated_at) FROM responses"
    ).fetchone()[0]
    return {
        "version": 1,
        "updated_at": updated_at,
        "responses": read_responses(database, items),
    }


def bootstrap_json(
    items: list[dict[str, str]],
    responses: dict[str, dict[str, Any]],
) -> str:
    payload = {"items": items, "responses": responses}
    return json.dumps(payload, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")


class ReviewServer(HTTPServer):
    items: list[dict[str, str]]
    item_names: set[str]
    database: sqlite3.Connection
    database_path: Path


class Handler(BaseHTTPRequestHandler):
    server: ReviewServer

    def send_bytes(self, status: int, content_type: str, body: bytes) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Content-Security-Policy", "default-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'")
        self.end_headers()
        self.wfile.write(body)

    def send_json(self, status: int, payload: dict[str, Any]) -> None:
        body = (json.dumps(payload, ensure_ascii=False) + "\n").encode("utf-8")
        self.send_bytes(status, "application/json; charset=utf-8", body)

    def do_GET(self) -> None:  # noqa: N802
        path = urlparse(self.path).path
        if path == "/":
            responses = read_responses(self.server.database, self.server.items)
            body = PAGE.replace(
                "__BOOTSTRAP__",
                bootstrap_json(self.server.items, responses),
            ).encode("utf-8")
            self.send_bytes(200, "text/html; charset=utf-8", body)
            return
        if path == "/api/response":
            self.send_json(
                200,
                response_payload(self.server.database, self.server.items),
            )
            return
        if path == "/favicon.ico":
            self.send_bytes(204, "image/x-icon", b"")
            return
        self.send_json(404, {"error": "not found"})

    def do_POST(self) -> None:  # noqa: N802
        if urlparse(self.path).path != "/api/response":
            self.send_json(404, {"error": "not found"})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_json(400, {"error": "invalid content length"})
            return
        if length <= 0 or length > 64 * 1024:
            self.send_json(400, {"error": "invalid request size"})
            return

        try:
            payload = json.loads(self.rfile.read(length))
        except (UnicodeDecodeError, json.JSONDecodeError):
            self.send_json(400, {"error": "invalid JSON"})
            return

        error = self.validate_response(payload)
        if error:
            self.send_json(400, {"error": error})
            return

        updated_at = datetime.now(timezone.utc).isoformat(timespec="milliseconds")
        try:
            with self.server.database:
                cursor = self.server.database.execute(
                    """
                    INSERT INTO responses
                        (name, decision, confirmed, note, more_info, revision, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(name) DO UPDATE SET
                        decision = excluded.decision,
                        confirmed = excluded.confirmed,
                        note = excluded.note,
                        more_info = excluded.more_info,
                        revision = excluded.revision,
                        updated_at = excluded.updated_at
                    WHERE excluded.revision > responses.revision
                    """,
                    (
                        payload["name"],
                        payload["decision"],
                        int(payload["confirmed"]),
                        payload["note"],
                        int(payload["more_info"]),
                        payload["revision"],
                        updated_at,
                    ),
                )
        except sqlite3.Error as error:
            self.send_json(500, {"error": f"cannot save response: {error}"})
            return
        self.send_json(
            200,
            {
                "ok": True,
                "saved": cursor.rowcount == 1,
                "revision": payload["revision"],
                "updated_at": updated_at,
            },
        )

    def validate_response(self, payload: Any) -> str | None:
        if not isinstance(payload, dict):
            return "request must be an object"
        if payload.get("name") not in self.server.item_names:
            return "unknown directory"
        if payload.get("decision") not in VALID_DECISIONS:
            return "invalid decision"
        if not isinstance(payload.get("confirmed"), bool):
            return "confirmed must be true or false"
        note = payload.get("note")
        if not isinstance(note, str) or len(note) > 10_000:
            return "note must be text no longer than 10,000 characters"
        if not isinstance(payload.get("more_info"), bool):
            return "more_info must be true or false"
        revision = payload.get("revision")
        if not isinstance(revision, int) or isinstance(revision, bool) or revision < 1:
            return "revision must be a positive integer"
        return None

    def log_message(self, message: str, *args: Any) -> None:
        sys.stderr.write(f"feedback: {message % args}\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--no-open", action="store_true", help="do not open the browser")
    parser.add_argument("--review", type=Path, default=DEFAULT_REVIEW, help=argparse.SUPPRESS)
    parser.add_argument("--database", type=Path, default=DEFAULT_DATABASE, help=argparse.SUPPRESS)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    database: sqlite3.Connection | None = None
    try:
        items = parse_review(args.review.resolve())
        database = open_database(args.database.resolve(), items)
    except (FileNotFoundError, OSError, ValueError, sqlite3.Error) as error:
        print(f"feedback: {error}", file=sys.stderr)
        return 1

    try:
        server = ReviewServer(("127.0.0.1", args.port), Handler)
    except OSError as error:
        database.close()
        print(f"feedback: cannot start localhost server: {error}", file=sys.stderr)
        return 1
    server.items = items
    server.item_names = {item["name"] for item in items}
    server.database = database
    server.database_path = args.database.resolve()
    host, port = server.server_address
    url = f"http://{host}:{port}/"
    print(f"Serving pruning review at {url}")
    print(f"Saving feedback to {server.database_path}")
    print("Press Ctrl-C to stop.")

    if not args.no_open:
        Timer(0.25, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        server.server_close()
        database.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
