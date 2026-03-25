#!/bin/bash
# ============================================================================
# metrics.sh — Skill Quality Metrics Tracker
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "${HOOKS_DIR:-}" ]]; then source "$SCRIPT_DIR/utils.sh"; fi

ensure_dirs

record_score() {
  local skill_name="$1" score="$2" total="${3:-0}" passed="${4:-0}"
  local failed="${5:-0}" needs_ai="${6:-0}" iteration="${7:-0}" source="${8:-hook}"
  jq -n \
    --arg timestamp "$(timestamp_utc)" --arg skill "$skill_name" \
    --argjson score "$score" --argjson total "$total" \
    --argjson passed "$passed" --argjson failed "$failed" \
    --argjson needs_ai "$needs_ai" --argjson iteration "$iteration" \
    --arg source "$source" \
    '{timestamp: $timestamp, skill: $skill, score: $score,
      total_assertions: $total, passed: $passed, failed: $failed,
      needs_ai: $needs_ai, iteration: $iteration, source: $source}' \
    >> "$METRICS_DIR/${skill_name}.jsonl"
}

get_latest_score() {
  local f="$METRICS_DIR/${1}.jsonl"
  [[ -f "$f" ]] && tail -1 "$f" | jq -r '.score' 2>/dev/null || echo "N/A"
}

get_best_score() {
  local f="$METRICS_DIR/${1}.jsonl"
  [[ -f "$f" ]] && jq -s 'map(.score) | max' "$f" 2>/dev/null || echo "N/A"
}

get_eval_count() {
  local f="$METRICS_DIR/${1}.jsonl"
  [[ -f "$f" ]] && wc -l < "$f" | tr -d ' ' || echo "0"
}

get_trend() {
  local f="$METRICS_DIR/${1}.jsonl"
  [[ -f "$f" ]] && tail -5 "$f" | jq -s 'map(.score)' || echo "[]"
}

get_trend_direction() {
  local f="$METRICS_DIR/${1}.jsonl"
  if [[ ! -f "$f" ]] || [[ $(wc -l < "$f") -lt 2 ]]; then echo "unknown"; return; fi
  local prev curr
  prev=$(tail -2 "$f" | jq -s '.[0].score')
  curr=$(tail -2 "$f" | jq -s '.[1].score')
  if   [[ "$curr" -gt "$prev" ]]; then echo "improving"
  elif [[ "$curr" -lt "$prev" ]]; then echo "declining"
  else echo "stable"; fi
}

get_improvement_delta() {
  local f="$METRICS_DIR/${1}.jsonl"
  if [[ -f "$f" ]] && [[ $(wc -l < "$f") -ge 2 ]]; then
    echo $(( $(tail -1 "$f" | jq '.score') - $(head -1 "$f" | jq '.score') ))
  else echo "0"; fi
}