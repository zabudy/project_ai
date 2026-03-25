#!/bin/bash
# ============================================================================
# eval-engine.sh — Binary Assertion Evaluation Engine
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "${HOOKS_DIR:-}" ]]; then source "$SCRIPT_DIR/utils.sh"; fi

check_contains()         { echo "$1" | grep -qi "$2"  && echo "true" || echo "false"; }
check_not_contains()     { echo "$1" | grep -qi "$2"  && echo "false" || echo "true"; }
check_min_code_blocks()  {
  local count; count=$(echo "$1" | grep -c '```' || true)
  [[ $((count / 2)) -ge "$2" ]] && echo "true" || echo "false"
}
check_word_count_under() {
  local count; count=$(echo "$1" | wc -w | tr -d ' ')
  [[ "$count" -lt "$2" ]] && echo "true" || echo "false"
}
check_word_count_over()  {
  local count; count=$(echo "$1" | wc -w | tr -d ' ')
  [[ "$count" -gt "$2" ]] && echo "true" || echo "false"
}
check_line_count_under() {
  local count; count=$(echo "$1" | wc -l | tr -d ' ')
  [[ "$count" -lt "$2" ]] && echo "true" || echo "false"
}
check_min_bullets() {
  local count; count=$(echo "$1" | grep -c '^\s*[-*•]' || true)
  [[ "$count" -ge "$2" ]] && echo "true" || echo "false"
}

evaluate_assertion() {
  local text="$1" output="$2"
  local lower; lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')

  if echo "$lower" | grep -qE 'does not contain|must not contain|should not contain'; then
    local pat; pat=$(echo "$text" | sed -E 's/.*contain[s]? //i' | tr -d '"'"'")
    check_not_contains "$output" "$pat"; return
  fi
  if echo "$lower" | grep -qE '^output (contains|includes|has)|^contains|^must contain|^should contain'; then
    local pat; pat=$(echo "$text" | sed -E 's/.*(contains|includes|has|contain) //i' | tr -d '"'"'")
    check_contains "$output" "$pat"; return
  fi
  if echo "$lower" | grep -qE 'word count.*(under|less than|below|max)|words.*(under|less than|below|max)'; then
    local lim; lim=$(echo "$text" | grep -oE '[0-9]+' | head -1)
    [[ -n "$lim" ]] && { check_word_count_under "$output" "$lim"; return; }
  fi
  if echo "$lower" | grep -qE 'word count.*(over|more than|at least)|words.*(over|more than|at least)'; then
    local lim; lim=$(echo "$text" | grep -oE '[0-9]+' | head -1)
    [[ -n "$lim" ]] && { check_word_count_over "$output" "$lim"; return; }
  fi
  if echo "$lower" | grep -qE 'code block'; then
    local min; min=$(echo "$text" | grep -oE '[0-9]+' | head -1); min=${min:-1}
    check_min_code_blocks "$output" "$min"; return
  fi
  if echo "$lower" | grep -qE 'at least [0-9]+ bullet'; then
    local min; min=$(echo "$text" | grep -oE '[0-9]+' | head -1)
    check_min_bullets "$output" "$min"; return
  fi
  if echo "$lower" | grep -qE 'not empty'; then
    [[ -n "$(echo "$output" | tr -d '[:space:]')" ]] && echo "true" || echo "false"; return
  fi

  echo "needs_ai"
}

evaluate_output() {
  local skill_name="$1" output_text="$2"
  local eval_file; eval_file=$(skill_eval_path "$skill_name")

  if [[ ! -f "$eval_file" ]]; then
    jq -n --arg s "$skill_name" '{error: "no eval.json found", skill: $s}'
    return 1
  fi

  local total=0 passed=0 failed=0 needs_ai=0 results="[]" failed_list="[]"
  local num_tests; num_tests=$(jq '.tests | length' "$eval_file")

  for ((t=0; t<num_tests; t++)); do
    local test_name; test_name=$(jq -r ".tests[$t].name" "$eval_file")
    local num_assertions; num_assertions=$(jq ".tests[$t].assertions | length" "$eval_file")

    for ((a=0; a<num_assertions; a++)); do
      local id text category result
      id=$(jq -r ".tests[$t].assertions[$a].id" "$eval_file")
      text=$(jq -r ".tests[$t].assertions[$a].text" "$eval_file")
      category=$(jq -r ".tests[$t].assertions[$a].category" "$eval_file")
      result=$(evaluate_assertion "$text" "$output_text")

      total=$((total + 1))
      case "$result" in
        true)     passed=$((passed + 1)) ;;
        false)
          failed=$((failed + 1))
          failed_list=$(echo "$failed_list" | jq \
            --arg id "$id" --arg text "$text" --arg test "$test_name" --arg cat "$category" \
            '. + [{id: $id, text: $text, test: $test, category: $cat}]') ;;
        needs_ai) needs_ai=$((needs_ai + 1)) ;;
      esac

      results=$(echo "$results" | jq \
        --arg id "$id" --arg text "$text" --arg result "$result" --arg test "$test_name" \
        '. + [{id: $id, assertion: $text, result: $result, test: $test}]')
    done
  done

  local evaluable=$((total - needs_ai))
  local score=0
  [[ "$evaluable" -gt 0 ]] && score=$((passed * 100 / evaluable))

  jq -n \
    --arg skill "$skill_name" --arg timestamp "$(timestamp_utc)" \
    --argjson total "$total" --argjson passed "$passed" --argjson failed "$failed" \
    --argjson needs_ai "$needs_ai" --argjson score "$score" \
    --argjson results "$results" --argjson failed_list "$failed_list" \
    '{skill: $skill, timestamp: $timestamp, score: $score,
      total_assertions: $total, passed: $passed, failed: $failed,
      needs_ai_evaluation: $needs_ai, results: $results,
      failed_assertions: $failed_list}'
}