#!/usr/bin/env bash
set -euo pipefail

# Build a complete MetaCubeX/V2Fly geosite.dat and append the local rule sets.
# Usage: build-geosite.sh [output-directory]

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$ROOT_DIR/geodata}"
WORK_DIR="${WORK_DIR:-$(mktemp -d)}"
COMMUNITY_DIR="$WORK_DIR/community"
BUILDER_DIR="$WORK_DIR/meta-rules-dat"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

mkdir -p "$OUT_DIR"
git clone --depth=1 https://github.com/v2fly/domain-list-community.git "$COMMUNITY_DIR"
git clone --depth=1 https://github.com/MetaCubeX/meta-rules-dat.git "$BUILDER_DIR"

python3 - "$ROOT_DIR" "$COMMUNITY_DIR/data" "$OUT_DIR" <<'PY'
import pathlib, re, sys

root = pathlib.Path(sys.argv[1])
data = pathlib.Path(sys.argv[2])
out = pathlib.Path(sys.argv[3])

groups = {
    "custom-direct": ["custom_direct.yaml", "unbreak-classical.yaml"],
    "custom-proxy": ["custom_proxy.yaml", "proxy-classical.yaml"],
}
rule_re = re.compile(r"^\s*-\s*(DOMAIN-SUFFIX|DOMAIN-KEYWORD|DOMAIN|IP-CIDR6?|DOMAIN-REGEX),\s*([^,\s]+)")
domain_re = re.compile(r"^[A-Za-z0-9_*.-]+$")

for group, names in groups.items():
    entries, ips = set(), set()
    for name in names:
        path = root / "rules" / name
        if not path.exists():
            raise SystemExit(f"missing rule file: {path}")
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            m = rule_re.match(line)
            if not m:
                continue
            kind, value = m.groups()
            value = value.strip().lower()
            if kind == "DOMAIN-SUFFIX" and domain_re.match(value):
                entries.add("domain:" + value.lstrip("."))
            elif kind == "DOMAIN" and domain_re.match(value):
                entries.add("full:" + value)
            elif kind == "DOMAIN-KEYWORD" and domain_re.match(value):
                entries.add("keyword:" + value)
            elif kind == "DOMAIN-REGEX":
                entries.add("regexp:" + value)
            elif kind.startswith("IP-CIDR"):
                ips.add(value)
    if not entries:
        raise SystemExit(f"no domain entries found for {group}")
    (data / group).write_text("\n".join(sorted(entries)) + "\n", encoding="utf-8")
    (out / (group + "-ip.txt")).write_text("\n".join(sorted(ips)) + ("\n" if ips else ""), encoding="utf-8")
PY

(cd "$BUILDER_DIR/custom" && go run ./ --datapath="$COMMUNITY_DIR/data")
test -s "$BUILDER_DIR/geosite.dat"
cp "$BUILDER_DIR/geosite.dat" "$OUT_DIR/geosite.dat"
sha256sum "$OUT_DIR/geosite.dat" > "$OUT_DIR/geosite.dat.sha256"
date -u +%Y-%m-%dT%H:%M:%SZ > "$OUT_DIR/updated-at.txt"
echo "Built $OUT_DIR/geosite.dat"
