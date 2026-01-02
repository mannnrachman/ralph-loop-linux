# Ralph Loop Linux Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-green.svg)](https://www.linux.org/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Toolkit-purple.svg)](https://claude.ai/code)

A **Linux-compatible** project-level toolkit for Claude Code implementing the Ralph Wiggum technique - continuous self-referential AI development loops.

> _"Me fail English? That's unpossible!"_ - Ralph Wiggum

## What is the Ralph Wiggum Technique?

The Ralph Wiggum technique (pioneered by [Geoffrey Huntley](https://ghuntley.com/ralph/)) creates iterative AI development loops:

```bash
while true; do
  cat PROMPT.md | claude --continue
done
```

The **same prompt** is repeatedly fed to Claude. Claude sees its own previous work in files and git history, allowing it to **iteratively improve** until a task is complete.

## Requirements

- **Linux** or **macOS** (or WSL on Windows)
- **Claude Code** CLI or VSCode extension
- **jq** - JSON processor (for parsing transcripts)
- **bash** - Shell (usually pre-installed)

### Installing jq

```bash
# Ubuntu/Debian
sudo apt install jq

# Fedora/RHEL
sudo dnf install jq

# macOS
brew install jq

# Arch Linux
sudo pacman -S jq
```

## Installation

### Option 1: Automatic Installation (Recommended)

Run this from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/mannnrachman/ralph-loop-linux/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/mannnrachman/ralph-loop-linux .claude/ralph-loop-linux
bash .claude/ralph-loop-linux/install.sh
```

### Option 2: Manual Installation

1. Create the required directories:

```bash
mkdir -p .claude/commands .claude/hooks .claude/scripts
```

2. Clone or download this repository

3. Copy files to your project:

```bash
cp commands/ralph-loop.md .claude/commands/
cp commands/cancel-ralph.md .claude/commands/
cp commands/help-ralph.md .claude/commands/
cp hooks/stop-hook.sh .claude/hooks/
cp scripts/setup-ralph-loop.sh .claude/scripts/
cp settings.local.json .claude/
```

4. Make scripts executable:

```bash
chmod +x .claude/hooks/stop-hook.sh
chmod +x .claude/scripts/setup-ralph-loop.sh
```

5. Restart Claude Code

## Usage

### Start a Ralph Loop

```bash
/ralph-loop "Build a REST API for todos" --max-iterations 20 --completion-promise "API COMPLETE"
```

**Options:**

- `--max-iterations <n>` - Maximum iterations before auto-stop (default: unlimited)
- `--completion-promise '<text>'` - Promise phrase to signal completion

### Cancel a Loop

```bash
/cancel-ralph
```

### Get Help

```bash
/help-ralph
```

## How It Works

1. `/ralph-loop` creates a state file at `.claude/ralph-loop.local.md`
2. You work on the task
3. When you try to exit, the stop hook intercepts
4. The same prompt is fed back to you
5. You see your previous work in files
6. Loop continues until:
   - `<promise>YOUR_PHRASE</promise>` is detected in output
   - Max iterations reached

## Completion Promises

To signal completion, output:

```
<promise>YOUR_COMPLETION_PHRASE</promise>
```

The phrase must match exactly what you set with `--completion-promise`.

**Important:** Only output the promise when the statement is genuinely TRUE. Don't lie to exit the loop.

## Monitoring

```bash
# View current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# View full state
head -10 .claude/ralph-loop.local.md
```

## Debug Log

The stop hook writes debug logs to `.claude/ralph-debug.log` for troubleshooting. This file records:

- When the hook is triggered
- Parsed state (iteration, max_iterations, completion_promise)
- Transcript parsing results
- Success/error messages

**Cleanup:** Delete the log file if it gets too large:

```bash
rm -f .claude/ralph-debug.log
```

## Project Structure

```
ralph-loop-linux/
├── commands/
│   ├── ralph-loop.md        # /ralph-loop command
│   ├── cancel-ralph.md      # /cancel-ralph command
│   └── help-ralph.md        # /help-ralph command
├── hooks/
│   └── stop-hook.sh         # Core loop logic (bash)
├── scripts/
│   └── setup-ralph-loop.sh  # Loop initialization (bash)
├── install.sh               # Automatic installer
├── settings.local.json      # Hooks configuration
└── README.md                # This file
```

## Differences from Windows Version

| Windows Version        | Linux Version         |
| ---------------------- | --------------------- |
| `stop-hook.ps1`        | `stop-hook.sh`        |
| `setup-ralph-loop.ps1` | `setup-ralph-loop.sh` |
| `ConvertFrom-Json`     | `jq`                  |
| PowerShell             | Bash                  |

## When to Use Ralph

**Good for:**

- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement
- Greenfield projects
- Building features incrementally

**Not good for:**

- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria

## Troubleshooting

### Loop not starting

- Verify files exist in `.claude/commands/`, `.claude/hooks/`, `.claude/scripts/`
- Check that `.claude/settings.local.json` exists with correct hooks config
- Restart Claude Code VSCode extension or CLI

### Loop not stopping

- Use `/cancel-ralph` to force stop
- Manually delete `.claude/ralph-loop.local.md` in your project directory

### Permission errors

```bash
chmod +x .claude/hooks/stop-hook.sh
chmod +x .claude/scripts/setup-ralph-loop.sh
```

### Commands not detected

- Make sure `.md` files exist in `.claude/commands/`
- Restart Claude Code VSCode extension
- Check frontmatter format in command files

### jq not found

Install jq for your system (see [Installing jq](#installing-jq) section above).

## Credits

- **Original technique**: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- **Original plugin (Unix)**: [Anthropic Claude Code team](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- **Windows version**: [Arthur742Ramos](https://github.com/Arthur742Ramos/ralph-wiggum-windows) (original), [mannnrachman](https://github.com/mannnrachman/ralph-wiggum-windows) (project-level fix)
- **Linux port**: mannnrachman

## Related Links

- [Ralph Wiggum Technique (ghuntley.com)](https://ghuntley.com/ralph/)
- [Original Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- [Windows Version (Project-Level)](https://github.com/mannnrachman/ralph-wiggum-windows)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
