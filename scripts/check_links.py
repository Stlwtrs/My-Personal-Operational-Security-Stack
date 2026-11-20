#!/usr/bin/env python3
"""Check that every relative Markdown link in the repository points to a file
or directory that exists, and that in-repo #anchors match a heading.

External (http/https/mailto) links are not checked. Run from anywhere:

    python3 scripts/check_links.py

Exit status is 1 if any broken link is found.
"""

from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
SKIP_DIRS = {".git", "node_modules"}


def github_slug(text: str) -> str:
    """Approximate GitHub's heading-anchor algorithm."""
    text = re.sub(r"`([^`]*)`", r"\1", text)                 # inline code
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)     # links
    text = re.sub(r"<[^>]+>", "", text)                       # inline HTML
    text = unicodedata.normalize("NFKC", text).lower()
    text = "".join(ch for ch in text if ch.isalnum() or ch in " -_")
    return text.replace(" ", "-")


def strip_code(lines: list[str]) -> list[str]:
    """Drop fenced code blocks so links and headings inside them are ignored."""
    out, in_fence = [], False
    for line in lines:
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            out.append(line)
    return out


def anchors_for(path: Path, cache: dict[Path, set[str]]) -> set[str]:
    if path not in cache:
        seen: dict[str, int] = {}
        anchors: set[str] = set()
        for line in strip_code(path.read_text(encoding="utf-8").splitlines()):
            match = HEADING_RE.match(line)
            if not match:
                continue
            slug = github_slug(match.group(2))
            count = seen.get(slug, 0)
            anchors.add(slug if count == 0 else f"{slug}-{count}")
            seen[slug] = count + 1
        cache[path] = anchors
    return cache[path]


def main() -> int:
    errors: list[str] = []
    cache: dict[Path, set[str]] = {}
    md_files = sorted(
        p for p in REPO_ROOT.rglob("*.md") if not SKIP_DIRS.intersection(p.parts)
    )

    for md in md_files:
        lines = strip_code(md.read_text(encoding="utf-8").splitlines())
        for line in lines:
            line = re.sub(r"`[^`]*`", "", line)  # ignore inline code spans
            for target in LINK_RE.findall(line):
                if re.match(r"^[a-z][a-z0-9+.-]*:", target, re.I):
                    continue  # external scheme (http, https, mailto, ...)
                file_part, _, fragment = target.partition("#")
                dest = (md.parent / file_part).resolve() if file_part else md
                rel = md.relative_to(REPO_ROOT)
                if not dest.exists():
                    errors.append(f"{rel}: broken link -> {target}")
                    continue
                if fragment and dest.is_file() and dest.suffix == ".md":
                    if fragment not in anchors_for(dest, cache):
                        errors.append(f"{rel}: missing anchor -> {target}")

    if errors:
        print(f"Found {len(errors)} broken link(s):")
        for err in errors:
            print(f"  - {err}")
        return 1

    print(f"OK: checked {len(md_files)} Markdown files, no broken internal links.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
