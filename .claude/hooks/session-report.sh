#!/bin/bash
# ============================================================================
# session-report.sh — Stop Hook (Session End)
# ============================================================================
# Fires when Claude finishes responding. Generates skill health summary.
# Hook event: Stop
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/metrics.sh"

ensure_dirs

INPUT=$(read_stdin_json)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

TODAY=$(timestamp_date)
EXEC_LOG="$LOGS_DIR/skill-executions-${TODAY}.jsonl"
EVAL_LOG="$LOGS_DIR/eval-results-${TODAY}.jsonl"

SKILLS_USED=0
[[ -f "$EXEC_LOG" ]] && SKILLS_USED=$(wc -l < "$EXEC_LOG" | tr -d ' ')
[[ "$SKILLS_USED" -eq 0 ]] && exit 0

EVALS_RUN=0
[[ -f "$EVAL_LOG" ]] && EVALS_RUN=$(wc -l < "$EVAL_LOG" | tr -d ' ')

SKILLS_WITH_EVAL=0; SKILLS_WITHOUT_EVAL=0; SKILLS_BELOW_THRESHOLD=0
THRESHOLD=80

for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")
  is_meta_skill "$skill_name" && continue

  if skill_has_eval "$skill_name"; then
    SKILLS_WITH_EVAL=$((SKILLS_WITH_EVAL + 1))
    local_score=$(get_latest_score "$skill_name")
    if [[ "$local_score" != "N/A" ]] && [[ "$local_score" -lt "$THRESHOLD" ]]; then
      SKILLS_BELOW_THRESHOLD=$((SKILLS_BELOW_THRESHOLD + 1))
    fi
  else
    SKILLS_WITHOUT_EVAL=$((SKILLS_WITHOUT_EVAL + 1))
  fi
done

REPORT_FILE="$LOGS_DIR/session-report-${TODAY}-${SESSION_ID:0:8}.md"
{
  echo "# Session Skill Health Report"
  echo "**Date**: $TODAY | **Session**: ${SESSION_ID:0:8}"
  echo ""
  echo "## Activity"
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Skills executed | $SKILLS_USED |"
  echo "| Evaluations run | $EVALS_RUN |"
  echo "| Skills with eval | $SKILLS_WITH_EVAL |"
  echo "| Skills without eval | $SKILLS_WITHOUT_EVAL |"
  echo "| Skills below ${THRESHOLD}% | $SKILLS_BELOW_THRESHOLD |"
  echo ""

  if [[ -f "$EVAL_LOG" ]]; then
    echo "## Evaluation Results"
    echo "| Skill | Score | Passed | Failed | Trend |"
    echo "|-------|-------|--------|--------|-------|"
    jq -r '.skill' "$EVAL_LOG" 2>/dev/null | sort -u | while read -r skill; do
      latest=$(get_latest_score "$skill")
      trend=$(get_trend_direction "$skill")
      p=$(jq -r "select(.skill == \"$skill\") | .passed" "$EVAL_LOG" | tail -1)
      f=$(jq -r "select(.skill == \"$skill\") | .failed" "$EVAL_LOG" | tail -1)
      icon="--"
      case "$trend" in improving) icon="↑" ;; declining) icon="↓" ;; stable) icon="=" ;; esac
      echo "| $skill | ${latest}% | $p | $f | $icon |"
    done
    echo ""
  fi

  echo "## Recommendations"
  [[ "$SKILLS_WITHOUT_EVAL" -gt 0 ]] && \
    echo "- **${SKILLS_WITHOUT_EVAL} skills** without eval — run \`/generate-eval [skill]\`"
  [[ "$SKILLS_BELOW_THRESHOLD" -gt 0 ]] && \
    echo "- **${SKILLS_BELOW_THRESHOLD} skills** below ${THRESHOLD}% — run \`/self-improve [skill]\`"
  [[ "$SKILLS_WITHOUT_EVAL" -eq 0 ]] && [[ "$SKILLS_BELOW_THRESHOLD" -eq 0 ]] && \
    echo "- All tracked skills are healthy ✓"
} > "$REPORT_FILE"

jq -n \
  --argjson skills_used "$SKILLS_USED" --argjson evals_run "$EVALS_RUN" \
  --argjson with_eval "$SKILLS_WITH_EVAL" --argjson without_eval "$SKILLS_WITHOUT_EVAL" \
  --argjson below_threshold "$SKILLS_BELOW_THRESHOLD" --arg report_path "$REPORT_FILE" \
  '{hookSpecificOutput: {session_skill_health: {
    skills_used_today: $skills_used, evaluations_run: $evals_run,
    skills_with_eval: $with_eval, skills_without_eval: $without_eval,
    skills_below_threshold: $below_threshold, report: $report_path
  }}}'

exit 0