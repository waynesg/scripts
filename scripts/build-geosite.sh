#!/usr/bin/env bash
set -euo pipefail

# Preserve the official Loyalsoldier database and append local categories.
# Usage: build-geosite.sh [output-directory]
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${1:-$ROOT_DIR/geodata}"
OUT_DIR="$(cd "${1:-$ROOT_DIR/geodata}" && pwd)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/geosite.XXXXXXXX")"

curl -fsSL --retry 3 \
  https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest \
  -o "$WORK_DIR/release.json"
RELEASE_TAG="$(python3 - "$WORK_DIR/release.json" <<'PY'
import json, re, sys
with open(sys.argv[1], encoding="utf-8") as source:
    tag = json.load(source)["tag_name"]
if not re.fullmatch(r"[A-Za-z0-9._-]+", tag):
    raise SystemExit("invalid upstream release tag")
print(tag)
PY
)"
BASE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$RELEASE_TAG"
curl -fsSL --retry 3 "$BASE_URL/geosite.dat" -o "$WORK_DIR/geosite.dat"
curl -fsSL --retry 3 "$BASE_URL/geosite.dat.sha256sum" -o "$WORK_DIR/geosite.dat.sha256sum"
(cd "$WORK_DIR" && shasum -a 256 -c geosite.dat.sha256sum)

python3 "$ROOT_DIR/scripts/merge-geosite.py" \
  --upstream "$WORK_DIR/geosite.dat" --rules-dir "$ROOT_DIR/rules" \
  --output-dir "$WORK_DIR/publish"
python3 "$ROOT_DIR/scripts/verify-geosite.py" "$WORK_DIR/publish/geosite.dat" \
  --upstream "$WORK_DIR/geosite.dat" \
  --labels "$WORK_DIR/publish/geosite-tags.txt" \
  --summary "$WORK_DIR/publish/geosite-summary.json"
printf 'Loyalsoldier/v2ray-rules-dat release %s\n' "$RELEASE_TAG" \
  > "$WORK_DIR/publish/source-revisions.txt"
printf 'upstream-sha256 %s\n' "$(shasum -a 256 "$WORK_DIR/geosite.dat" | cut -d ' ' -f 1)" \
  >> "$WORK_DIR/publish/source-revisions.txt"
(cd "$WORK_DIR/publish" && shasum -a 256 geosite.dat > geosite.dat.sha256)
date -u +%Y-%m-%dT%H:%M:%SZ > "$WORK_DIR/publish/updated-at.txt"

# Publish only after the checksum and upstream-preservation checks pass.
cp "$WORK_DIR/publish/"* "$OUT_DIR/"
echo "Built $OUT_DIR/geosite.dat from Loyalsoldier release $RELEASE_TAG"
