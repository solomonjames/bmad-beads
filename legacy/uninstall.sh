#!/usr/bin/env bash
set -euo pipefail

# Determine target directory
TARGET=""
if [[ "${1:-}" == "--target" && -n "${2:-}" ]]; then
  TARGET="$2"
elif [[ -n "${1:-}" && "${1:-}" != -* ]]; then
  TARGET="$1"
else
  TARGET="."
fi

# Resolve to absolute path
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
  echo "Error: Target directory '$TARGET' does not exist."
  exit 1
}

echo "Uninstalling MELD from: $TARGET"

# Remove MELD formula files (regular files or symlinks)
REMOVED_FORMULAS=0
for f in "$TARGET/.beads/formulas/"meld-*.formula.toml; do
  if [[ -f "$f" || -L "$f" ]]; then
    rm "$f"
    REMOVED_FORMULAS=$((REMOVED_FORMULAS + 1))
  fi
done

# Remove MELD skills directory (regular directory or symlink)
if [[ -d "$TARGET/.beads/skills/meld" || -L "$TARGET/.beads/skills/meld" ]]; then
  rm -rf "$TARGET/.beads/skills/meld"
  echo "  Removed .beads/skills/meld/"
fi

# Remove version file
if [[ -f "$TARGET/.meld-version" ]]; then
  rm "$TARGET/.meld-version"
fi

echo ""
echo "MELD uninstalled."
echo "  Formulas removed: $REMOVED_FORMULAS"
echo "  Skills directory:  removed"
