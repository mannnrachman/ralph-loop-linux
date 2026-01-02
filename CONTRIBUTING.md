# Contributing to Ralph Loop Linux

Thank you for your interest in contributing to the Ralph Loop Linux Toolkit!

## How to Contribute

### Reporting Issues

- Use the GitHub Issues page to report bugs
- Include your OS version, bash version, and jq version
- Provide steps to reproduce the issue
- Include any error messages

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style

- Use 4 spaces for indentation in bash scripts
- Follow shellcheck recommendations
- Add comments for complex logic
- Keep functions small and focused

### Testing

Before submitting:
- Test on Linux (Ubuntu/Debian preferred)
- Test on macOS if possible
- Verify jq commands work correctly
- Test with Claude Code CLI and VSCode extension

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/ralph-loop-linux
cd ralph-loop-linux

# Make scripts executable
chmod +x hooks/stop-hook.sh
chmod +x scripts/setup-ralph-loop.sh
chmod +x install.sh

# Run shellcheck (optional but recommended)
shellcheck hooks/stop-hook.sh
shellcheck scripts/setup-ralph-loop.sh
shellcheck install.sh
```

## Questions?

Open an issue with the "question" label.
