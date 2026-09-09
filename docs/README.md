# Documentation

`docs/wiki/` holds the bs-updater technical paper. It is the source of two
published copies:

- The GitHub wiki of this repository. Each file is one wiki page. The file
  name is the page name.
- The PCBBugs knowledge space with the key `BUPI`.

The text obeys ASD-STE100, Simplified Technical English, Issue 9. Read
`docs/wiki/13-Simplified-Technical-English.md` before you change a page. It
holds the compliance statement, the declared technical names and the rules
for a new page.

## How to publish to the GitHub wiki

```
git clone https://github.com/WACOMalt/bs-updater.wiki.git
cp docs/wiki/*.md bs-updater.wiki/
cd bs-updater.wiki && git add -A && git commit && git push
```

## How to publish to the knowledge space

```
export PCBBUGS_URL=https://<your-pcbbugs-host>
export PCBBUGS_API_TOKEN=<an API token from Settings -> Access keys>
python3 docs/import-to-bupi.py
```

The script creates one parent page and 14 child pages, and then writes the
content of each page. It is idempotent: a second run updates the pages that
are present already. Use `--dry-run` to see the plan without a change, and
`--space KEY` for a different knowledge space.
