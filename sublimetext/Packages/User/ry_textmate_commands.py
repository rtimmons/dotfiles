import os
import re
import shutil
import subprocess

import sublime
import sublime_plugin


TRANSITION_CHEATSHEET = """# TextMate -> Sublime Cheatsheet

## First anchors

- Open this sheet: `control+shift+h`
- Set syntax to Markdown: `control+option+shift+m`
- Command palette: `cmd+shift+p`
- Search files / fuzzy open: `cmd+p`
- Find in project: `cmd+shift+f`
- Toggle side bar: `cmd+k`, then `cmd+b`

## Syntax / language switching

- TextMate muscle memory equivalent: use `cmd+shift+p`, then type `syntax markdown`
- Direct Markdown shortcut in this setup: `control+option+shift+m`
- Current file syntax menu: menu bar -> `View` -> `Syntax`

## Scratch / document feel

- New untitled file: `cmd+n`
- Sublime now keeps unsaved files on quit again
- Cheat sheet tabs open as scratch buffers, so closing them won't ask to save

## Useful migrated Ry commands

- Open terminal here: `control+option+t`
- Open finder: `control+option+f`
- Tidy Markdown: `control+q`
- Tidy Markdown without wrapping: `control+option+q`
- More Ry commands: `cmd+shift+p` and type `Ry:`

## Mental model shift

- TextMate bundles map mostly to Sublime command palette entries, snippets, and local commands
- `mate -w` behavior maps to `subl -n -w` when tools launch the editor
- The `mate` shell command still works here, but opens Sublime
"""


def error_dialog(message):
    sublime.error_message("Ry TextMate Migration\n\n{}".format(message))


def active_path(window):
    view = window.active_view()
    if view is not None and view.file_name():
        return view.file_name()

    folders = window.folders()
    if folders:
        return folders[0]

    return os.path.expanduser("~")


def active_directory(window):
    path = active_path(window)
    return path if os.path.isdir(path) else os.path.dirname(path)


def selected_regions(view, fallback_to_full_buffer=False):
    regions = [region for region in view.sel() if not region.empty()]
    if regions:
        return regions

    if fallback_to_full_buffer:
        return [sublime.Region(0, view.size())]

    return list(view.sel())


def replace_regions(view, edit, replacements):
    for region, text in sorted(replacements, key=lambda item: item[0].begin(), reverse=True):
        view.replace(edit, region, text)


def split_items(text, chomp=False):
    items = []
    for piece in re.split(r"\s*,\s*|\n", text):
        item = piece.strip()
        if chomp:
            item = re.sub(r"\s+", "", item)
        if item:
            items.append(item)
    return items


def quote_item(item, quote):
    if quote == "single":
        return "'{}'".format(item)
    if quote == "double":
        return '"{}"'.format(item)
    return item


def group_sort_key(group):
    first_line = group.splitlines()[0] if group.splitlines() else ""
    return first_line.lower()


class RyOpenTerminalHereCommand(sublime_plugin.WindowCommand):
    def run(self):
        cwd = active_directory(self.window)
        script = (
            'tell application "Terminal"\n'
            'activate\n'
            'do script "cd " & quoted form of "{}"\n'
            "end tell\n"
        ).format(cwd.replace("\\", "\\\\").replace('"', '\\"'))
        subprocess.run(["osascript", "-e", script], check=False)


class RyOpenTransitionCheatsheetCommand(sublime_plugin.WindowCommand):
    def run(self):
        target_name = "TextMate -> Sublime Cheatsheet"

        for view in self.window.views():
            if view.name() == target_name:
                self.window.focus_view(view)
                view.set_read_only(False)
                view.run_command("select_all")
                view.run_command("left_delete")
                view.run_command("append", {"characters": TRANSITION_CHEATSHEET})
                view.set_scratch(True)
                view.assign_syntax("Packages/Markdown/Markdown.sublime-syntax")
                view.set_read_only(True)
                return

        view = self.window.new_file()
        view.set_name(target_name)
        view.set_scratch(True)
        view.assign_syntax("Packages/Markdown/Markdown.sublime-syntax")
        view.run_command("append", {"characters": TRANSITION_CHEATSHEET})
        view.set_read_only(True)


class RyOpenFinderCommand(sublime_plugin.WindowCommand):
    def run(self):
        path = active_path(self.window)
        command = ["open", path] if os.path.isdir(path) else ["open", "-R", path]
        subprocess.run(command, check=False)


class RyOpenInMarkedCommand(sublime_plugin.WindowCommand):
    def run(self):
        path = active_path(self.window)
        app_name = "Marked 2" if os.path.exists("/Applications/Marked 2.app") else "Marked"
        subprocess.run(["open", "-a", app_name, path], check=False)


class RyOpenInFirefoxCommand(sublime_plugin.WindowCommand):
    def run(self):
        path = active_path(self.window)
        subprocess.run(["open", "-a", "Firefox", path], check=False)


class RyOpenInTexteditCommand(sublime_plugin.WindowCommand):
    def run(self):
        path = active_path(self.window)
        subprocess.run(["open", "-a", "TextEdit", path], check=False)


class RyTidyMarkdownCommand(sublime_plugin.TextCommand):
    def run(self, edit, wrap=True):
        if shutil.which("pandoc") is None:
            error_dialog("pandoc is not installed, so Tidy Markdown is unavailable.")
            return

        replacements = []
        command = ["pandoc", "-f", "markdown", "-t", "gfm", "--reference-links"]
        if not wrap:
            command.append("--wrap=none")

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            text = self.view.substr(region)
            result = subprocess.run(
                command,
                input=text,
                text=True,
                capture_output=True,
                check=False,
            )
            if result.returncode != 0:
                error_dialog(result.stderr.strip() or "pandoc failed to format the selection.")
                return
            replacements.append((region, result.stdout))

        replace_regions(self.view, edit, replacements)


class RySetMarkdownSyntaxCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        self.view.assign_syntax("Packages/Markdown/Markdown.sublime-syntax")
        sublime.status_message("Syntax set to Markdown")


class RyUnderlineAboveCommand(sublime_plugin.TextCommand):
    def run(self, edit, character="-"):
        replacements = []

        for region in self.view.sel():
            line = self.view.line(region.begin())
            if line.begin() == 0:
                continue

            previous_line = self.view.line(line.begin() - 1)
            previous_text = self.view.substr(previous_line).strip()
            underline = character * len(previous_text)
            replacements.append((line, underline))

        replace_regions(self.view, edit, replacements)


class RyCommaListCommand(sublime_plugin.TextCommand):
    def run(self, edit, quote=None, chomp=False):
        replacements = []

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            items = split_items(self.view.substr(region), chomp=chomp)
            text = ", ".join(quote_item(item, quote) for item in items)
            replacements.append((region, text))

        replace_regions(self.view, edit, replacements)


class RyFormatCsvCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        replacements = []

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            lines = [line for line in self.view.substr(region).splitlines() if line.strip()]
            if len(lines) < 2:
                continue

            headers = [column.strip().strip('"') for column in lines[0].split("|")]
            rows = []
            for line in lines[1:]:
                values = [column.strip().strip('"') for column in line.split("|")]
                pairs = zip(headers, values)
                rows.append(
                    "\n".join(
                        "{}  {}".format(key.rjust(38), value)
                        for key, value in sorted(pairs, key=lambda item: item[0])
                    )
                )

            replacements.append((region, "\n\n".join(rows)))

        replace_regions(self.view, edit, replacements)


class RyKeepOnlyFirstWordCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        replacements = []

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            output = []
            for line in self.view.substr(region).splitlines():
                parts = line.split()
                output.append(parts[0] if parts else "")
            replacements.append((region, "\n".join(output)))

        replace_regions(self.view, edit, replacements)


class RyRemoveNumberOnlyLinesCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        replacements = []

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            lines = [
                line
                for line in self.view.substr(region).splitlines()
                if not re.fullmatch(r"\d+\s*", line)
            ]
            replacements.append((region, "\n".join(lines)))

        replace_regions(self.view, edit, replacements)


class RySortUniqLineGroupsCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        replacements = []

        for region in selected_regions(self.view, fallback_to_full_buffer=True):
            groups = []
            current = []

            for line in self.view.substr(region).splitlines():
                normalized = line.replace("\t", "    ")
                if normalized.strip() == "":
                    continue
                if normalized[:1].isspace():
                    if current:
                        current.append(normalized)
                    continue
                if current:
                    groups.append("\n".join(current))
                current = [normalized]

            if current:
                groups.append("\n".join(current))

            unique_groups = sorted(set(groups), key=group_sort_key)
            replacements.append((region, "\n\n".join(unique_groups)))

        replace_regions(self.view, edit, replacements)
