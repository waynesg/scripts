#!/usr/bin/env python3
"""Verify a V2Ray geosite.dat and export its category labels."""

import argparse
import json
from pathlib import Path


def read_varint(data, offset):
    value = 0
    shift = 0
    while offset < len(data):
        byte = data[offset]
        offset += 1
        value |= (byte & 0x7F) << shift
        if byte < 0x80:
            return value, offset
        shift += 7
        if shift >= 64:
            raise ValueError("invalid protobuf varint")
    raise ValueError("truncated protobuf varint")


def fields(data):
    offset = 0
    while offset < len(data):
        key, offset = read_varint(data, offset)
        number, wire = key >> 3, key & 7
        if number == 0:
            raise ValueError("invalid protobuf field number")
        if wire == 0:
            value, offset = read_varint(data, offset)
        elif wire == 1:
            value = data[offset : offset + 8]
            offset += 8
        elif wire == 2:
            length, offset = read_varint(data, offset)
            value = data[offset : offset + length]
            offset += length
        elif wire == 5:
            value = data[offset : offset + 4]
            offset += 4
        else:
            raise ValueError(f"unsupported protobuf wire type: {wire}")
        if offset > len(data):
            raise ValueError("truncated protobuf field")
        yield number, wire, value


def inspect(path):
    entries = []
    domain_count = 0
    for number, wire, value in fields(path.read_bytes()):
        if number != 1 or wire != 2:
            continue
        tag = None
        domains = 0
        for entry_number, entry_wire, entry_value in fields(value):
            if entry_number == 1 and entry_wire == 2:
                tag = entry_value.decode("utf-8").upper()
            elif entry_number == 2 and entry_wire == 2:
                domains += 1
        if tag:
            entries.append(tag)
            domain_count += domains
    return entries, domain_count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("--labels", type=Path)
    parser.add_argument("--summary", type=Path)
    parser.add_argument("--min-categories", type=int, default=1000)
    args = parser.parse_args()

    tags, domain_count = inspect(args.input)
    unique_tags = sorted(set(tags))
    required = {
        "APPLE",
        "CATEGORY-ADS-ALL",
        "CN",
        "CUSTOM-DIRECT",
        "CUSTOM-PROXY",
        "GEOLOCATION-!CN",
        "GOOGLE",
        "PRIVATE",
    }
    missing = sorted(required - set(unique_tags))

    if len(tags) != len(unique_tags):
        raise SystemExit("duplicate geosite category labels found")
    if len(unique_tags) < args.min_categories:
        raise SystemExit(
            f"incomplete geosite: {len(unique_tags)} categories, "
            f"expected at least {args.min_categories}"
        )
    if missing:
        raise SystemExit("missing required geosite categories: " + ", ".join(missing))

    if args.labels:
        args.labels.write_text("\n".join(tag.lower() for tag in unique_tags) + "\n", encoding="utf-8")
    summary = {
        "categories": len(unique_tags),
        "domain_entries": domain_count,
        "required_categories": sorted(tag.lower() for tag in required),
    }
    if args.summary:
        args.summary.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, sort_keys=True))


if __name__ == "__main__":
    main()
