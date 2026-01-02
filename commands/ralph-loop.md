---
description: "Start Ralph loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(bash .claude/scripts/setup-ralph-loop.sh *)"]
---

Run this command to start the Ralph loop:

bash .claude/scripts/setup-ralph-loop.sh $ARGUMENTS

Please work on the task. When you try to exit, the Ralph loop will feed the SAME PROMPT back to you for the next iteration. You'll see your previous work in files and git history, allowing you to iterate and improve.

CRITICAL RULE: If a completion promise is set, you may ONLY output it when the statement is completely and unequivocally TRUE. Do not output false promises to escape the loop.
