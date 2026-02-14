#!/bin/bash
# PostToolUse hook: auto-format after editing source files
set -euo pipefail

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

# Check if a .rs file was edited
if echo "$TOOL_INPUT" | grep -q '\.rs"'; then
  RUSTUP_HOME="$HOME/.rustup" cargo fmt --manifest-path "$PROJECT_DIR/src-tauri/Cargo.toml" --quiet 2>/dev/null || true
fi

# Check if a .ts/.tsx file was edited
if echo "$TOOL_INPUT" | grep -q '\.ts\(x\)\?"'; then
  pnpm --dir "$PROJECT_DIR" exec oxlint --fix "$PROJECT_DIR/src/" --quiet 2>/dev/null || true
fi
