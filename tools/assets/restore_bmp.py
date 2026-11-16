#!/usr/bin/env python3
"""Restore the user's original 320x200 Ezh3 BMP from a lossless text archive.

The GitHub connector writes UTF-8 files; storing compressed base64 keeps the
exact uploaded BMP (including 24-bit pixels) available for reproducible builds.
A normal assets/pult_ezh3.bmp always takes precedence over this fallback.
"""
import base64
import gzip
import hashlib
from pathlib import Path
import sys

EXPECTED_SHA256 = "8770b7b75dc0eba0d590768e0704afe44db98765b1554ac1b5915f4f5d59f264"

if len(sys.argv) != 3:
    raise SystemExit("usage: restore_bmp.py INPUT.bmp.gz.b64 OUTPUT.bmp")

source, dest = map(Path, sys.argv[1:])
decoded = gzip.decompress(base64.b64decode(source.read_text(encoding="ascii")))
if hashlib.sha256(decoded).hexdigest() != EXPECTED_SHA256:
    raise SystemExit("Embedded panel BMP SHA256 mismatch")
if not decoded.startswith(b"BM"):
    raise SystemExit("Embedded panel data is not a Windows BMP")
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_bytes(decoded)
print(f"Restored {len(decoded)} bytes of original Ezh3 panel BMP to {dest}")
