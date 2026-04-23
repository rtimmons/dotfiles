#!/usr/bin/env python3

from pathlib import Path
import plistlib
import re
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parents[2]
SOURCE_DIR = ROOT / "textmate" / "RyBundle.tmbundle" / "Snippets"
TARGET_DIR = ROOT / "sublimetext" / "Packages" / "User" / "TextMate Snippets"


def slugify(name):
    slug = re.sub(r"[^A-Za-z0-9]+", "-", name).strip("-")
    return slug or "snippet"


def cdata(text):
    return text.replace("]]>", "]]]]><![CDATA[>")


def normalize_content(text):
    lines = [line.rstrip() for line in text.splitlines()]
    return "\n".join(lines)


def snippet_xml(data):
    content = normalize_content(data["content"])
    lines = [
        "<snippet>",
        "\t<content><![CDATA[{}]]></content>".format(cdata(content)),
    ]

    if data.get("tabTrigger"):
        lines.append("\t<tabTrigger>{}</tabTrigger>".format(escape(data["tabTrigger"])))

    if data.get("scope"):
        lines.append("\t<scope>{}</scope>".format(escape(data["scope"])))

    lines.append("\t<description>{}</description>".format(escape(data.get("name", ""))))
    lines.append("</snippet>")
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + "\n".join(lines) + "\n"


def main():
    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    for source_path in sorted(SOURCE_DIR.glob("*.tmSnippet")):
        with source_path.open("rb") as handle:
            data = plistlib.load(handle)

        target_name = "{}.sublime-snippet".format(slugify(data.get("name", source_path.stem)))
        target_path = TARGET_DIR / target_name
        target_path.write_text(snippet_xml(data), encoding="utf-8")


if __name__ == "__main__":
    main()
