#!/bin/bash
# ============================================================================
# utils.sh — Shared utilities for skill self-improvement hooks
# ============================================================================
set -euo pipefail

HOOKS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks"
SKILLS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/skills"
LOGS_DIR="$HOOKS_DIR/logs"
METRICS_DIR="$HOOKS_DIR/metrics"

ensure_dirs() {
  mkdir -p "$LOGS_DIR" "$METRICS_DIR"
}

timestamp_utc()  { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
timestamp_date() { date +"%Y-%m-%d"; }

read_stdin_json() { cat; }

skill_has_eval() {
  local skill_name="$1"
  [[ -f "$SKILLS_DIR/$skill_name/eval/eval.json" ]]
}

skill_eval_path() { echo "$SKILLS_DIR/${1}/eval/eval.json"; }
skill_md_path()   { echo "$SKILLS_DIR/${1}/SKILL.md"; }

is_meta_skill() {
  case "$1" in
    self-improve|generate-eval|skill-health) return 0 ;;
    *) return 1 ;;
  esac
}

log_info()  { echo "[$(timestamp_utc)] [INFO] $*" >&2; }
log_warn()  { echo "[$(timestamp_utc)] [WARN] $*" >&2; }
log_error() { echo "[$(timestamp_utc)] [ERROR] $*" >&2; }