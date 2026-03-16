#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/TheAlexPorter/jira-sync.git"
INSTALL_DIR="${HOME}/.claude/plugins/jira-sync"

echo "Installing jira-sync plugin..."

if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation..."
  git -C "$INSTALL_DIR" pull --ff-only
else
  git clone "$REPO" "$INSTALL_DIR"
fi

echo ""
echo "Done! Start a new Claude Code session to pick up the plugin:"
echo "  claude --plugin-dir ${INSTALL_DIR}"
echo ""
echo "Or install it permanently:"
echo "  claude plugin install --path ${INSTALL_DIR} --scope user"
