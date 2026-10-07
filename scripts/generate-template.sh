#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="${1:-${ROOT_DIR}/routing.template.json}"

read_rules() {
  jq -Rsc '
    split("\n")
    | map(sub("[[:space:]]*#.*$"; ""))
    | map(gsub("^[[:space:]]+|[[:space:]]+$"; ""))
    | map(select(length > 0))
  ' "$1"
}

DIRECT_RULES="$(read_rules "${ROOT_DIR}/rules/direct.txt")"
PROXY_RULES="$(read_rules "${ROOT_DIR}/rules/proxy.txt")"
BLOCK_RULES="$(read_rules "${ROOT_DIR}/rules/block.txt")"
RU_RULES="$(read_rules "${ROOT_DIR}/rules/ru.txt")"

jq \
  --argjson direct "${DIRECT_RULES}" \
  --argjson proxy "${PROXY_RULES}" \
  --argjson block "${BLOCK_RULES}" \
  --argjson ru "${RU_RULES}" '
    def sites: map(select(startswith("geosite:")));
    def ips: map(select(startswith("geoip:")));
    .DirectSites = (($direct + $ru) | sites) |
    .DirectIp = (($direct + $ru) | ips) |
    .ProxySites = ($proxy | sites) |
    .ProxyIp = ($proxy | ips) |
    .BlockSites = ($block | sites) |
    .BlockIp = ($block | ips)
  ' "${ROOT_DIR}/routing.base.json" > "${OUTPUT}"

jq empty "${OUTPUT}"
