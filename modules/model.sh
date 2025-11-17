#!/bin/bash
# Model name module

get_model_name() {
  local model_id="$1"

  case "$model_id" in
    *sonnet-4*)
      model_name="sonnet-4-5"
      ;;
    *sonnet*)
      model_name="sonnet-3.5"
      ;;
    *opus*)
      model_name="opus"
      ;;
    *haiku*)
      model_name="haiku"
      ;;
    *)
      model_name="claude"
      ;;
  esac

  echo "🤖 ${GREEN}${model_name}${RESET}"
}
