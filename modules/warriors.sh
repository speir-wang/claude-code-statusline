#!/bin/bash
# Golden State Warriors game info module

get_warriors_game() {
  local warriors_cache="/tmp/warriors_game_cache.json"
  local warriors_cache_time="/tmp/warriors_game_cache.time"
  local cache_duration=180  # 3 minutes

  # Check if cache is fresh
  local age=999999
  if [ -f "$warriors_cache_time" ]; then
    local last_fetch=$(cat "$warriors_cache_time")
    local current_time=$(date +%s)
    age=$((current_time - last_fetch))
  fi

  # Fetch fresh data if cache is stale
  if [ $age -gt $cache_duration ]; then
    curl -s "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard" > "$warriors_cache" 2>/dev/null
    date +%s > "$warriors_cache_time"
  fi

  # Parse Warriors game data
  if [ -f "$warriors_cache" ]; then
    local warriors_data=$(cat "$warriors_cache" | jq -r '
      .events[] |
      select(.competitions[0].competitors[] | (.team.abbreviation == "GSW" or .team.abbreviation == "GS")) |
      {
        status: .status.type.state,
        period: .status.period,
        clock: .status.displayClock,
        gsw_score: (.competitions[0].competitors[] | select(.team.abbreviation == "GSW" or .team.abbreviation == "GS") | .score),
        opp_abbr: (.competitions[0].competitors[] | select(.team.abbreviation != "GSW" and .team.abbreviation != "GS") | .team.abbreviation),
        opp_score: (.competitions[0].competitors[] | select(.team.abbreviation != "GSW" and .team.abbreviation != "GS") | .score),
        date: .date,
        home_away: (.competitions[0].competitors[] | select(.team.abbreviation == "GSW" or .team.abbreviation == "GS") | .homeAway)
      } |
      if .status == "in" then
        "LIVE|\(.gsw_score)-\(.opp_score) \(.opp_abbr) Q\(.period) \(.clock)"
      elif .status == "pre" then
        "NEXT|\(.date)|\(.home_away)|\(.opp_abbr)"
      elif .status == "post" then
        "FINAL|\(.gsw_score)-\(.opp_score) \(.opp_abbr)"
      else
        empty
      end
    ' 2>/dev/null | head -1)

    if [ -n "$warriors_data" ]; then
      local game_type=$(echo "$warriors_data" | cut -d'|' -f1)
      # Warriors orange color (256-color mode)
      local WARRIORS_COLOR='\033[38;5;214m'

      if [ "$game_type" = "LIVE" ]; then
        local game_info=$(echo "$warriors_data" | cut -d'|' -f2)
        # Fix clock format when under a minute (e.g., "48.0" -> "0:48")
        if [[ "$game_info" =~ ([0-9]+\.[0-9])$ ]]; then
          local seconds=$(echo "$game_info" | grep -oE '[0-9]+\.[0-9]$' | cut -d'.' -f1)
          game_info=$(echo "$game_info" | sed -E "s/[0-9]+\.[0-9]$/0:${seconds}/")
        fi
        echo "${WARRIORS_COLOR}🏀 GSW ${game_info}${RESET}"
      elif [ "$game_type" = "FINAL" ]; then
        local game_info=$(echo "$warriors_data" | cut -d'|' -f2)
        echo "${WARRIORS_COLOR}🏀 FINAL: GSW ${game_info}${RESET}"
      elif [ "$game_type" = "NEXT" ]; then
        local game_date=$(echo "$warriors_data" | cut -d'|' -f2)
        local home_away=$(echo "$warriors_data" | cut -d'|' -f3)
        local opponent=$(echo "$warriors_data" | cut -d'|' -f4)

        # Convert UTC to Melbourne time and format
        local mel_time=$(TZ=Australia/Melbourne date -j -f "%Y-%m-%dT%H:%M:%SZ" "$game_date" "+%a %-I:%M%p" 2>/dev/null || echo "TBD")

        if [ "$home_away" = "home" ]; then
          echo "${WARRIORS_COLOR}🏀 vs ${opponent} ${mel_time}${RESET}"
        else
          echo "${WARRIORS_COLOR}🏀 @ ${opponent} ${mel_time}${RESET}"
        fi
      fi
    fi
  fi
}
