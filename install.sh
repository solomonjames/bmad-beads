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

# Validate target has .beads/ directory
if [[ ! -d "$TARGET/.beads" ]]; then
  echo "Error: Target directory does not have a .beads/ directory."
  echo "Run 'bd init' in the target project first, then re-run this script."
  exit 1
fi

echo "Installing BMAD-Beads into: $TARGET"

# Create target directories
mkdir -p "$TARGET/.beads/formulas"
mkdir -p "$TARGET/.beads/skills/bmad"

# Copy formulas
cp "$SCRIPT_DIR/formulas/"bmad-*.formula.toml "$TARGET/.beads/formulas/"
FORMULA_COUNT=$(ls "$SCRIPT_DIR/formulas/"bmad-*.formula.toml 2>/dev/null | wc -l | tr -d ' ')

# Copy skills (preserving directory structure)
cp -R "$SCRIPT_DIR/skills/bmad/"* "$TARGET/.beads/skills/bmad/"
SKILL_COUNT=$(find "$SCRIPT_DIR/skills/bmad" -type f -name '*.md' | wc -l | tr -d ' ')

# Write version file
VERSION=$(get_version)
echo "$VERSION" > "$TARGET/$VERSION_FILE"

echo ""
echo "BMAD-Beads installed successfully!"
echo "  Formulas: $FORMULA_COUNT"
echo "  Skills:   $SKILL_COUNT"
echo "  Version:  $VERSION"
echo ""
echo "Verify with: cd $TARGET && bd formula list"
