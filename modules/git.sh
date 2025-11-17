#!/bin/bash
# Git branch and status module

get_git_status() {
  local dir="$1"

  cd "$dir" 2>/dev/null || return

  # Get git branch
  local branch=$(git -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch="no-git"
    git_info=""
  else
    # Get git status
    if git -c core.useBuiltinFSMonitor=false diff-index --quiet HEAD -- 2>/dev/null; then
      if [ -z "$(git -c core.useBuiltinFSMonitor=false status --porcelain 2>/dev/null)" ]; then
        status_symbol="✓"
      else
        status_symbol="+"  # Untracked files
      fi
    else
      status_symbol="±"  # Modified files
    fi

    # Get ahead/behind status
    local upstream=$(git -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [ -n "$upstream" ]; then
      local ahead=$(git -c core.useBuiltinFSMonitor=false rev-list --count @{upstream}..HEAD 2>/dev/null)
      local behind=$(git -c core.useBuiltinFSMonitor=false rev-list --count HEAD..@{upstream} 2>/dev/null)

      local ahead_behind=""
      if [ "$ahead" -gt 0 ]; then
        ahead_behind="↑${ahead}"
      fi
      if [ "$behind" -gt 0 ]; then
        ahead_behind="${ahead_behind}↓${behind}"
      fi
    else
      ahead_behind=""
    fi

    # Combine git info
    git_info=" ${status_symbol}"
    if [ -n "$ahead_behind" ]; then
      git_info="${git_info} ${ahead_behind}"
    fi
  fi

  # Return formatted output
  echo "🌿 ${YELLOW}${branch}${RESET}${BLUE}${git_info}${RESET}"
}
