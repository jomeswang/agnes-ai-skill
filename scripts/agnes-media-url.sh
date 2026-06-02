#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  agnes-media-url.sh <file-or-url> [ttl]

Examples:
  agnes-media-url.sh ./frame.png
  agnes-media-url.sh ./frame.png 12h
  agnes-media-url.sh https://example.com/frame.png

If the input is already an http(s) URL, the script prints it unchanged.
If the input is a local file path, the script uploads it to Litterbox and
prints the resulting temporary public URL.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit 0
fi

input="$1"
ttl="${2:-1h}"

if [[ "$input" =~ ^https?:// ]]; then
  printf '%s\n' "$input"
  exit 0
fi

if [[ ! -r "$input" ]]; then
  printf 'Input must be a readable file path or an http(s) URL: %s\n' "$input" >&2
  exit 1
fi

curl -sS https://litterbox.catbox.moe/resources/internals/api.php \
  -F "reqtype=fileupload" \
  -F "time=${ttl}" \
  -F "fileToUpload=@${input}"
