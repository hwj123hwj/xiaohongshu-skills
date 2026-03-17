#!/usr/bin/env bash
# wait_login_bg.sh — 后台等待扫码登录，成功后向 OpenClaw Webhook 发通知
#
# 用法:
#   bash scripts/wait_login_bg.sh <notify_url> [timeout_seconds]
#
# 示例:
#   bash scripts/wait_login_bg.sh "https://hook.example.com/xhs-login" 180
#
# 说明:
#   - 在后台运行 wait-login --notify-url，脚本立即返回（不阻塞）
#   - 登录成功/超时后，向 notify_url POST JSON: {"logged_in": true/false, "message": "..."}
#   - 日志写入 /tmp/xhs/wait_login_bg.log

set -euo pipefail

NOTIFY_URL="${1:-}"
TIMEOUT="${2:-180}"
LOG_FILE="/tmp/xhs/wait_login_bg.log"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$NOTIFY_URL" ]]; then
  echo "Usage: $0 <notify_url> [timeout_seconds]" >&2
  exit 1
fi

mkdir -p /tmp/xhs

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动后台等待登录，timeout=${TIMEOUT}s，notify=${NOTIFY_URL}" >> "$LOG_FILE"

cd "$SKILL_DIR"
export PATH="$HOME/.local/bin:$PATH"

nohup uv run python scripts/cli.py wait-login \
  --timeout "$TIMEOUT" \
  --notify-url "$NOTIFY_URL" \
  >> "$LOG_FILE" 2>&1 &

BG_PID=$!
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 后台进程 PID=$BG_PID" >> "$LOG_FILE"
echo "$BG_PID" > /tmp/xhs/wait_login_bg.pid

echo "✅ 后台等待登录已启动 (PID=$BG_PID)，日志: $LOG_FILE"
