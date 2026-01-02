---
description: "Cancel active Ralph loop"
allowed-tools: ["Bash(rm -f .claude/ralph-loop.local.md)"]
---

# Cancel Ralph

Check if Ralph loop is active and cancel it:

1. First check: cat .claude/ralph-loop.local.md 2>/dev/null || echo "NO_LOOP"

2. If file exists, run: rm -f .claude/ralph-loop.local.md

3. Report the result to the user.
