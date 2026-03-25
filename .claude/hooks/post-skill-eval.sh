#!/bin/bash
# ============================================================================
# post-skill-eval.sh — PostToolUse Evaluation Hook for Skill
# ============================================================================
# Fires AFTER a skill executes. Runs binary assertions, records score.
# If score < threshold, suggests /self-improve.
# Hook event: PostToolUse | Matcher: Skill
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/eval-engine.sh"
source "$SCRIPT_DIR/lib/metrics.sh"

ensure_dirs

SCORE_THRESHOLD="${SKILL_EVAL_THRESHOLD:-80}"

INPUT=$(read_stdin_json)
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // "unknown"')
SKILL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

is_meta_skill "$SKILL_NAME" && exit 0

if ! skill_has_eval "$SKILL_NAME"; then
  jq -n --arg skill "$SKILL_NAME" \
    '{hookSpecificOutput: {eval_status: "no_eval",
      hint: "Run /generate-eval \($skill) to enable quality tracking"}}'
  exit 0
fi

PREV_SCORE=$(get_latest_score "$SKILL_NAME")
EVAL_RESULT=$(evaluate_output "$SKILL_NAME" "$SKILL_OUTPUT")

SCORE=$(echo "$EVAL_RESULT"      | jq '.score')
TOTAL=$(echo "$EVAL_RESULT"      | jq '.total_assertions')
PASSED=$(echo "$EVAL_RESULT"     | jq '.passed')
FAILED=$(echo "$EVAL_RESULT"     | jq '.failed')
NEEDS_AI=$(echo "$EVAL_RESULT"   | jq '.needs_ai_evaluation')
FAILED_LIST=$(echo "$EVAL_RESULT" | jq '.failed_assertions')

record_score "$SKILL_NAME" "$SCORE" "$TOTAL" "$PASSED" "$FAILED" "$NEEDS_AI" 0 "hook"

LOG_FILE="$LOGS_DIR/eval-results-$(timestamp_date).jsonl"
jq -n \
  --arg timestamp "$(timestamp_utc)" --arg session "$SESSION_ID" --arg skill "$SKILL_NAME" \
  --argjson score "$SCORE" --argjson total "$TOTAL" --argjson passed "$PASSED" \
  --argjson failed "$FAILED" --argjson needs_ai "$NEEDS_AI" \
  --arg prev_score "$PREV_SCORE" --argjson failed_list "$FAILED_LIST" \
  '{timestamp: $timestamp, session_id: $session, event: "post_skill_eval",
    skill: $skill, score: $score, total: $total, passed: $passed, failed: $failed,
    needs_ai: $needs_ai, previous_score: $prev_score,
    failed_assertions: $failed_list}' >> "$LOG_FILE"

TREND_DIR=$(get_trend_direction "$SKILL_NAME")
IMPROVEMENT=$(get_improvement_delta "$SKILL_NAME")
SUGGESTION=""
[[ "$SCORE" -lt "$SCORE_THRESHOLD" ]] && \
  SUGGESTION="Score is below ${SCORE_THRESHOLD}%. Consider running: /self-improve $SKILL_NAME"

jq -n \
  --arg skill "$SKILL_NAME" --argjson score "$SCORE" --argjson total "$TOTAL" \
  --argjson passed "$PASSED" --argjson failed "$FAILED" --argjson needs_ai "$NEEDS_AI" \
  --arg prev "$PREV_SCORE" --arg trend "$TREND_DIR" --argjson delta "$IMPROVEMENT" \
  --argjson failures "$FAILED_LIST" --arg suggestion "$SUGGESTION" \
  '{hookSpecificOutput: {eval_result: {
    skill: $skill, score: $score, total_assertions: $total,
    passed: $passed, failed: $failed, needs_ai_evaluation: $needs_ai,
    previous_score: $prev, trend: $trend, improvement_since_first: $delta,
    failed_assertions: $failures, suggestion: $suggestion
  }}}'

exit 0