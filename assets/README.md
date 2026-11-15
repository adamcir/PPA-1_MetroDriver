# Optional bitmap resource

Use your Ež3 driver's cab screenshot exported from **GIMP**:

1. Resize or crop to **320 × 200** pixels.
2. Choose **File → Export As…** and use a `.bmp` extension.
3. Export as **uncompressed BMP** (8-bit indexed, 24-bit RGB or 32-bit
   uncompressed color; do not select RLE/bitfields compression).
4. Save as `assets/cab_ezh3.bmp` in this repository, then run `make`.
   The older `cab_ecs.bmp` filename also works as a fallback.

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

No bitmap file is required: without a cab BMP, the program still renders
the original Ečs-style panel in PPA-1 ASM.

### Replacing gm_construct with live rails

Your original Ež3 screenshot includes gm_construct through the windshields.
Do not paint pre-rendered rails onto the cab texture: the game now draws
the tunnel, moving sleepers and rail outlines **in front of those pixels**
using VGA from PPA-1 ASM. The rest of the screenshot, including the
dashboard and window frames, is left visible.

For the supplied 320×200 screenshot, the current ASM covers:

- front window: x=112..207, y=0..105;
- left window: x=0..57, y=0..69;
- right window: x=275..319, y=12..102.

Only the front window currently receives animated rails; side windows show
dark tunnel. If you crop/scale the screenshot differently in GIMP, adjust
the rectangle origins/sizes inside `draw_ezh3_window` in `main.asm`.
If any pixels of gm_construct remain visible beside an opening, expand
its window rectangle slightly without covering the silver window frame.

The original `railroad_001.png` in the GMod texture atlas is not a
ready-made front-facing tunnel view and is not yet projected in-game.

For additional resources or arbitrary binary blobs, use:

```sh
make rompack
out/tools/ppa_rompack out/main.prg out/resources.bin \
  --bmp 0001:assets/cab_ezh3.bmp \
  --put 0002:0100:/path/to/custom.dat --info
```

BANK and OFFSET are **hexadecimal**. Bank `0000` is protected because
the running program occupies it. An inserted file must fit within its
chosen 64 KiB bank; the tool refuses overlaps.
