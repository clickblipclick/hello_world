#!/bin/sh
# Checks that the changes since the last commit keep the site growing.
#
# An update mostly adds. It may also change or remove a little of what is
# already there, within these limits:
#
#   - at most 20 existing lines changed or removed
#     (changing a line counts as removing it and adding another)
#   - more lines added than removed
#   - no existing file deleted, renamed or replaced
#
# Run it before committing:  sh check.sh
# It prints "ok" and exits 0, or says what is wrong and exits 1.

LIMIT=20

cd "$(dirname "$0")" || exit 1

# Let new files that are not yet staged show up in the comparison.
git add -A -N .

bad=0

# Files that were deleted, renamed, or changed type.
gone=$(git diff --no-renames --name-status HEAD | grep -v '^[AM]')
if [ -n "$gone" ]; then
  echo "not allowed: an existing file was deleted, renamed or replaced:"
  echo "$gone"
  bad=1
fi

# Existing files that are not text cannot be changed, only added.
binary=$(git diff --no-renames --diff-filter=M --numstat HEAD | awk -F'\t' '$1 == "-" { print $3 }')
if [ -n "$binary" ]; then
  echo "not allowed: an existing non-text file was replaced:"
  echo "$binary"
  bad=1
fi

counts=$(git diff --no-renames --numstat HEAD | awk -F'\t' '$1 != "-" { a += $1; d += $2 } END { print a + 0, d + 0 }')
added=${counts% *}
removed=${counts#* }

if [ "$removed" -gt "$LIMIT" ]; then
  echo "not allowed: $removed existing lines were changed or removed; the limit is $LIMIT."
  echo "(a file's last line must keep its ending newline, or it counts as changed)"
  bad=1
fi

if [ "$added" -le "$removed" ]; then
  echo "not allowed: $added lines added and $removed removed; an update must add more than it removes."
  bad=1
fi

if [ "$bad" -eq 0 ]; then
  echo "ok ($added lines added, $removed changed or removed)"
fi
exit "$bad"
