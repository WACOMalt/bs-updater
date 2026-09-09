#!/usr/bin/env python3
"""Import docs/wiki/ into a PCBBugs knowledge space (default key: BUPI).

The runner token that builds this repository cannot reach the knowledge-base
API, so this import is a separate, human-run step.

Usage:
    export PCBBUGS_URL=https://<your-pcbbugs-host>
    export PCBBUGS_API_TOKEN=<an API token from Settings -> Access keys>
    python3 docs/import-to-bupi.py [--space BUPI] [--dry-run]

The script is idempotent: a page whose title already exists in the space is
updated in place rather than created a second time.
"""
import argparse
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.request

ROOT_TITLE = "bs-updater technical paper"
WIKI_DIR = pathlib.Path(__file__).resolve().parent / "wiki"
SKIP = {"_Sidebar.md", "_Footer.md"}


def api(base, token, path, method="GET", body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(base.rstrip("/") + path, data=data, method=method)
    req.add_header("Authorization", "Bearer " + token)
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read() or b"{}")
    except urllib.error.HTTPError as e:
        sys.exit("%s %s -> %s %s" % (method, path, e.code, e.read().decode()[:300]))


def title_of(path):
    for line in path.read_text().splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return path.stem


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--space", default="BUPI")
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    home = WIKI_DIR / "Home.md"
    chapters = sorted(f for f in WIKI_DIR.glob("*.md")
                      if f.name not in SKIP and f.name != "Home.md")
    plan = [(ROOT_TITLE, home)] + [(title_of(f), f) for f in chapters]

    if args.dry_run:
        for t, f in plan:
            print("%-40s <- %s" % (t, f.name))
        return

    base = os.environ.get("PCBBUGS_URL")
    token = os.environ.get("PCBBUGS_API_TOKEN")
    if not base or not token:
        sys.exit("Set PCBBUGS_URL and PCBBUGS_API_TOKEN first.")

    space = api(base, token, "/api/kb/spaces/by-key/" + args.space)
    space_id = space["space"]["id"]
    existing = {pg["title"]: pg for pg in space.get("pages", [])}

    ids, slugs = {}, {}
    for title, path in plan:
        parent = None if path is home else ids[ROOT_TITLE]
        if title in existing:
            page = existing[title]
            print("update  %s" % title)
        else:
            page = api(base, token, "/api/kb/pages", "POST",
                       {"spaceId": space_id, "parentId": parent, "title": title})["page"]
            print("create  %s" % title)
        ids[title] = page["id"]
        slugs[path.stem] = page["slug"]

    # The wiki uses bare page names as link targets. Rewrite them to the
    # knowledge-space addresses now that every slug is known.
    def relink(md):
        def sub(m):
            target = m.group(2)
            if target.startswith("http"):
                return m.group(0)
            stem = "Home" if target == "Home" else target
            if stem not in slugs:
                return m.group(0)
            return "[%s](/kb/%s/%s)" % (m.group(1), args.space, slugs[stem])
        return re.sub(r"\[([^\]]+)\]\(([^)]+)\)", sub, md)

    for title, path in plan:
        api(base, token, "/api/kb/pages/%s" % ids[title], "PATCH",
            {"markdown": relink(path.read_text())})
        print("content %s" % title)

    print("\nDone. %d pages in space %s." % (len(plan), args.space))


if __name__ == "__main__":
    main()
