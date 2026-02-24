#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE=".bmad-beads-version"

# Resolve version from git tag or SHA
get_version() {
  cd "$SCRIPT_DIR"
  if git describe --tags --exact-match HEAD 2>/dev/null; then
    return
  fi
  git rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

# Parse arguments (flags and target in any order)
LINK=false
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --link) LINK=true ;;
    --target) ;; # handled below
    -*) echo "Unknown option: $arg"; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done

# Support legacy --target <path> form
if [[ "${1:-}" == "--target" && -n "${2:-}" ]]; then
  TARGET="$2"
fi

# Default to current directory
TARGET="${TARGET:-.}"

# Resolve to absolute path
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
  echo "Error: Target directory '$TARGET' does not exist."
  exit 1
}

# Validate target has .beads/ directory
if [[ ! -d "$TARGET/.beads" ]]; then
  echo "Error: Target directory does not have a .beads/ directory."
  echo "Run 'bd init' in the target project first, then re-run this script."
  exit 1
fi

if $LINK; then
  echo "Installing BMAD-Beads into: $TARGET (linked)"
else
  echo "Installing BMAD-Beads into: $TARGET"
fi

# Create target directories
mkdir -p "$TARGET/.beads/formulas"
mkdir -p "$TARGET/.beads/skills"

if $LINK; then
  # --- Link mode ---

  # Formulas: remove existing bmad formula files/symlinks, then symlink each file
  for f in "$TARGET/.beads/formulas/"bmad-*.formula.toml; do
    if [[ -f "$f" || -L "$f" ]]; then
      rm "$f"
    fi
  done
  for f in "$SCRIPT_DIR/formulas/"bmad-*.formula.toml; do
    ln -sf "$f" "$TARGET/.beads/formulas/"
  done

  # Skills: remove existing bmad directory/symlink, then symlink the whole directory
  if [[ -d "$TARGET/.beads/skills/bmad" || -L "$TARGET/.beads/skills/bmad" ]]; then
    rm -rf "$TARGET/.beads/skills/bmad"
  fi
  ln -sf "$SCRIPT_DIR/skills/bmad" "$TARGET/.beads/skills/bmad"
else
  # --- Copy mode (default) ---

  mkdir -p "$TARGET/.beads/skills/bmad"

  # Copy formulas
  cp "$SCRIPT_DIR/formulas/"bmad-*.formula.toml "$TARGET/.beads/formulas/"

  # Copy skills (preserving directory structure)
  cp -R "$SCRIPT_DIR/skills/bmad/"* "$TARGET/.beads/skills/bmad/"
fi

FORMULA_COUNT=$(ls "$SCRIPT_DIR/formulas/"bmad-*.formula.toml 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$SCRIPT_DIR/skills/bmad" -type f -name '*.md' | wc -l | tr -d ' ')

# Write version file
VERSION=$(get_version)
echo "$VERSION" > "$TARGET/$VERSION_FILE"

MODE=""
if $LINK; then
  MODE=" (linked)"
fi

echo ""
echo "BMAD-Beads installed successfully!$MODE"
echo "  Formulas: $FORMULA_COUNT"
echo "  Skills:   $SKILL_COUNT"
echo "  Version:  $VERSION"
echo ""
echo "Verify with: cd $TARGET && bd formula list"
