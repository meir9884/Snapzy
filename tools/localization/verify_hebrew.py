#!/usr/bin/env python3
"""Verify complete Hebrew catalogs and preserve runtime formatting tokens."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOGS = ROOT / "Snapzy/Resources/Localization"
FORMAT = re.compile(r"%(?:\d+\$)?[-+#0 ]*(?:\d+|\*)?(?:\.(?:\d+|\*))?(?:hh|ll|[hlLzjt])?[@diuoxXfFeEgGaAcsp%]")
TOKEN = re.compile(r"\{[A-Za-z][A-Za-z0-9]*\}")


def verify():
    total = 0
    for path in sorted(CATALOGS.rglob("*.xcstrings")):
        catalog = json.loads(path.read_text())
        for key, entry in catalog["strings"].items():
            en = entry["localizations"]["en"]["stringUnit"]["value"]
            he = entry["localizations"].get("he", {}).get("stringUnit", {})
            assert he.get("state") == "translated", (path.name, key, "missing translation")
            value = he.get("value", "")
            assert value, (path.name, key, "empty translation")
            assert FORMAT.findall(en) == FORMAT.findall(value), (key, "format mismatch")
            assert TOKEN.findall(en) == TOKEN.findall(value), (key, "naming token mismatch")
            total += 1
    print(f"Hebrew: {total}/{total} entries translated; format and naming tokens preserved.")


if __name__ == "__main__":
    verify()
