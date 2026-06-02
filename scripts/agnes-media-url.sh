#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/agnes-media-url.sh <file-or-url> [1h|12h|24h|72h]

If the input is already an http(s) URL, print it unchanged.
If the input is a local file path, upload it to Litterbox and print the
temporary public URL.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit $([[ $# -ge 1 ]] && echo 0 || echo 1)
fi

input="$1"
ttl="${2:-1h}"

case "$ttl" in
  1h|12h|24h|72h) ;;
  *)
    echo "Unsupported TTL: $ttl" >&2
    echo "Expected one of: 1h, 12h, 24h, 72h" >&2
    exit 1
    ;;
esac

if [[ "$input" =~ ^https?:// ]]; then
  printf '%s\n' "$input"
  exit 0
fi

if [[ ! -f "$input" ]]; then
  echo "Input must be an existing file path or an http(s) URL: $input" >&2
  exit 1
fi

curl -fsS https://litterbox.catbox.moe/resources/internals/api.php \
  -F "reqtype=fileupload" \
  -F "time=${ttl}" \
  -F "fileToUpload=@${input}"
