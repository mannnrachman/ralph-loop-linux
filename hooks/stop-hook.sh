#!/bin/bash
# Ralph Loop Stop Hook (Linux/Bash)
# Prevents session exit when a ralph-loop is active
# Feeds Claude's output back as input to continue the loop

set -e

# Read hook input from stdin (advanced stop hook API)
hook_input=$(cat)

# Check if ralph-loop is active
ralph_state_file=".claude/ralph-loop.local.md"

if [[ ! -f "$ralph_state_file" ]]; then
    # No active loop - allow exit
    exit 0
fi

# Read the state file
content=$(cat "$ralph_state_file")

# Parse YAML frontmatter (between --- markers)
frontmatter=$(echo "$content" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

if [[ -z "$frontmatter" ]]; then
    echo "Ralph loop: State file corrupted (no frontmatter found)" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Parse frontmatter values
iteration=0
max_iterations=0
completion_promise=""

while IFS= read -r line; do
    if [[ "$line" =~ ^iteration:[[:space:]]*(.+)$ ]]; then
        iteration="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^max_iterations:[[:space:]]*(.+)$ ]]; then
        max_iterations="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^completion_promise:[[:space:]]*\"?([^\"]*)\"?$ ]]; then
        completion_promise="${BASH_REMATCH[1]}"
        if [[ "$completion_promise" == "null" ]]; then
            completion_promise=""
        fi
    fi
done <<< "$frontmatter"

# Validate iteration is a valid number
if ! [[ "$iteration" =~ ^[0-9]+$ ]] || [[ "$iteration" -lt 0 ]]; then
    echo "Ralph loop: State file corrupted - 'iteration' is invalid" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Check if max iterations reached
if [[ "$max_iterations" -gt 0 ]] && [[ "$iteration" -ge "$max_iterations" ]]; then
    echo "Ralph loop: Max iterations ($max_iterations) reached."
    rm -f "$ralph_state_file"
    exit 0
fi

# Get transcript path from hook input (JSON)
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null)

if [[ -z "$transcript_path" ]]; then
    echo "Ralph loop: Failed to parse hook input as JSON" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

if [[ ! -f "$transcript_path" ]]; then
    echo "Ralph loop: Transcript file not found" >&2
    echo "Expected: $transcript_path" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Read transcript (JSONL format - one JSON per line)
# Find last assistant message
last_assistant_line=$(grep '"role"[[:space:]]*:[[:space:]]*"assistant"' "$transcript_path" | tail -1)

if [[ -z "$last_assistant_line" ]]; then
    echo "Ralph loop: No assistant messages found in transcript" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Parse the assistant message JSON and extract text content
last_output=$(echo "$last_assistant_line" | jq -r '.message.content[] | select(.type == "text") | .text' 2>/dev/null | tr '\n' ' ')

if [[ -z "$last_output" ]]; then
    echo "Ralph loop: Assistant message contained no text content" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Check for completion promise (only if set)
if [[ -n "$completion_promise" ]]; then
    # Extract text from <promise> tags
    if [[ "$last_output" =~ \<promise\>([^<]*)\</promise\> ]]; then
        promise_text="${BASH_REMATCH[1]}"
        # Normalize whitespace
        promise_text=$(echo "$promise_text" | tr -s '[:space:]' ' ' | sed 's/^ //;s/ $//')

        if [[ "$promise_text" == "$completion_promise" ]]; then
            echo "Ralph loop: Detected <promise>$completion_promise</promise>"
            rm -f "$ralph_state_file"
            exit 0
        fi
    fi
fi

# Not complete - continue loop with SAME PROMPT
next_iteration=$((iteration + 1))

# Extract prompt (everything after the closing ---)
prompt_text=$(echo "$content" | sed -n '/^---$/,/^---$/!p' | sed '1,/^---$/d')
prompt_text=$(echo "$prompt_text" | sed '/^$/d' | head -c -1)

if [[ -z "$prompt_text" ]]; then
    echo "Ralph loop: State file corrupted - no prompt text found" >&2
    rm -f "$ralph_state_file"
    exit 0
fi

# Update iteration in state file
sed -i "s/iteration:[[:space:]]*[0-9]*/iteration: $next_iteration/" "$ralph_state_file"

# Build system message
if [[ -n "$completion_promise" ]]; then
    system_msg="Ralph iteration $next_iteration | To stop: output <promise>$completion_promise</promise> (ONLY when statement is TRUE - do not lie to exit!)"
else
    system_msg="Ralph iteration $next_iteration | No completion promise set - loop runs infinitely"
fi

# Output JSON to block the stop and feed prompt back
# Escape special characters for JSON
prompt_escaped=$(echo "$prompt_text" | jq -Rs '.')
system_msg_escaped=$(echo "$system_msg" | jq -Rs '.')

echo "{\"decision\":\"block\",\"reason\":${prompt_escaped},\"systemMessage\":${system_msg_escaped}}"

exit 0
