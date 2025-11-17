#!/bin/bash
# Main statusline composer
# Loads modules based on config and combines their output

STATUSLINE_DIR="$HOME/.claude/statusline"

# Color codes (shared across modules)
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract common values
dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_id=$(echo "$input" | jq -r '.model.id')

# Load configuration
source "$STATUSLINE_DIR/config.sh"

# Load all module files
for module in "${STATUSLINE_MODULES[@]}"; do
  source "$STATUSLINE_DIR/modules/${module}.sh"
done

# Build the statusline by calling each module's function
output=""
separator=""

for module in "${STATUSLINE_MODULES[@]}"; do
  case "$module" in
    git)
      result=$(get_git_status "$dir")
      ;;
    model)
      result=$(get_model_name "$model_id")
      ;;
    cost)
      result=$(get_session_cost "$input")
      ;;
    context)
      result=$(get_context_usage "$input")
      ;;
    warriors)
      result=$(get_warriors_game)
      ;;
    *)
      result=""
      ;;
  esac

  if [ -n "$result" ]; then
    output="${output}${separator}${result}"
    separator=" | "
  fi
done

# Print the final statusline
printf "%b" "$output"
