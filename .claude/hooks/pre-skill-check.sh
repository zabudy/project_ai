#!/bin/bash
# ============================================================================
# pre-skill-check.sh — PreToolUse Hook for Skill
# ============================================================================
# Fires BEFORE a skill executes. Injects skill health context into session.
# Hook event: PreToolUse | Matcher: Skill
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/metrics.sh"

ensure_dirs

INPUT=$(read_stdin_json)
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // "unknown"')

is_meta_skill "$SKILL_NAME" && exit 0
[[ ! -d "$SKILLS_DIR/$SKILL_NAME" ]] && exit 0

HAS_EVAL="false"; LATEST_SCORE="N/A"; BEST_SCORE="N/A"
TREND_DIR="unknown"; EVAL_COUNT="0"

if skill_has_eval "$SKILL_NAME"; then
  HAS_EVAL="true"
  LATEST_SCORE=$(get_latest_score "$SKILL_NAME")
  BEST_SCORE=$(get_best_score "$SKILL_NAME")
  TREND_DIR=$(get_trend_direction "$SKILL_NAME")
  EVAL_COUNT=$(get_eval_count "$SKILL_NAME")
fi

LOG_FILE="$LOGS_DIR/pre-checks-$(timestamp_date).jsonl"
jq -n \
  --arg timestamp "$(timestamp_utc)" --arg skill "$SKILL_NAME" \
  --arg has_eval "$HAS_EVAL" --arg latest_score "$LATEST_SCORE" --arg trend "$TREND_DIR" \
  '{timestamp: $timestamp, event: "pre_skill_check", skill: $skill,
    has_eval: ($has_eval == "true"), latest_score: $latest_score, trend: $trend}' >> "$LOG_FILE"

jq -n \
  --arg skill "$SKILL_NAME" --arg has_eval "$HAS_EVAL" \
  --arg latest_score "$LATEST_SCORE" --arg best_score "$BEST_SCORE" \
  --arg trend "$TREND_DIR" --arg eval_count "$EVAL_COUNT" \
  '{hookSpecificOutput: {skill_health: {
    skill: $skill, has_eval: ($has_eval == "true"),
    latest_score: $latest_score, best_score: $best_score,
    trend: $trend, total_evaluations: ($eval_count | tonumber)
  }}}'

exit 0