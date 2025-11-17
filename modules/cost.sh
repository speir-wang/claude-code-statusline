#!/bin/bash
# Session cost module

get_session_cost() {
  local input="$1"

  local total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
  local cost_display=$(printf "U\$%.2f" "$total_cost")

  echo "💰 ${CYAN}${cost_display}${RESET}"
}
