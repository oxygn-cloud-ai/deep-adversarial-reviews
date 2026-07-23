#!/usr/bin/env bash
# DARc install.sh — Claude Code CLI skill installer
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILL_TARGET="${CLAUDE_DIR}/skills/darc"
mkdir -p "$SKILL_TARGET"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_TARGET/SKILL.md"
mkdir -p "$SKILL_TARGET/references"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cp "$REPO_ROOT/references/openai-review.sh" "$SKILL_TARGET/references/openai-review.sh"
chmod +x "$SKILL_TARGET/references/openai-review.sh"
mkdir -p "${CLAUDE_DIR}/commands"
cat > "${CLAUDE_DIR}/commands/darc.md" << 'ROUTER'
# darc — Deep Adversarial Review CLI Router
Parse the argument from: $ARGUMENTS
Route to the appropriate sub-command:
| Argument | Action |
|----------|--------|
| (empty) or `<target>` or `<number>` | Run `/darc` |
| `help`, `--help`, `-h` | Run `/darc help` |
| `doctor`, `--doctor`, `check` | Run `/darc doctor` |
| `version`, `--version`, `-v` | Run `/darc version` |
Invoke the matching skill using the Skill tool.
ROUTER
# Ensure user-level availability. If CLAUDE_CONFIG_DIR points elsewhere (e.g. /workspace/.claude),
# the command is only available within that scope. Symlink into $HOME/.claude/commands/ so /darc
# works everywhere on the machine.
USER_COMMANDS="${HOME}/.claude/commands"
if [ "${CLAUDE_DIR}/commands" != "${USER_COMMANDS}" ]; then
  mkdir -p "${USER_COMMANDS}"
  ln -sf "${CLAUDE_DIR}/commands/darc.md" "${USER_COMMANDS}/darc.md"
fi
echo "DARc v1.0.0 installed to ${CLAUDE_DIR}"
