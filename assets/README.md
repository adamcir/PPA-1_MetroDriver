# Optional bitmap resource

Export your Ečs control-desk artwork from **GIMP**:

1. Resize or crop to **320 × 200** pixels.
2. Choose **File → Export As…** and use a `.bmp` extension.
3. Export as **uncompressed BMP** (8-bit indexed, 24-bit RGB or 32-bit
   uncompressed color; do not select RLE/bitfields compression).
4. Save as `assets/cab_ecs.bmp` in this repository, then run `make`.

The C ROM packer converts BMP pixels into a shared 256-color PPA-VGA
palette (the first 16 colors retain EGA colors, and 16–255 use an RGB
6 × 8 × 5 color cube). The BMP itself is **not** copied to the EEPROM:
`PIMG` resources in ROM bank `0001` contain a compact header,
768-byte RGB palette and top-to-bottom 8-bit pixel array.

The first image can occupy at most 65024 bytes in its bank:
1024 bytes of header/palette/padding + 320 × 200 pixels.
The assembler creates `out/main.prg` (64 KiB program bank), then
ROMPACK combines it with optional assets and writes the complete
`out/main.bin` (2 MiB EEPROM image). ROMPACK always runs, even without BMP.

No bitmap file is required: without `cab_ecs.bmp` the program still
renders the original gray Ečs-style panel in PPA-1 ASM.

For additional resources or arbitrary binary blobs, use:

```sh
make rompack
out/tools/ppa_rompack out/main.prg out/resources.bin \
  --bmp 0001:assets/cab_ecs.bmp \
  --put 0002:0100:/path/to/custom.dat --info
```

BANK and OFFSET are **hexadecimal**. Bank `0000` is protected because
the running program occupies it. An inserted file must fit within its
chosen 64 KiB bank; the tool refuses overlaps.
