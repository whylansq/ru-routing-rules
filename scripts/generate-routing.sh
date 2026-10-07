#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 BASE_URL UNIX_TIMESTAMP [OUTPUT]" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_URL="${1%/}"
TIMESTAMP="$2"
OUTPUT="${3:-${ROOT_DIR}/routing.json}"

if [[ ! "${TIMESTAMP}" =~ ^[0-9]+$ ]]; then
  echo "UNIX_TIMESTAMP must contain digits only" >&2
  exit 2
fi

jq \
  --arg geoip "${BASE_URL}/geoip.dat" \
  --arg geosite "${BASE_URL}/geosite.dat" \
  --arg timestamp "${TIMESTAMP}" '
    .Geoipurl = $geoip |
    .Geositeurl = $geosite |
    .LastUpdated = $timestamp
  ' "${ROOT_DIR}/routing.template.json" > "${OUTPUT}"

jq empty "${OUTPUT}"
