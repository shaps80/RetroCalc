#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

# jq filter to extract assistant text from Codex JSONL events
stream_text='(
  if .type == "item.completed" and .item.type == "message" and .item.role == "assistant" then
    .item.content[]? | select(.type == "output_text" or .type == "text") | .text
  elif .type == "agent_message_delta" then
    .delta
  elif .type == "agent_message" then
    .message
  else
    empty
  end
) // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'

for ((i=1; i<=$1; i++)); do
  tmpfile=$(mktemp)
  resultfile=$(mktemp)
  trap "rm -f $tmpfile $resultfile" EXIT

  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
  issues=$(cat issues/*.md 2>/dev/null || echo "No issues found")
  prompt=$(cat ralph/prompt.md)

  codex --ask-for-approval never exec \
    --cd . \
    --sandbox workspace-write \
    --json \
    --output-last-message "$resultfile" \
    "Previous commits: $commits Issues: $issues $prompt" \
  | grep --line-buffered '^{' \
  | tee "$tmpfile" \
  | jq --unbuffered -rj "$stream_text"

  result=$(cat "$resultfile")

  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    echo "Ralph complete after $i iterations."
    exit 0
  fi
done
