#!/bin/bash
# Ralph Loop Setup Script (Linux/Bash)
# Creates state file for in-session Ralph loop

set -e

# Function to show help
show_help() {
    cat << 'EOF'
Ralph Loop - Interactive self-referential development loop (Linux)

USAGE:
  /ralph-loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Initial prompt to start the loop (can be multiple words without quotes)

OPTIONS:
  --max-iterations <n>           Maximum iterations before auto-stop (default: unlimited)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a Ralph loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, you must output: <promise>YOUR_PHRASE</promise>

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /ralph-loop --max-iterations 10 Fix the auth bug
  /ralph-loop Refactor cache layer  (runs forever)

STOPPING:
  Only by reaching --max-iterations or detecting --completion-promise
  No manual stop - Ralph runs infinitely by default!

MONITORING:
  # View current iteration:
  grep '^iteration:' .claude/ralph-loop.local.md

  # View full state:
  head -10 .claude/ralph-loop.local.md
EOF
    exit 0
}

# Parse arguments
prompt_parts=()
max_iterations=0
completion_promise="null"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        --max-iterations)
            shift
            if [[ -z "$1" ]]; then
                echo "Error: --max-iterations requires a number argument" >&2
                exit 1
            fi
            if ! [[ "$1" =~ ^[0-9]+$ ]]; then
                echo "Error: --max-iterations must be a positive integer or 0, got: $1" >&2
                exit 1
            fi
            max_iterations="$1"
            ;;
        --completion-promise)
            shift
            if [[ -z "$1" ]]; then
                echo "Error: --completion-promise requires a text argument" >&2
                exit 1
            fi
            completion_promise="$1"
            ;;
        *)
            prompt_parts+=("$1")
            ;;
    esac
    shift
done

# Join all prompt parts with spaces
prompt="${prompt_parts[*]}"

# Validate prompt is non-empty
if [[ -z "$prompt" ]]; then
    echo "Error: No prompt provided" >&2
    echo ""
    echo "   Ralph needs a task description to work on."
    echo ""
    echo "   Examples:"
    echo "     /ralph-loop Build a REST API for todos"
    echo "     /ralph-loop Fix the auth bug --max-iterations 20"
    echo ""
    echo "   For all options: /ralph-loop --help"
    exit 1
fi

# Create .claude directory if not exists
mkdir -p .claude

# Quote completion promise for YAML if it contains special chars or is not null
if [[ -n "$completion_promise" && "$completion_promise" != "null" ]]; then
    completion_promise_yaml="\"$completion_promise\""
else
    completion_promise_yaml="null"
fi

started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create state file for stop hook (markdown with YAML frontmatter)
cat > ".claude/ralph-loop.local.md" << EOF
---
active: true
iteration: 1
max_iterations: $max_iterations
completion_promise: $completion_promise_yaml
started_at: "$started_at"
---

$prompt
EOF

# Output setup message
if [[ "$max_iterations" -gt 0 ]]; then
    max_iter_display="$max_iterations"
else
    max_iter_display="unlimited"
fi

if [[ "$completion_promise" != "null" ]]; then
    promise_display="$completion_promise (ONLY output when TRUE - do not lie!)"
else
    promise_display="none (runs forever)"
fi

cat << EOF

Ralph loop activated in this session!

Iteration: 1
Max iterations: $max_iter_display
Completion promise: $promise_display

The stop hook is now active. When you try to exit, the SAME PROMPT will be
fed back to you. You'll see your previous work in files, creating a
self-referential loop where you iteratively improve on the same task.

To monitor: head -10 .claude/ralph-loop.local.md

WARNING: This loop cannot be stopped manually! It will run infinitely
unless you set --max-iterations or --completion-promise.


EOF

# Output the initial prompt
if [[ -n "$prompt" ]]; then
    echo ""
    echo "$prompt"
fi
