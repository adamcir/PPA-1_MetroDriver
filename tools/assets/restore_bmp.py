#!/usr/bin/env python3
"""Restore bundled user artwork from base64-compressed sources.

Upload newer editable BMP files to assets/ to override these embedded assets.
The panel archive preserves the exact uploaded 24-bit BMP.
The cab archive holds a PPA-1 palette-quantized 8-bit rendering of the
uploaded 24-bit cab (the build target is always 8-bit VGA).
"""
import base64
import gzip
import hashlib
import lzma
from pathlib import Path
import sys

EXPECTED_SHA256 = {
    "pult_ezh3.bmp.gz.b64": "8770b7b75dc0eba0d590768e0704afe44db98765b1554ac1b5915f4f5d59f264",
    "cab_ezh3_layer.bmp.xz.b64": "2de2989a646f4b13e7935a0e5cad688b6d4b938ec884ee0a32909d457ae29a54",
}

if len(sys.argv) != 3:
    raise SystemExit("usage: restore_bmp.py INPUT.bmp.{gz,xz}.b64 OUTPUT.bmp")

source, dest = map(Path, sys.argv[1:])
if source.name not in EXPECTED_SHA256:
    raise SystemExit(f"Unknown asset archive: {source.name}")
packed = base64.b64decode(source.read_text(encoding="ascii"))
if source.name.endswith(".gz.b64"):
    decoded = gzip.decompress(packed)
elif source.name.endswith(".xz.b64"):
    decoded = lzma.decompress(packed)
else:
    raise SystemExit("Unknown compression format")
if hashlib.sha256(decoded).hexdigest() != EXPECTED_SHA256[source.name]:
    raise SystemExit("Embedded artwork SHA256 mismatch")
if not decoded.startswith(b"BM"):
    raise SystemExit("Embedded artwork is not a Windows BMP")
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_bytes(decoded)
print(f"Restored {len(decoded)} bytes of Ezh3 artwork to {dest}")
