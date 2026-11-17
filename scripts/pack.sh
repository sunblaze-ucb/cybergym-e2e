#!/usr/bin/env bash
set -euo pipefail

OUTPUT="src.tgz"
TMPFILE=$(mktemp)

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <repo_dir1> [repo_dir2 ...]"
  exit 1
fi

if ! tar --version 2>/dev/null | grep -q 'GNU tar'; then
  echo "Error: $0 needs GNU tar (for --sort, --mtime, --owner, --mode)." >&2
  exit 1
fi

for filename in "$@"; do
  if [ -d "$filename/.git" ]; then
    echo "Adding files from $filename ..."
    (
      cd "$filename"
      git ls-files -co --exclude-standard | sed "s|^|$filename/|" >> "$TMPFILE"
    )
  elif [ -d "$filename" ]; then
    echo "Warning: No .git found in $filename, adding all files."
    echo "$filename" >> "$TMPFILE"
  elif [ -f "$filename" ]; then
    echo "Adding file $filename ..."
    echo "$filename" >> "$TMPFILE"
  fi
done

# Normalize tar headers so they do not reveal which files the task builder touched:
# fixed mtime (2026-04-01), owner 0:0 with no user/group names, mode 0644 or 0755
# (0755 for directories and anything with an exec bit; setuid/setgid/sticky dropped).
# Must match what scripts/audit_src_tgz.py checks.
# Pack source trees, not built ones: with one mtime for every file, make and ninja treat
# any shipped object or library as up to date and will not recompile edited sources.
tar --sort=name --mtime='@1775001600' --owner=0 --group=0 --numeric-owner \
    --mode='a-st,u=rwX,go=rX' -czf "$OUTPUT" --exclude-vcs --files-from "$TMPFILE"
rm "$TMPFILE"
