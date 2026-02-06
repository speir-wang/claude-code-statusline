#!/bin/bash
# Context window usage module

get_context_usage() {
  local input="$1"

  # Use Claude Code's built-in pre-calculated percentage
  local used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

  if [ -z "$used_pct" ]; then
    echo "🧠 N/A"
    return
  fi

  # Round to integer
  used_pct=$(printf '%.0f' "$used_pct")

  # Dynamic color based on percentage
  local context_color
  if [ "$used_pct" -lt 50 ]; then
    context_color=$GREEN
  elif [ "$used_pct" -lt 75 ]; then
    context_color=$YELLOW
  else
    context_color=$RED
  fi

  echo "🧠 ${context_color}${used_pct}%${RESET}"
}
