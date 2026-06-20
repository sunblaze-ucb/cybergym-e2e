#!/usr/bin/env bash
set -euo pipefail

OUTPUT="src.tgz"
TMPFILE=$(mktemp)

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <repo_dir1> [repo_dir2 ...]"
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

tar -czf "$OUTPUT" --exclude-vcs --files-from "$TMPFILE"
rm "$TMPFILE"
