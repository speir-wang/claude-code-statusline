#!/bin/bash
# Context window usage module

get_context_usage() {
  local input="$1"

  local transcript_path=$(echo "$input" | jq -r '.transcript_path')

  if [ -f "$transcript_path" ]; then
    # Get latest assistant message's cache state
    local latest_usage=$(jq -s '[.[] | select(.type == "assistant")] | .[-1] | .message.usage | (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.output_tokens // 0)' "$transcript_path" 2>/dev/null)

    if [ -n "$latest_usage" ] && [ "$latest_usage" != "null" ] && [ "$latest_usage" -gt 0 ]; then
      # Add full buffer overhead (autocompact buffer is 45k tokens)
      local buffer_overhead=45000
      local total_tokens=$((latest_usage + buffer_overhead))
      local context_pct=$((total_tokens * 100 / 200000))

      # Dynamic color based on percentage
      local context_color
      if [ $context_pct -lt 50 ]; then
        context_color=$GREEN
      elif [ $context_pct -lt 75 ]; then
        context_color=$YELLOW
      else
        context_color=$RED
      fi

      echo "🧠 ${context_color}${context_pct}%${RESET}"
    else
      echo "🧠 N/A"
    fi
  else
    echo "🧠 N/A"
  fi
}
