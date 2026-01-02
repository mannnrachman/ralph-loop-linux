---
description: "Cancel active Ralph loop"
allowed-tools: ["Bash"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

```!
if [[ -f .claude/ralph-loop.local.md ]]; then
  iteration=$(grep -oP 'iteration:\s*\K\d+' .claude/ralph-loop.local.md 2>/dev/null || echo "unknown")
  echo "FOUND_LOOP=true"
  echo "ITERATION=$iteration"
else
  echo "FOUND_LOOP=false"
fi
```

Check the output above:

1. **If FOUND_LOOP=false**:
   - Say "No active Ralph loop found."

2. **If FOUND_LOOP=true**:
   - Use Bash: `rm -f .claude/ralph-loop.local.md`
   - Report: "Cancelled Ralph loop (was at iteration N)" where N is the ITERATION value from above.
