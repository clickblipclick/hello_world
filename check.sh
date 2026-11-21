#!/bin/sh
# Checks that the changes since the last commit are additive.
#
# Additive means: new files and new lines only. No existing file may be
# deleted, renamed or replaced, and no existing line may be changed or removed.
# (Changing a line counts as removing it and adding another.)
#
# Run it before committing:  sh check.sh
# It prints "additive" and exits 0, or says what is wrong and exits 1.

cd "$(dirname "$0")" || exit 1

bad=0

# Files that were deleted, renamed, or changed type.
removed=$(git diff --no-renames --name-status HEAD | grep -v '^M' )
if [ -n "$removed" ]; then
  echo "not additive: an existing file was deleted, renamed or replaced:"
  echo "$removed"
  bad=1
fi

# Existing files that lost lines. Binary files show "-" and count as changed.
changed=$(git diff --no-renames --numstat HEAD | awk -F'\t' '$2 != "0" { print $2 "\t" $3 }')
if [ -n "$changed" ]; then
  echo "not additive: lines were changed or removed (count, file):"
  echo "$changed"
  echo "every file must keep its existing lines exactly, including the"
  echo "newline at the end of its last line."
  bad=1
fi

if [ "$bad" -eq 0 ]; then
  echo "additive"
fi
exit "$bad"
