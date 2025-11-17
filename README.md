# Claude Code Custom Statusline

A modular statusline configuration for Claude Code that displays contextual information about your development session.

## Features

- **Git Status** - Current branch, modification status, and ahead/behind counts
- **Model Info** - Which Claude model is currently active
- **Session Cost** - Running cost of the current session in USD
- **Context Usage** - Percentage of context window used with color-coded warnings
- **Sports Info** - Live NBA game scores (configurable per team)

## Installation

1. Copy the `statusline/` directory to `~/.claude/statusline/`

2. Add to your `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline/main.sh"
  }
}
```

3. Ensure scripts are executable:
```bash
chmod +x ~/.claude/statusline/*.sh
chmod +x ~/.claude/statusline/modules/*.sh
```

## Configuration

Edit `config.sh` to enable/disable modules:

```bash
# All modules enabled
STATUSLINE_MODULES=("git" "model" "cost" "context" "warriors")

# Work setup (no sports)
STATUSLINE_MODULES=("git" "model" "cost" "context")

# Minimal setup
STATUSLINE_MODULES=("git" "model" "context")
```

## Module Details

### git.sh
Displays current git branch with status indicators:
- `✓` - Clean working tree
- `+` - Untracked files present
- `±` - Modified files
- `↑N` - N commits ahead of upstream
- `↓N` - N commits behind upstream

### model.sh
Shows the active Claude model:
- `sonnet-4-5` for Claude Sonnet 4.5
- `sonnet-3.5` for Claude Sonnet 3.5
- `opus` for Claude Opus
- `haiku` for Claude Haiku

### cost.sh
Displays cumulative session cost in USD (e.g., `U$0.42`)

**Note:** Cost tracking behaves differently depending on your billing:
- **API users** - Shows actual USD spent per token (directly reflects billing)
- **Subscription users** (Pro/Max plans) - May show $0 or equivalent cost, not actual charges

If the cost display doesn't suit your needs, ask Claude Code to modify `modules/cost.sh` to adapt to your situation (e.g., track token count instead, show session duration, or remove entirely).

### context.sh
Shows context window usage as a percentage with color coding:
- Green (< 50%) - Plenty of space
- Yellow (50-75%) - Getting full
- Red (> 75%) - Consider starting a new session

### warriors.sh
Shows Golden State Warriors game information:
- Live scores with quarter info
- Final game results
- Next game schedule (in Melbourne timezone)

To customize for a different team, modify the team abbreviation in the jq query (e.g., "GSW" to "LAL" for Lakers).

## Requirements

- `jq` - JSON processor (required)
- `curl` - For fetching external APIs (sports module only)
- `git` - For git status module

## Creating Custom Modules

1. Create a new file in `modules/` (e.g., `modules/mymodule.sh`)
2. Define a function that returns formatted output:
```bash
#!/bin/bash
get_mymodule_info() {
  # Your logic here
  echo "🔧 ${GREEN}my info${RESET}"
}
```

3. Add the module to `main.sh` case statement:
```bash
mymodule)
  result=$(get_mymodule_info "$input")
  ;;
```

4. Enable it in `config.sh`:
```bash
STATUSLINE_MODULES=("git" "model" "cost" "context" "mymodule")
```

## Example Output

```
🌿 main ✓ | 🤖 sonnet-4-5 | 💰 U$0.15 | 🧠 23% | 🏀 vs LAL Sat 12:30PM
```

## License

MIT
