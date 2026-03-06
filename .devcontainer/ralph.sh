#!/bin/bash
# ralph.sh - Autonomous loop for pi
# Usage: ./ralph.sh <iterations> <file>
# Examples:
#   ralph.sh 20 tasks.json
#   ralph.sh 20 PRD.md

set -e

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <iterations> <file>"
    exit 1
fi

MAX=$1
SOURCE=$2
PROGRESS="progress.txt"

[[ ! -f "$SOURCE" ]] && echo "❌ Missing: $SOURCE" && exit 1
[[ ! -f "$PROGRESS" ]] && touch "$PROGRESS"

echo "🤖 Ralph Loop | Max: $MAX | Source: $SOURCE"

for ((i=1; i<=$MAX; i++)); do
    echo "🔄 [$i/$MAX] Running..."

    result=$(pi -p \
        "@$SOURCE @$PROGRESS
        1. Find the next incomplete task and implement it.
        2. Verify it works.
        3. Commit your changes.
        4. Update progress.txt.
        ONLY ONE TASK.
        If all done, output <promise>COMPLETE</promise>.")

    echo "$result"

    if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
        echo "✅ Complete after $i iterations"
        exit 0
    fi

    sleep 3
done

echo "🛑 Max iterations reached"
exit 1
