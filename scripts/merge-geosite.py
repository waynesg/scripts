#!/usr/bin/env python3
"""Append custom GeoSite protobuf entries without rewriting the upstream bytes."""

import argparse
import importlib.util
import ipaddress
import re
from pathlib import Path

spec = importlib.util.spec_from_file_location("verify_geosite", Path(__file__).with_name("verify-geosite.py"))
verify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify)

GROUPS = {
    "custom-direct": ["custom_direct.yaml", "unbreak-classical.yaml"],
    "custom-proxy": ["custom_proxy.yaml", "proxy-classical.yaml"],
}
DOMAIN_TYPES = {"DOMAIN-KEYWORD": 0, "DOMAIN-REGEX": 1, "DOMAIN-SUFFIX": 2, "DOMAIN": 3}


def varint(value):
    result = bytearray()
    while value > 127:
        result.append((value & 127) | 128)
        value >>= 7
    result.append(value)
    return bytes(result)


def message_field(number, payload):
    return varint((number << 3) | 2) + varint(len(payload)) + payload


def parse_rules(paths):
    domains, ips = set(), set()
    for path in paths:
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            match = re.match(r"^\s*-\s*(.*)$", line)
            if not match:
                continue
            rule = match[1].strip()
            if rule[:1] in ("'", '"') and rule[-1:] == rule[:1]:
                rule = rule[1:-1]
            kind, separator, value = rule.partition(",")
            kind, value = kind.strip(), value.strip()
            if not separator:
                continue
            if kind in ("IP-CIDR", "IP-CIDR6"):
                ips.add(str(ipaddress.ip_network(value.split(",", 1)[0].strip(), strict=False)))
            elif kind in DOMAIN_TYPES:
                if kind != "DOMAIN-REGEX":
                    value = value.split(",", 1)[0].strip().lower()
                    if kind == "DOMAIN-SUFFIX":
                        value = value.lstrip(".")
                    if not value or not re.fullmatch(r"[A-Za-z0-9_*.-]+", value):
                        raise ValueError(f"{path}:{line_number}: invalid domain: {value!r}")
                if not value:
                    raise ValueError(f"{path}:{line_number}: empty domain rule")
                # Regex case and commas are meaningful and must be retained.
                domains.add((DOMAIN_TYPES[kind], value))
    return sorted(domains), sorted(ips)


def encode_category(tag, domains):
    entry = message_field(1, tag.upper().encode("utf-8"))
    for kind, value in domains:
        # Domain.Type: Plain=0, Regex=1, RootDomain=2, Full=3.
        domain = (b"\x08" + varint(kind) if kind else b"") + message_field(2, value.encode("utf-8"))
        entry += message_field(2, domain)
    return message_field(1, entry)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream", type=Path, required=True)
    parser.add_argument("--rules-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    upstream = args.upstream.read_bytes()
    tags, count = verify.inspect(args.upstream)
    if len(tags) < 1000 or count < 400000:
        raise SystemExit("upstream is not the expected full Loyalsoldier database")
    collisions = set(tags) & {tag.upper() for tag in GROUPS}
    if collisions:
        raise SystemExit("upstream already contains custom categories: " + ", ".join(sorted(collisions)))
    args.output_dir.mkdir(parents=True, exist_ok=True)
    output = bytearray(upstream)
    for group, names in GROUPS.items():
        domains, ips = parse_rules([args.rules_dir / name for name in names])
        if not domains:
            raise SystemExit(f"no domain rules found for {group}")
        output.extend(encode_category(group, domains))
        (args.output_dir / (group + "-ip.txt")).write_text(
            "\n".join(ips) + ("\n" if ips else ""), encoding="utf-8"
        )
        print(f"{group}: {len(domains)} domains, {len(ips)} IP networks")
    (args.output_dir / "geosite.dat").write_bytes(output)


if __name__ == "__main__":
    main()
