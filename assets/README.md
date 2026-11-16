# Ež3 layered textures for PPA-1 MetroDriver

The user-supplied cabin and panel are **separate graphics layers**. Their
original authoring format is a 320×200 BMP with color-key masking.

| Source | Packed into | Purpose |
|---|---|---|
| `cab_ezh3_layer.bmp` | ROM bank `0001` | Cab walls/frames without the panel |
| `pult_ezh3.bmp` | ROM bank `0002` | Independent metal/wood dashboard |

Both new drawings are already bundled into this repository as compressed,
SHA-256-checked text archives. `make` restores them to
`out/assets/cab_ezh3_layer.bmp` and `out/assets/pult_ezh3.bmp`.

- `cab_ezh3_layer.bmp.xz.b64` is a palette-quantized 8-bit copy of the
  user's uploaded cabin: same PPA-1 output colors and mask shape.
- `pult_ezh3.bmp.gz.b64` is the original uploaded 24-bit BMP, preserved
  without any change.

You can override either archive by placing your new uncompressed GIMP
export directly at `assets/cab_ezh3_layer.bmp` or
`assets/pult_ezh3.bmp`; the build prioritizes these source BMPs.

## Color-key masks

**Exact RGB values** are important:

- `#00FF00` green: window/opening, where the moving metro track appears.
- `#0000FF` blue: the space reserved for the dashboard (also transparent
  in the graphics compositor).
- All other colors are drawn normally.

ROMPACK converts these to VGA palette indices `FFh` (green) and `FEh`
(blue); it excludes those two indices from opaque quantized colors.
The PPA-1 ASM compositor skips both keys. No BMP alpha channel is needed.

Render order: **ASM tunnel/rails/stations -> cab -> dashboard**.

Use solid colors for the masks. Avoid soft edges, blur and antialiasing into
the mask color, otherwise you can get green/blue fringe pixels.

## GIMP export

1. Set canvas to **320×200** pixels.
2. Export BMP (8-bit indexed, uncompressed 24-bit RGB, or uncompressed 32-bit).
3. Disable RLE compression and BITFIELDS modes.
4. Place the files in `assets/` with the names above.
5. Run `make clean && make` (or simply `make`).

The final `out/main.bin` is a 2 MiB EEPROM image; the intermediate
`out/main.prg` is a 64 KiB program, not a full EEPROM.
If the BMP sources are absent, the bundled checked archives supply them.

## Legacy screenshot

The original `assets/cab_ezh3.bmp` is kept as a reference image.
It is used only in legacy mode if there is no independent cab/panel
texture. The new masked layers take priority.

Currently the game draws its moving metro environment with PPA-1 ASM
primitives. The textures for tunnels, curved tracks and instruments can
be added independently in future versions.
