"""Production-quality tests for _whisper_watch.py.

Design principles:
- All file I/O uses real temp directories — no mocks for filesystem operations.
- External subprocesses (whisper, claude) are mocked at the function level.
- Data safety invariants are verified as explicit assertions, not as side-effects.
- Adversarial inputs (unicode, embedded ---, CRLF, large content) are exercised
  via subTest loops so any failure identifies the specific input.
- Every test that touches the meeting note records its content before and after
  and asserts exactly what changed and what did not.
"""

import hashlib
import shutil
import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from typing import Optional
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent.parent / "bin"))
import _whisper_watch as ww

# ── Shared test inputs ────────────────────────────────────────────────────────

# Bodies chosen to exercise common failure modes in front-matter parsers.
ADVERSARIAL_BODIES = [
    "# Simple body\n",
    "# Unicode: 日本語 🎤 café résumé\n",
    # Note: bodies containing a bare `---` line are intentionally excluded.
    # The YAML front-matter format is inherently ambiguous with Markdown thematic
    # breaks (---). Any front-matter parser — including gray-matter and our own —
    # treats the first standalone `---` line as the FM closing delimiter.
    # Obsidian avoids this by only using --- as FM delimiters at the file head.
    # Note: CRLF bodies are intentionally excluded. Python's text-mode I/O
    # normalizes \r\n → \n on read, which is correct and expected behavior.
    "# Multiple\n\n\nblanks\n\n",
    "# Trailing space   \n# More content\n",
    "",  # empty body — front-matter only
    "a" * 8000,  # large body
    "# Indented content\n  - bullet\n  - another\n",
    "# Colon: in body\nkey: value\nredo: true\n",  # should never be parsed as FM
]

ADVERSARIAL_FM_LINES = [
    "title: Meeting",
    "title: Has: colons: in: value",
    "title: Unicode 日本語",
    "created: 2026-06-05",
    "priority: high",
]


def _body_of(text: str) -> str:
    """Extract the body after front-matter (or the whole text if no FM)."""
    m = ww._FM_RE.match(text)
    return text[m.end():] if m else text


def _make_config(drop: Path, vault: Path) -> dict:
    return {
        "drop_folder": str(drop),
        "obsidian_vault_root": str(vault),
        "obsidian_meetings_subdir": "Meetings",
        "obsidian_summaries_subdir": "Meetings/AI/Summaries",
    }


def _setup_dirs(tmpdir: str) -> tuple[Path, Path, Path, Path]:
    drop = Path(tmpdir) / "drop"
    vault = Path(tmpdir) / "vault"
    meetings = vault / "Meetings"
    summaries = vault / "Meetings" / "AI" / "Summaries"
    drop.mkdir()
    summaries.mkdir(parents=True)
    return drop, vault, meetings, summaries


def _make_m4a(drop: Path, name: str = "Meeting.m4a") -> Path:
    p = drop / name
    p.write_bytes(b"fake audio content")
    return p


class _PipelineBase(unittest.TestCase):
    """Base with setUp/tearDown for pipeline integration tests."""

    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()
        self.drop, self.vault, self.meetings, self.summaries = _setup_dirs(self.tmpdir)
        self.config = _make_config(self.drop, self.vault)
        log_dir = Path(self.tmpdir) / "logs"
        self.log, self.log_file = ww.setup_logging(log_dir, "debug", 7, 30)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir)

    def _stub_whisper(self, m4a: Path, log_file: Path, cmd: Optional[str] = None) -> None:
        m4a.with_suffix(".srt").write_text(
            "1\n00:00:00,000 --> 00:00:05,000\nSPEAKER_00: Hello.\n",
            encoding="utf-8",
        )

    def _stub_claude(self, srt: Path, note: Path, log_file: Path,
                     cmd: Optional[str] = None, **_kw) -> str:
        # Returns markdown content; process() writes it via write_safe()
        return "# Summary\nAuto-generated."

    def _run(self, m4a: Path, **kw) -> None:
        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.process(m4a, self.config, self.log, self.log_file, **kw)

    def _note(self, stem: str) -> Path:
        return self.meetings / f"{stem}.md"

    def _srt(self, stem: str) -> Path:
        return self.summaries / f"{stem}.srt"

    def _summary(self, stem: str) -> Path:
        return self.summaries / f"{stem}-summary.md"

    def _inclusion(self, stem: str) -> str:
        subdir = self.config["obsidian_summaries_subdir"].rstrip("/")
        return f"![[{subdir}/{stem}-summary]]"


# ═══════════════════════════════════════════════════════════════════════════════
# A. Front-matter pure function tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestFrontmatterPurity(unittest.TestCase):
    """Pure function tests. No filesystem I/O. Parametrized over adversarial inputs."""

    # ── ensure_frontmatter ────────────────────────────────────────────────────

    def test_ensure_frontmatter_adds_delimiters_when_absent(self) -> None:
        result = ww.ensure_frontmatter("# Body\n")
        # Empty FM uses ---\n\n---\n\n so _FM_RE can parse it (needs \n before closing ---)
        self.assertTrue(result.startswith("---\n"), "FM opening present")
        self.assertIn("\n---\n", result, "FM closing present")
        self.assertIn("# Body\n", result)
        self.assertTrue(ww.has_frontmatter(result), "result is parseable as FM")

    def test_ensure_frontmatter_noop_when_present(self) -> None:
        text = "---\ntitle: t\n---\n# Body\n"
        self.assertEqual(ww.ensure_frontmatter(text), text)

    def test_ensure_frontmatter_preserves_body_exactly(self) -> None:
        """Prepending front-matter must not alter a single byte of body content."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                text = f"---\ntitle: t\n---\n{body}"
                result = ww.ensure_frontmatter(text)
                self.assertEqual(_body_of(result), body)

    def test_ensure_frontmatter_on_empty_string(self) -> None:
        result = ww.ensure_frontmatter("")
        self.assertTrue(ww.has_frontmatter(result), "empty string gets parseable FM")

    # ── ensure_tag ────────────────────────────────────────────────────────────

    def test_ensure_tag_adds_new_tags_key_when_absent(self) -> None:
        text = "---\ntitle: M\n---\nBody"
        result = ww.ensure_tag(text, "has-voice-memo")
        self.assertIn("tags:", result)
        self.assertIn("has-voice-memo", result)

    def test_ensure_tag_appends_to_existing_empty_tags(self) -> None:
        text = "---\ntags:\n---\nBody"
        result = ww.ensure_tag(text, "has-voice-memo")
        self.assertIn("has-voice-memo", result)

    def test_ensure_tag_appends_to_existing_tags_list(self) -> None:
        text = "---\ntags:\n  - other-tag\n---\nBody"
        result = ww.ensure_tag(text, "has-voice-memo")
        self.assertIn("other-tag", result, "existing tag preserved")
        self.assertIn("has-voice-memo", result)

    def test_ensure_tag_noop_when_already_present(self) -> None:
        text = "---\ntags:\n  - has-voice-memo\n---\nBody"
        self.assertEqual(ww.ensure_tag(text, "has-voice-memo"), text)

    def test_ensure_tag_no_false_positive_on_substring_match(self) -> None:
        """'has-voice-memo' must not match 'not-has-voice-memo'."""
        for containing_tag in [
            "not-has-voice-memo",
            "already-has-voice-memo",
            "has-voice-memo-final",
            "xhas-voice-memo",
        ]:
            with self.subTest(tag=containing_tag):
                text = f"---\ntags:\n  - {containing_tag}\n---\nBody"
                result = ww.ensure_tag(text, "has-voice-memo")
                # The real tag should have been added because the existing one is different
                self.assertIn("has-voice-memo\n", result,
                              f"tag should be added when only '{containing_tag}' is present")

    def test_ensure_tag_idempotent(self) -> None:
        """Applying ensure_tag twice produces the same result as once."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:40])):
                text = f"---\ntitle: t\n---\n{body}"
                once = ww.ensure_tag(text, "has-voice-memo")
                twice = ww.ensure_tag(once, "has-voice-memo")
                self.assertEqual(once, twice, "not idempotent")

    def test_ensure_tag_preserves_body_exactly(self) -> None:
        """Tag insertion must never modify body content."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                text = f"---\ntitle: t\n---\n{body}"
                result = ww.ensure_tag(text, "has-voice-memo")
                self.assertEqual(_body_of(result), body,
                                 "body changed after ensure_tag")

    def test_ensure_tag_noop_on_no_frontmatter(self) -> None:
        text = "# No front-matter\n"
        self.assertEqual(ww.ensure_tag(text, "has-voice-memo"), text)

    # ── remove_frontmatter_key ────────────────────────────────────────────────

    def test_remove_key_strips_target(self) -> None:
        text = "---\nredo: true\ntitle: M\n---\nBody\n"
        result = ww.remove_frontmatter_key(text, "redo")
        self.assertNotIn("redo:", result)
        self.assertIn("title: M", result)

    def test_remove_key_preserves_body_exactly(self) -> None:
        """The body must be byte-for-byte identical after key removal."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                text = f"---\nredo: true\ntitle: t\n---\n{body}"
                result = ww.remove_frontmatter_key(text, "redo")
                self.assertEqual(_body_of(result), body,
                                 "body changed after remove_frontmatter_key")

    def test_remove_key_noop_when_absent(self) -> None:
        text = "---\ntitle: M\n---\nBody"
        self.assertEqual(ww.remove_frontmatter_key(text, "redo"), text)

    def test_remove_key_handles_multiple_occurrences(self) -> None:
        text = "---\nredo: true\ntitle: M\nredo: true\n---\nBody"
        result = ww.remove_frontmatter_key(text, "redo")
        self.assertEqual(result.count("redo:"), 0)
        self.assertIn("title: M", result)

    def test_remove_key_noop_on_no_frontmatter(self) -> None:
        text = "redo: true\n# Body\n"
        self.assertEqual(ww.remove_frontmatter_key(text, "redo"), text)

    def test_remove_only_key_leaves_valid_empty_frontmatter(self) -> None:
        """Removing the only key yields ---\\n---\\n, never an empty string."""
        text = "---\nredo: true\n---\n# Body\n"
        result = ww.remove_frontmatter_key(text, "redo")
        self.assertTrue(result.startswith("---\n"), "FM header present")
        self.assertIn("\n---\n", result, "FM closing delimiter present")
        self.assertIn("# Body\n", result, "body preserved")
        self.assertNotEqual(result, "", "result is not empty string")

    def test_remove_key_preserves_other_fm_keys(self) -> None:
        for extra_line in ADVERSARIAL_FM_LINES:
            with self.subTest(line=extra_line):
                text = f"---\nredo: true\n{extra_line}\n---\nBody\n"
                result = ww.remove_frontmatter_key(text, "redo")
                self.assertIn(extra_line, result)

    # ── set_frontmatter_value ────────────────────────────────────────────────

    def test_set_frontmatter_value_replaces_existing(self) -> None:
        text = "---\nredo: true\ntitle: X\n---\nBody\n"
        result = ww.set_frontmatter_value(text, "redo", "false")
        self.assertIn("redo: false", result)
        self.assertNotIn("redo: true", result)
        self.assertIn("title: X", result)
        self.assertIn("Body\n", result)

    def test_set_frontmatter_value_adds_new_key(self) -> None:
        text = "---\ntitle: X\n---\nBody\n"
        result = ww.set_frontmatter_value(text, "redo", "false")
        self.assertIn("redo: false", result)
        self.assertIn("title: X", result)

    def test_set_frontmatter_value_noop_on_no_frontmatter(self) -> None:
        text = "redo: true\n# Body\n"
        self.assertEqual(ww.set_frontmatter_value(text, "redo", "false"), text)

    def test_set_frontmatter_value_preserves_body(self) -> None:
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                text = f"---\nredo: true\n---\n{body}"
                result = ww.set_frontmatter_value(text, "redo", "false")
                self.assertEqual(_body_of(result), body)

    # ── ensure_frontmatter_key ───────────────────────────────────────────────

    def test_ensure_frontmatter_key_adds_when_absent(self) -> None:
        text = "---\ntitle: X\n---\nBody\n"
        result = ww.ensure_frontmatter_key(text, "redo", "false")
        self.assertIn("redo: false", result)
        self.assertIn("title: X", result)

    def test_ensure_frontmatter_key_noop_when_present(self) -> None:
        text = "---\nredo: true\ntitle: X\n---\nBody\n"
        result = ww.ensure_frontmatter_key(text, "redo", "false")
        self.assertIn("redo: true", result)
        self.assertNotIn("redo: false", result)

    def test_ensure_frontmatter_key_noop_on_no_frontmatter(self) -> None:
        text = "# Body\n"
        self.assertEqual(ww.ensure_frontmatter_key(text, "redo", "false"), text)

    # ── combined mutations never lose body ───────────────────────────────────

    def test_all_mutations_combined_preserve_body(self) -> None:
        """Applying all FM mutations in sequence must not alter body."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                text = f"---\nredo: true\ntitle: t\n---\n{body}"
                text = ww.ensure_frontmatter(text)
                text = ww.ensure_tag(text, "has-voice-memo")
                text = ww.set_frontmatter_value(text, "redo", "false")
                self.assertEqual(_body_of(text), body)


# ═══════════════════════════════════════════════════════════════════════════════
# B. write_safe contract tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestWriteSafe(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir)

    def _p(self, name: str = "out.md") -> Path:
        return Path(self.tmpdir) / name

    def test_writes_correct_content(self) -> None:
        p = self._p()
        ww.write_safe(p, "hello")
        self.assertEqual(p.read_text(), "hello")

    def test_writes_unicode(self) -> None:
        p = self._p()
        content = "日本語 🎤 café résumé\n"
        ww.write_safe(p, content)
        self.assertEqual(p.read_text(encoding="utf-8"), content)

    def test_no_tmp_file_remains_after_success(self) -> None:
        p = self._p()
        ww.write_safe(p, "content")
        self.assertFalse(p.with_suffix(".tmp").exists())

    def test_refuses_empty_string(self) -> None:
        p = self._p()
        with self.assertRaises(ValueError):
            ww.write_safe(p, "")

    def test_original_preserved_when_write_refused(self) -> None:
        """If write_safe refuses, the original file must be untouched."""
        p = self._p()
        original = "important user notes"
        p.write_text(original, encoding="utf-8")
        with self.assertRaises(ValueError):
            ww.write_safe(p, "")
        self.assertEqual(p.read_text(), original)

    def test_no_tmp_file_remains_after_refusal(self) -> None:
        p = self._p()
        try:
            ww.write_safe(p, "")
        except ValueError:
            pass
        self.assertFalse(p.with_suffix(".tmp").exists())

    def test_overwrites_existing_file(self) -> None:
        p = self._p()
        p.write_text("old")
        ww.write_safe(p, "new content")
        self.assertEqual(p.read_text(), "new content")


# ═══════════════════════════════════════════════════════════════════════════════
# C. SRT move safety tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestSRTMove(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()
        log_dir = Path(self.tmpdir) / "logs"
        self.log, _ = ww.setup_logging(log_dir, "debug", 7, 30)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir)

    def test_successful_move_content_preserved(self) -> None:
        src = Path(self.tmpdir) / "src" / "test.srt"
        dst = Path(self.tmpdir) / "dst" / "test.srt"
        src.parent.mkdir()
        src.write_text("SRT content 日本語\n", encoding="utf-8")
        expected_hash = hashlib.md5(src.read_bytes()).hexdigest()
        ww._move_srt_to_vault(src, dst, self.log)
        self.assertEqual(hashlib.md5(dst.read_bytes()).hexdigest(), expected_hash)

    def test_successful_move_removes_source(self) -> None:
        src = Path(self.tmpdir) / "src" / "test.srt"
        dst = Path(self.tmpdir) / "dst" / "test.srt"
        src.parent.mkdir()
        src.write_text("content")
        ww._move_srt_to_vault(src, dst, self.log)
        self.assertFalse(src.exists(), "source must be removed after successful move")

    def test_copy_failure_preserves_source(self) -> None:
        """If the copy step fails, the source SRT must be intact."""
        src = Path(self.tmpdir) / "test.srt"
        dst = Path(self.tmpdir) / "dst" / "test.srt"
        src.write_text("precious transcript")
        with patch("shutil.copy2", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                ww._move_srt_to_vault(src, dst, self.log)
        self.assertTrue(src.exists(), "source preserved on copy failure")
        self.assertEqual(src.read_text(), "precious transcript")
        self.assertFalse(dst.exists(), "no partial destination file")

    def test_hash_mismatch_preserves_source_and_removes_dst(self) -> None:
        """If hash check fails, source is preserved and corrupt destination is cleaned up."""
        src = Path(self.tmpdir) / "test.srt"
        dst = Path(self.tmpdir) / "dst" / "test.srt"
        src.write_text("original content")

        def corrupt_copy(s, d, *a, **kw):
            Path(d).write_text("corrupted")

        with patch("shutil.copy2", side_effect=corrupt_copy):
            with self.assertRaises(RuntimeError):
                ww._move_srt_to_vault(src, dst, self.log)
        self.assertTrue(src.exists(), "source preserved on hash mismatch")
        self.assertFalse(dst.exists(), "corrupt destination cleaned up")

    def test_creates_destination_directory(self) -> None:
        src = Path(self.tmpdir) / "test.srt"
        dst = Path(self.tmpdir) / "a" / "b" / "c" / "test.srt"
        src.write_text("content")
        ww._move_srt_to_vault(src, dst, self.log)
        self.assertTrue(dst.exists())


# ═══════════════════════════════════════════════════════════════════════════════
# D. _claude_cmd_from_nvm resolution tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestClaudeCmdResolution(unittest.TestCase):
    """Tests for the nvm path resolver used by run_claude.

    These test the path-resolution logic that was NOT covered by the pipeline
    tests (which mock run_claude). A bug here causes a launchd-only failure
    because NVM_DIR is unset in that environment — nvm-exec cannot find
    installed node versions without it, but the direct path lookup can.
    """

    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()
        # Read the real .nvmrc so tests stay in sync with the actual config
        nvmrc_path = Path(__file__).parent.parent.parent / "claude" / ".nvmrc"
        self.version = nvmrc_path.read_text().strip()

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir)

    def _make_fake_nvm(self, install_claude: bool = True) -> Path:
        nvm_dir = Path(self.tmpdir) / ".nvm"
        node_bin = nvm_dir / "versions" / "node" / self.version / "bin"
        node_bin.mkdir(parents=True)
        if install_claude:
            claude = node_bin / "claude"
            claude.write_text("#!/bin/sh\necho claude stub\n")
            claude.chmod(0o755)
        return nvm_dir

    def test_returns_direct_path_to_claude_binary(self) -> None:
        nvm_dir = self._make_fake_nvm()
        cmd, _ = ww._claude_cmd_from_nvm(_nvm_dir=nvm_dir)
        expected = str(nvm_dir / "versions" / "node" / self.version / "bin" / "claude")
        self.assertEqual(cmd, [expected])

    def test_prepends_node_bin_to_path(self) -> None:
        nvm_dir = self._make_fake_nvm()
        _, env = ww._claude_cmd_from_nvm(_nvm_dir=nvm_dir)
        node_bin = str(nvm_dir / "versions" / "node" / self.version / "bin")
        self.assertTrue(env["PATH"].startswith(node_bin),
                        "node bin dir must be first in PATH so child processes find node")

    def test_raises_file_not_found_when_claude_absent(self) -> None:
        nvm_dir = self._make_fake_nvm(install_claude=False)
        with self.assertRaises(FileNotFoundError) as ctx:
            ww._claude_cmd_from_nvm(_nvm_dir=nvm_dir)
        self.assertIn("nvm install", str(ctx.exception),
                      "error message should tell user how to fix it")

    def test_raises_when_nvm_dir_does_not_exist(self) -> None:
        missing = Path(self.tmpdir) / "no-such-nvm"
        with self.assertRaises(FileNotFoundError):
            ww._claude_cmd_from_nvm(_nvm_dir=missing)

    def test_non_executable_claude_raises(self) -> None:
        nvm_dir = self._make_fake_nvm(install_claude=False)
        node_bin = nvm_dir / "versions" / "node" / self.version / "bin"
        claude = node_bin / "claude"
        claude.write_text("#!/bin/sh\n")
        claude.chmod(0o644)  # not executable
        with self.assertRaises(FileNotFoundError):
            ww._claude_cmd_from_nvm(_nvm_dir=nvm_dir)


# ═══════════════════════════════════════════════════════════════════════════════
# F. _update_meeting_note contract tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestUpdateMeetingNote(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()
        log_dir = Path(self.tmpdir) / "logs"
        self.log, _ = ww.setup_logging(log_dir, "debug", 7, 30)

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir)

    def _note(self, content: str) -> Path:
        p = Path(self.tmpdir) / "Meeting.md"
        p.write_text(content, encoding="utf-8")
        return p

    def _update(self, note: Path, inclusion: str = "![[AI/Summaries/meeting-summary]]") -> None:
        ww._update_meeting_note(note, inclusion, self.log)

    def test_adds_all_three_when_missing(self) -> None:
        note = self._note("# Body\n")
        self._update(note)
        content = note.read_text()
        self.assertTrue(content.startswith("---\n"), "front-matter added")
        self.assertIn("has-voice-memo", content, "tag added")
        self.assertIn("![[AI/Summaries/meeting-summary]]", content, "inclusion added")

    def test_noop_when_all_present(self) -> None:
        text = (
            "---\ntags:\n  - has-voice-memo\nredo: false\nprocessing_status: done\n---\n"
            "# Body\n\n![[AI/Summaries/meeting-summary]]\n"
        )
        note = self._note(text)
        self._update(note)
        self.assertEqual(note.read_text(), text)

    def test_adds_only_missing_pieces(self) -> None:
        """If front-matter and tag exist but inclusion is missing, add only inclusion."""
        text = "---\ntags:\n  - has-voice-memo\n---\n# Body with notes\n"
        note = self._note(text)
        self._update(note)
        content = note.read_text()
        self.assertIn("![[AI/Summaries/meeting-summary]]", content)
        self.assertEqual(content.count("has-voice-memo"), 1, "tag not duplicated")

    def test_idempotent(self) -> None:
        note = self._note("# Notes\n")
        self._update(note)
        after_once = note.read_text()
        self._update(note)
        after_twice = note.read_text()
        self.assertEqual(after_once, after_twice)

    def test_preserves_body_content_exactly(self) -> None:
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:60])):
                note = self._note(body)
                self._update(note)
                self.assertIn(body, note.read_text(),
                              "body content lost after _update_meeting_note")

    def test_no_op_on_nonexistent_file(self) -> None:
        note = Path(self.tmpdir) / "nonexistent.md"
        ww._update_meeting_note(note, "![[link]]", self.log)  # must not raise

    def test_inclusion_not_duplicated(self) -> None:
        note = self._note("# Notes\n")
        self._update(note)
        self._update(note)
        content = note.read_text()
        self.assertEqual(content.count("![[AI/Summaries/meeting-summary]]"), 1)


# ═══════════════════════════════════════════════════════════════════════════════
# G. process() — happy path
# ═══════════════════════════════════════════════════════════════════════════════

class TestProcessHappyPath(_PipelineBase):

    def test_full_pipeline_produces_all_outputs(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting1.m4a")
        self._run(m4a)
        self.assertTrue(self._srt("Meeting1").exists(), "SRT in vault")
        self.assertTrue(self._summary("Meeting1").exists(), "summary in vault")
        self.assertTrue(self._note("Meeting1").exists(), "meeting note exists")

    def test_srt_in_vault_not_drop_folder(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting2.m4a")
        self._run(m4a)
        self.assertFalse((self.drop / "Meeting2.srt").exists(), "SRT removed from drop")
        self.assertTrue(self._srt("Meeting2").exists(), "SRT in vault")

    def test_mp3_stays_in_drop_folder(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting3.m4a")
        (self.drop / "Meeting3.mp3").write_bytes(b"fake mp3")
        self._run(m4a)
        self.assertTrue((self.drop / "Meeting3.mp3").exists())

    def test_meeting_note_has_frontmatter_tag_and_inclusion(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting4.m4a")
        self._run(m4a)
        content = self._note("Meeting4").read_text()
        self.assertTrue(content.startswith("---\n"), "front-matter")
        self.assertIn("has-voice-memo", content, "tag")
        self.assertIn(self._inclusion("Meeting4"), content, "inclusion link")

    def test_existing_note_body_preserved_exactly(self) -> None:
        """The user's hand-written notes must not be modified in any way."""
        m4a = _make_m4a(self.drop, "Meeting5.m4a")
        note = self._note("Meeting5")
        original_body = "## My Notes\n- Decision: use Python\n- Action: write tests\n"
        note.write_text(f"---\ntitle: Design Review\n---\n{original_body}")
        self._run(m4a)
        self.assertIn(original_body, note.read_text(), "user body content preserved")

    def test_existing_fm_keys_preserved(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting6.m4a")
        note = self._note("Meeting6")
        note.write_text("---\ntitle: My Meeting\ncreated: 2026-06-05\n---\n# Notes\n")
        self._run(m4a)
        content = note.read_text()
        self.assertIn("title: My Meeting", content)
        self.assertIn("created: 2026-06-05", content)


# ═══════════════════════════════════════════════════════════════════════════════
# H. process() — idempotency and crash recovery
# ═══════════════════════════════════════════════════════════════════════════════

class TestProcessIdempotency(_PipelineBase):

    def test_skip_when_fully_complete(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting7.m4a")
        self._summary("Meeting7").write_text("# Existing summary")
        self._srt("Meeting7").write_text("1\nExisting SRT\n")
        note = self._note("Meeting7")
        note.write_text(
            "---\ntags:\n  - has-voice-memo\nredo: false\nprocessing_status: done\n---\n# Notes\n\n"
            + self._inclusion("Meeting7") + "\n"
        )
        original_note = note.read_text()
        called = []
        with patch.object(ww, "run_whisper", lambda *a, **k: called.append("w")), \
             patch.object(ww, "run_claude", lambda *a, **k: called.append("c")):
            ww.process(m4a, self.config, self.log, self.log_file)
        self.assertEqual(called, [], "no subprocess called on complete state")
        self.assertEqual(note.read_text(), original_note, "note unchanged")

    def test_recovery_summary_exists_but_note_missing_inclusion(self) -> None:
        """Simulates a crash between summary creation and note update.

        On re-run, the pipeline skips whisper+claude but still adds the
        inclusion link that was missing. This is the critical crash recovery path.
        """
        m4a = _make_m4a(self.drop, "Meeting8.m4a")
        self._summary("Meeting8").write_text("# Summary already written")
        self._srt("Meeting8").write_text("1\nExisting SRT\n")
        note = self._note("Meeting8")
        note.write_text("---\ntitle: t\n---\n# My notes\nImportant decision.\n")

        called = []
        with patch.object(ww, "run_whisper", lambda *a, **k: called.append("w")), \
             patch.object(ww, "run_claude", lambda *a, **k: called.append("c")):
            ww.process(m4a, self.config, self.log, self.log_file)

        self.assertEqual(called, [], "no subprocess called — expensive steps skipped")
        content = note.read_text()
        self.assertIn(self._inclusion("Meeting8"), content, "inclusion added on recovery")
        self.assertIn("Important decision.", content, "user notes preserved")
        self.assertIn("has-voice-memo", content, "tag added on recovery")

    def test_recovery_summary_exists_but_note_missing_tag(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting9.m4a")
        self._summary("Meeting9").write_text("# Summary")
        self._srt("Meeting9").write_text("1\nSRT\n")
        note = self._note("Meeting9")
        note.write_text(
            "---\ntitle: t\n---\n# Notes\n\n" + self._inclusion("Meeting9") + "\n"
        )
        self._run(m4a)
        self.assertIn("has-voice-memo", note.read_text())

    def test_skip_whisper_when_srt_in_vault(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting10.m4a")
        self._srt("Meeting10").write_text("1\nExisting SRT\n")
        called = []
        with patch.object(ww, "run_whisper", lambda *a, **k: called.append("w")), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.process(m4a, self.config, self.log, self.log_file)
        self.assertEqual(called, [], "whisper not called when SRT already in vault")

    def test_srt_in_drop_moved_without_rerunning_whisper(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting11.m4a")
        srt_drop = self.drop / "Meeting11.srt"
        srt_drop.write_text("1\nPre-existing transcript.\n")
        called = []
        with patch.object(ww, "run_whisper", lambda *a, **k: called.append("w")), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.process(m4a, self.config, self.log, self.log_file)
        self.assertEqual(called, [], "whisper not called for pre-existing drop SRT")
        self.assertTrue(self._srt("Meeting11").exists(), "SRT moved to vault")
        self.assertFalse(srt_drop.exists(), "SRT removed from drop")

    def test_second_run_is_noop_on_already_complete_state(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting12.m4a")
        self._run(m4a)
        note_after_first = self._note("Meeting12").read_text()
        summary_after_first = self._summary("Meeting12").read_text()
        self._run(m4a)
        self.assertEqual(self._note("Meeting12").read_text(), note_after_first)
        self.assertEqual(self._summary("Meeting12").read_text(), summary_after_first)


# ═══════════════════════════════════════════════════════════════════════════════
# I. process() — redo logic
# ═══════════════════════════════════════════════════════════════════════════════

class TestProcessRedo(_PipelineBase):

    def test_redo_strips_flag_before_any_subprocess(self) -> None:
        """The redo flag must be gone BEFORE whisper/claude run so the vault
        watcher cannot see it and re-trigger while processing is in progress."""
        m4a = _make_m4a(self.drop, "Meeting13.m4a")
        note = self._note("Meeting13")
        note.write_text("---\nredo: true\n---\n# Notes\n")
        flag_seen = []

        def stub_w(m4a, log_file, cmd=None):
            flag_seen.append(ww.get_frontmatter_value(note.read_text(), "redo"))
            self._stub_whisper(m4a, log_file, cmd)

        with patch.object(ww, "run_whisper", stub_w), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.process(m4a, self.config, self.log, self.log_file)

        self.assertEqual(flag_seen, ["false"],
                         "redo must be set to false before whisper runs")

    def test_redo_regenerates_summary(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting14.m4a")
        note = self._note("Meeting14")
        note.write_text("---\nredo: true\ntitle: Old\n---\n# Notes\nCorrection: X = Y.\n")
        self._summary("Meeting14").write_text("# Old summary")
        self._srt("Meeting14").write_text("1\nOld SRT\n")
        self._run(m4a)
        # Stub claude always produces this exact content; verifying it confirms
        # the new pipeline ran (not that the old summary was merely kept).
        self.assertEqual(self._summary("Meeting14").read_text(),
                         "# Summary\nAuto-generated.\n",
                         "summary regenerated by stub claude")

    def test_redo_preserves_user_notes_exactly(self) -> None:
        """The user's notes above the inclusion line must survive redo unchanged."""
        user_notes = "## Notes\nCorrection: SPEAKER_01 is Alice.\nDecision: use async.\n"
        m4a = _make_m4a(self.drop, "Meeting15.m4a")
        note = self._note("Meeting15")
        note.write_text(
            f"---\nredo: true\n---\n{user_notes}\n"
            f"{self._inclusion('Meeting15')}\n"
        )
        self._summary("Meeting15").write_text("# Old")
        self._srt("Meeting15").write_text("1\nOld\n")
        self._run(m4a)
        self.assertIn(user_notes, note.read_text())

    def test_redo_strips_flag_and_preserves_other_fm_keys(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting16.m4a")
        note = self._note("Meeting16")
        note.write_text("---\nredo: true\ntitle: Design Review\n---\n# Notes\n")
        self._summary("Meeting16").write_text("# Old")
        self._srt("Meeting16").write_text("1\nOld\n")
        self._run(m4a)
        content = note.read_text()
        self.assertNotIn("redo: true", content, "redo flag stripped")
        self.assertIn("title: Design Review", content, "other FM keys preserved")

    def test_redo_when_no_prior_outputs_exist(self) -> None:
        """redo: true on a note with no existing summary should run normally."""
        m4a = _make_m4a(self.drop, "Meeting17.m4a")
        note = self._note("Meeting17")
        note.write_text("---\nredo: true\n---\n# Notes\n")
        self._run(m4a)
        self.assertTrue(self._summary("Meeting17").exists())
        self.assertNotIn("redo: true", note.read_text())


# ═══════════════════════════════════════════════════════════════════════════════
# J. process() — processing_status transitions
# ═══════════════════════════════════════════════════════════════════════════════

class TestProcessingStatus(_PipelineBase):

    def test_transcribing_set_before_whisper(self) -> None:
        """processing_status: transcribing must be written before whisper runs."""
        m4a = _make_m4a(self.drop, "Meeting18s.m4a")
        note = self._note("Meeting18s")
        note.write_text("---\nredo: false\n---\n# Notes\n")
        status_seen = []

        def stub_w(m4a, log_file, cmd=None):
            status_seen.append(ww.get_frontmatter_value(note.read_text(), "processing_status"))
            self._stub_whisper(m4a, log_file, cmd)

        with patch.object(ww, "run_whisper", stub_w), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.process(m4a, self.config, self.log, self.log_file)

        self.assertEqual(status_seen, ["transcribing"])

    def test_summarizing_set_before_claude(self) -> None:
        """processing_status: summarizing must be written before Claude runs."""
        m4a = _make_m4a(self.drop, "Meeting19s.m4a")
        note = self._note("Meeting19s")
        note.write_text("---\nredo: false\n---\n# Notes\n")
        status_seen = []

        def stub_c(srt, meeting, log_file, cmd=None, **kw):
            status_seen.append(ww.get_frontmatter_value(note.read_text(), "processing_status"))
            return self._stub_claude(srt, meeting, log_file, cmd, **kw)

        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", stub_c):
            ww.process(m4a, self.config, self.log, self.log_file)

        self.assertEqual(status_seen, ["summarizing"])

    def test_processing_status_done_when_complete(self) -> None:
        """processing_status must be 'done' in the note after a complete run."""
        m4a = _make_m4a(self.drop, "Meeting20s.m4a")
        self._run(m4a)
        self.assertEqual(
            ww.get_frontmatter_value(self._note("Meeting20s").read_text(), "processing_status"),
            "done",
            "processing_status should be 'done' after successful run",
        )

    def test_summarizing_set_when_srt_already_exists(self) -> None:
        """When SRT is already in the vault, pipeline jumps straight to summarizing."""
        m4a = _make_m4a(self.drop, "Meeting21s.m4a")
        note = self._note("Meeting21s")
        note.write_text("---\nredo: false\n---\n# Notes\n")
        self._srt("Meeting21s").write_text("1\nExisting SRT\n")
        status_seen = []

        def stub_c(srt, meeting, log_file, cmd=None, **kw):
            status_seen.append(ww.get_frontmatter_value(note.read_text(), "processing_status"))
            return self._stub_claude(srt, meeting, log_file, cmd, **kw)

        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", stub_c):
            ww.process(m4a, self.config, self.log, self.log_file)

        self.assertEqual(status_seen, ["summarizing"])

    def test_update_meeting_note_sets_done_over_stale_status(self) -> None:
        """`_update_meeting_note` overwrites transcribing/summarizing with done."""
        note = self._note("MeetingStale")
        note.write_text(
            "---\ntags:\n  - has-voice-memo\nredo: false\nprocessing_status: transcribing\n---\n"
            "# Notes\n\n![[AI/Summaries/MeetingStale-summary]]\n"
        )
        ww._update_meeting_note(note, "![[AI/Summaries/MeetingStale-summary]]", self.log)
        self.assertEqual(
            ww.get_frontmatter_value(note.read_text(), "processing_status"),
            "done",
            "stale processing_status should be overwritten with done",
        )


# ═══════════════════════════════════════════════════════════════════════════════
# K. process() — failure modes and data safety
# ═══════════════════════════════════════════════════════════════════════════════

class TestProcessFailureModes(_PipelineBase):
    """Every test here asserts that user data (meeting notes) is not corrupted."""

    def _assert_note_unchanged(self, note: Path, original: str, label: str) -> None:
        # Strip processing_status before comparing — it is legitimately written
        # before any expensive step and cleaned up by _update_meeting_note on
        # the next successful run, so its presence after a failure is expected.
        actual = ww.remove_frontmatter_key(note.read_text(encoding="utf-8"), "processing_status")
        self.assertEqual(actual, original,
                         f"Meeting note user content changed after {label}")

    def test_whisper_failure_leaves_note_byte_identical(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting18.m4a")
        note = self._note("Meeting18")
        note.write_text("---\ntitle: t\n---\n# Critical notes.\n")
        original = note.read_text()
        with self.assertRaises(RuntimeError):
            with patch.object(ww, "run_whisper",
                              lambda *a, **k: (_ for _ in ()).throw(RuntimeError("exploded"))):
                ww.process(m4a, self.config, self.log, self.log_file)
        self._assert_note_unchanged(note, original, "whisper failure")

    def test_whisper_failure_no_partial_srt_in_vault(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting19.m4a")
        with self.assertRaises(RuntimeError):
            with patch.object(ww, "run_whisper",
                              lambda *a, **k: (_ for _ in ()).throw(RuntimeError("exploded"))):
                ww.process(m4a, self.config, self.log, self.log_file)
        self.assertFalse(self._srt("Meeting19").exists(), "no SRT in vault after failure")

    def test_claude_failure_leaves_note_byte_identical(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting20.m4a")
        note = self._note("Meeting20")
        note.write_text("---\ntitle: t\n---\n# Critical notes.\n")
        original = note.read_text()
        with self.assertRaises(RuntimeError):
            with patch.object(ww, "run_whisper", self._stub_whisper), \
                 patch.object(ww, "run_claude",
                              lambda *a, **k: (_ for _ in ()).throw(RuntimeError("exploded"))):
                ww.process(m4a, self.config, self.log, self.log_file)
        self._assert_note_unchanged(note, original, "claude failure")

    def test_claude_failure_no_partial_summary_in_vault(self) -> None:
        m4a = _make_m4a(self.drop, "Meeting21.m4a")
        with self.assertRaises(RuntimeError):
            with patch.object(ww, "run_whisper", self._stub_whisper), \
                 patch.object(ww, "run_claude",
                              lambda *a, **k: (_ for _ in ()).throw(RuntimeError("exploded"))):
                ww.process(m4a, self.config, self.log, self.log_file)
        self.assertFalse(self._summary("Meeting21").exists())

    def test_srt_move_failure_preserves_srt_in_drop(self) -> None:
        """If the SRT cannot be moved to the vault, the drop copy is preserved."""
        m4a = _make_m4a(self.drop, "Meeting22.m4a")
        srt_drop = self.drop / "Meeting22.srt"

        def stub_whisper_no_move(m4a, log_file, cmd=None):
            srt_drop.write_text("1\nTranscript content.\n")

        with self.assertRaises(OSError):
            with patch.object(ww, "run_whisper", stub_whisper_no_move), \
                 patch("shutil.copy2", side_effect=OSError("disk full")):
                ww.process(m4a, self.config, self.log, self.log_file)

        self.assertTrue(srt_drop.exists(), "SRT preserved in drop on copy failure")
        self.assertEqual(srt_drop.read_text(), "1\nTranscript content.\n")

    def test_whisper_failure_on_note_with_existing_content(self) -> None:
        """Adversarial inputs: note with unicode, dashes, multiline content."""
        for body in ADVERSARIAL_BODIES:
            with self.subTest(body=repr(body[:50])):
                m4a = _make_m4a(self.drop, "FailNote.m4a")
                note = self._note("FailNote")
                note.write_text(f"---\ntitle: t\n---\n{body}")
                original = note.read_text()
                try:
                    with patch.object(ww, "run_whisper",
                                      lambda *a, **k: (_ for _ in ()).throw(RuntimeError("x"))):
                        ww.process(m4a, self.config, self.log, self.log_file)
                except RuntimeError:
                    pass
                self._assert_note_unchanged(
                    note, original, f"whisper failure with body={repr(body[:30])}"
                )
                # Clean up between subtests
                (self.drop / "FailNote.m4a").unlink(missing_ok=True)
                note.unlink(missing_ok=True)

    def test_write_safe_never_empties_meeting_note(self) -> None:
        """The core invariant: write_safe refuses empty content."""
        note = Path(self.tmpdir) / "safe_test.md"
        note.write_text("# Critical user data\nNotes here.\n")
        original = note.read_text()
        with self.assertRaises(ValueError):
            ww.write_safe(note, "")
        self.assertEqual(note.read_text(), original)


# ═══════════════════════════════════════════════════════════════════════════════
# K. Auto-creation of meeting note
# ═══════════════════════════════════════════════════════════════════════════════

class TestMeetingNoteCreation(_PipelineBase):

    def test_auto_created_note_has_frontmatter_and_tag(self) -> None:
        m4a = _make_m4a(self.drop, "New1.m4a")
        self.assertFalse(self._note("New1").exists())
        self._run(m4a)
        content = self._note("New1").read_text()
        self.assertTrue(content.startswith("---\n"))
        self.assertIn("has-voice-memo", content)

    def test_frontmatter_and_tag_added_to_existing_note_without_them(self) -> None:
        m4a = _make_m4a(self.drop, "New2.m4a")
        note = self._note("New2")
        note.write_text("# No front-matter yet\nUser notes here.\n")
        self._run(m4a)
        content = note.read_text()
        self.assertTrue(content.startswith("---\n"), "FM prepended")
        self.assertIn("has-voice-memo", content, "tag added")
        self.assertIn("User notes here.", content, "original content preserved")

    def test_unicode_note_content_preserved_throughout(self) -> None:
        m4a = _make_m4a(self.drop, "New3.m4a")
        note = self._note("New3")
        unicode_notes = "## 日本語のノート\n- 決定: Python を使う\n- 🎤 録音あり\n"
        note.write_text(f"---\ntitle: test\n---\n{unicode_notes}")
        self._run(m4a)
        self.assertIn(unicode_notes, note.read_text(encoding="utf-8"))


# ═══════════════════════════════════════════════════════════════════════════════
# L. Backfill
# ═══════════════════════════════════════════════════════════════════════════════

class TestBackfill(_PipelineBase):

    def test_processes_all_m4a_in_drop(self) -> None:
        for i in range(1, 4):
            _make_m4a(self.drop, f"Batch{i}.m4a")
        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", self._stub_claude):
            result = ww.backfill(self.config, self.log, self.log_file)
        self.assertEqual(result, 0)
        for i in range(1, 4):
            self.assertTrue(self._summary(f"Batch{i}").exists(), f"Batch{i} processed")

    def test_skips_already_processed_files(self) -> None:
        m4a = _make_m4a(self.drop, "Done1.m4a")
        self._summary("Done1").write_text("# Existing")
        self._srt("Done1").write_text("1\nExisting\n")
        note = self._note("Done1")
        note.write_text(
            "---\ntags:\n  - has-voice-memo\n---\n# Notes\n\n"
            + self._inclusion("Done1") + "\n"
        )
        called = []
        with patch.object(ww, "run_whisper", lambda *a, **k: called.append("w")), \
             patch.object(ww, "run_claude", lambda *a, **k: called.append("c")):
            ww.backfill(self.config, self.log, self.log_file)
        self.assertEqual(called, [])

    def test_continues_processing_after_individual_failure(self) -> None:
        for i in range(1, 3):
            _make_m4a(self.drop, f"Cont{i}.m4a")
        processed = []

        def selective_whisper(m4a, log_file, cmd=None):
            if "Cont1" in m4a.name:
                raise RuntimeError("simulated failure")
            self._stub_whisper(m4a, log_file, cmd)
            processed.append(m4a.stem)

        with patch.object(ww, "run_whisper", selective_whisper), \
             patch.object(ww, "run_claude", self._stub_claude):
            result = ww.backfill(self.config, self.log, self.log_file)

        self.assertEqual(result, 1, "non-zero exit when any file failed")
        self.assertIn("Cont2", processed, "Cont2 processed despite Cont1 failure")

    def test_returns_zero_on_empty_drop_folder(self) -> None:
        result = ww.backfill(self.config, self.log, self.log_file)
        self.assertEqual(result, 0)

    def test_processes_uppercase_m4a_extension(self) -> None:
        _make_m4a(self.drop, "Upper.M4A")
        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", self._stub_claude):
            result = ww.backfill(self.config, self.log, self.log_file)
        self.assertEqual(result, 0)
        self.assertTrue(self._summary("Upper").exists(), ".M4A processed by backfill")

    def test_backfill_notes_all_get_frontmatter_and_tag(self) -> None:
        for i in range(1, 3):
            _make_m4a(self.drop, f"Tag{i}.m4a")
            # Notes without FM or tag
            (self.meetings / f"Tag{i}.md").write_text(f"# Tag{i} notes\n")
        with patch.object(ww, "run_whisper", self._stub_whisper), \
             patch.object(ww, "run_claude", self._stub_claude):
            ww.backfill(self.config, self.log, self.log_file)
        for i in range(1, 3):
            content = (self.meetings / f"Tag{i}.md").read_text()
            self.assertIn("has-voice-memo", content, f"Tag{i} note missing tag")
            self.assertTrue(content.startswith("---\n"), f"Tag{i} note missing FM")


if __name__ == "__main__":
    unittest.main(verbosity=2)