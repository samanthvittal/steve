#!/usr/bin/env bash
set -euo pipefail

STEVE_HOME="${HOME}/.steve"
STEVE_BIN_DIR="${HOME}/.local/bin"
STEVE_BIN="${STEVE_BIN_DIR}/steve"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Steve..."

# Create directories
mkdir -p "$STEVE_HOME/commands"
mkdir -p "$STEVE_BIN_DIR"

# Copy CLI binary
cp -f "${SCRIPT_DIR}/steve" "$STEVE_BIN"
chmod +x "$STEVE_BIN"

# Copy version
cp -f "${SCRIPT_DIR}/VERSION" "${STEVE_HOME}/version"

# Copy slash commands
cp -f "${SCRIPT_DIR}/commands/"steve:*.md "${STEVE_HOME}/commands/"

# Check if ~/.local/bin is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$STEVE_BIN_DIR"; then
    echo ""
    echo "WARNING: ${STEVE_BIN_DIR} is not in your PATH."
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo ""
    echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
    echo ""
fi

STEVE_VERSION=$(cat "${STEVE_HOME}/version")
echo "Steve v${STEVE_VERSION} installed successfully."
echo ""
echo "Quick start:"
echo "  mkdir my-app && cd my-app"
echo "  steve init"
