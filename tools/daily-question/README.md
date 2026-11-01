# Daily question run

Adds two new practice questions to each event's `extra.json` every morning, then
commits and pushes. Runs Claude Code on this Mac, so it uses your own git
credentials — no GitHub connector involved.

## Files

- `prompt.md` — what Claude is asked to do. Edit this to change scope, counts or topics.
- `run.sh` — pulls, runs Claude Code, validates the JSON, commits and pushes.
- `com.ovmsso.dailyquestion.plist` — launchd job, 4:41 AM daily.
- `last-run.log` — everything the run printed. Check here first when something looks off.

## Install

Try one run by hand first:

    ./tools/daily-question/run.sh ; tail -40 tools/daily-question/last-run.log

If that pushes a commit, install the schedule:

    cp tools/daily-question/com.ovmsso.dailyquestion.plist ~/Library/LaunchAgents/
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ovmsso.dailyquestion.plist

To check, stop, or restart it:

    launchctl print gui/$(id -u)/com.ovmsso.dailyquestion     # status
    launchctl kickstart -k gui/$(id -u)/com.ovmsso.dailyquestion   # run it now
    launchctl bootout gui/$(id -u)/com.ovmsso.dailyquestion   # remove

After editing the plist, bootout then bootstrap again.

## Notes

- The Mac has to be awake at 4:41 AM. If it is asleep, launchd runs the job once
  the Mac wakes; if it is off, that day is skipped. Nothing breaks — the next run
  just adds that day's questions.
- `run.sh` refuses to commit if either `extra.json` stopped being valid JSON, and
  reverts both files instead.
- If `--permission-mode acceptEdits` is not recognized by your Claude Code version,
  check `claude --help` and swap in the equivalent flag in `run.sh`.
