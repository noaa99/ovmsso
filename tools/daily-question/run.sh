#!/bin/bash
# Daily OVMS practice-question run. Invoked by launchd; safe to run by hand.
set -uo pipefail

REPO="/Users/hyunjong.choi/Workspace/PrivateDocuments/Jayden/OVMS_ScienceOlympiad/ovmsso_web"
DIR="$REPO/tools/daily-question"
LOG="$DIR/last-run.log"

# launchd gives a bare PATH; add the usual places Claude Code and git live.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

exec >>"$LOG" 2>&1
echo "=================================================="
echo "run started $(date '+%Y-%m-%d %H:%M:%S %Z')"

cd "$REPO" || { echo "FAIL: repo not found at $REPO"; exit 1; }

command -v claude >/dev/null || { echo "FAIL: claude not on PATH ($PATH)"; exit 1; }

echo "--- git pull ---"
git pull --ff-only || { echo "FAIL: pull failed, leaving the tree alone"; exit 1; }

echo "--- claude ---"
# 20-minute cap: a stuck run should not hold the slot until tomorrow.
if command -v timeout >/dev/null; then RUNNER="timeout 1200"; else RUNNER=""; fi
$RUNNER claude -p "$(cat "$DIR/prompt.md")" --permission-mode acceptEdits
status=$?
if [ "$status" -eq 124 ]; then
  echo "FAIL: claude timed out after 20 minutes; reverting any partial edits"
  git checkout -- circuit-lab/extra.json water-quality/extra.json
  exit 1
fi
echo "claude exit status: $status"

echo "--- git ---"
if git diff --quiet -- circuit-lab/extra.json water-quality/extra.json; then
  echo "no changes to extra.json; nothing to commit"
  echo "run finished $(date '+%H:%M:%S')"
  exit 0
fi

# Refuse to commit if either file stopped being valid JSON.
for f in circuit-lab/extra.json water-quality/extra.json; do
  python3 -c "import json,sys; json.load(open('$f'))" || {
    echo "FAIL: $f is not valid JSON; reverting both files"
    git checkout -- circuit-lab/extra.json water-quality/extra.json
    exit 1
  }
done

git add circuit-lab/extra.json water-quality/extra.json
git commit -m "Daily practice questions for $(date '+%Y-%m-%d')" \
           -m "Added by the daily question run." || { echo "FAIL: commit failed"; exit 1; }
git push origin main || { echo "FAIL: push failed (commit is still local)"; exit 1; }

echo "pushed $(git rev-parse --short HEAD)"
echo "run finished $(date '+%H:%M:%S')"
