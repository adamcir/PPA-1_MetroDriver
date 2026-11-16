# PPA-1 MetroDriver

A metro-driving game written entirely in **PPA-1 assembly**. It supports the original Ečs-inspired procedural cockpit and separate Ež3 cabin/dashboard textures.
The game runs on the emulated PPA-1 processor; VGA graphics, HUD, track,
keyboard, signals, and sound are produced by PPA-1 instructions.

Copyright (c) 2026 Adam Cír (Adava), Adava Software, Adava Development.

## Project files

```text
main.asm                    Complete ASM game + PIMG loader integration
includes/ppa-vga.inc        PPA-VGA/1 interface (slot 1)
includes/ppa-ps2.inc        PPA-PS/2/1 interface (slot 2)
includes/ppa-gfx.inc        Shared ASM PIMG blitter and VGA DAC palette loader
includes/ppa-game.inc       Game helpers (keyboard, delay, random)
tools/asm/ppa-1_asm.c       Local PPA-1 assembler source
tools/rompack/ppa_rompack.c C ROM packer (GIMP BMP + arbitrary files)
assets/README.md            Bitmap export instructions
Makefile                    Builds the game and packs optional ROM assets
```

The sound-card interface (slot 3) is defined in `main.asm`.

## Build

Linux / GCC or compatible C compiler and `make`:

```sh
git clone https://github.com/adamcir/PPA-1_MetroDriver.git
cd PPA-1_MetroDriver
make
```

The build now has exactly three stages:

```text
main.asm
   |  ppa-1_asm --program
   v
out/main.prg                (64 KiB program, ROM bank 0000)
   |  ppa_rompack + optional assets/*.bmp / binary files
   v
out/main.bin                (complete 2 MiB / 32-bank EEPROM image)
```

ROMPACK is **always the final step**, including when no BMP is present.
The standalone assembler and ROMPACK executables are built automatically.
You do **not** need a separate copy of the emulator source.

### Ež3 cabin and panel layers

The project includes the user's two 320×200 Ež3 drawings in checksum-
verified archives. On `make`, these are restored to BMP automatically.
Direct BMPs from GIMP override the bundled archives:

- `assets/cab_ezh3_layer.bmp`: cabin *without* the dashboard.
- `assets/pult_ezh3.bmp`: the independent dashboard.

Both must use 320×200 uncompressed BMP (8/24/32-bit). Exact color keys:

- `#00FF00` (green) — display the live tunnel / rails in this region.
- `#0000FF` (blue) — reserved space for the independent dashboard.
- Other colors remain opaque; no alpha channel is needed.

ROMPACK reserves palette indices `FF` and `FE` for the green and blue
keys, respectively. ASM draws **track -> cabin (ROM 0001) -> panel (ROM 0002)**
using the transparent PIMG blitter. The window shapes now follow the BMP
mask rather than hardcoded rectangular viewports.

The old photographic Ež3 window mode is retained for ROMs with no separate
panel; no-image setups fall back to the procedural Ečs cockpit. The old
white HUD is suppressed for the new layered Ež3 artwork; animated needles
and controller sprites can be added to dedicated layers later.

Track motion still uses native PPA-1 ASM graphics, not the original
Metrostroi rail model atlas. See [assets/README.md](assets/README.md).

`out/main.prg` is the **64 KiB program file** from the assembler;
`out/main.bin` is the **final EEPROM image** built by ROMPACK, including when
no BMP is present. Do not load the `.prg` directly as a 2 MiB EEPROM image.

The **C** packer also handles other files at explicit ROM addresses:

```sh
make rompack
out/tools/ppa_rompack out/main.prg out/resources.bin \
    --bmp 0001:assets/cab_ecs.bmp \
    --put 0002:0100:path/to/anyfile.dat --info
```

See [the bitmap instructions](assets/README.md) for layout and palette
details. BANK and OFFSET are hexadecimal; bank 0000 contains program
instructions and is intentionally protected.

Additional targets: `make asm`, `make rompack`, `make symbols`, `make test-rompack`, `make clean`.

## Running

In [PPA-1_Emu](https://github.com/adamcir/PPA-1_Emu), install and
activate these modules *while CPU power is off*:

| Slot | Module | Banks |
|---|---|---|
| 1 | `ppa-vga-1.ppamod` | `2000` registers / `2001` VRAM |
| 2 | `ppa-ps2-1.ppamod` | `3000` |
| 3 | `ppa-sound-1.ppamod` | `4000` |

Build modules in the emulator repo with `make modules`. Load the
MetroDriver **`out/main.bin`** into EEPROM, power on and press RUN.
Open VGA VIEW and PS/2 keyboard VIEW; focus the keyboard window.
Try a CPU clock around **1 MHz**.

## Controls

- **W** (press and release): advance one controller notch.
- **S** (press and release): move back one controller notch.

Metrostroi KV-35-inspired positions:

```text
T2 <-> T1A <-> T1 <-> 0 <-> X1 <-> X2 <-> X3
```

`X1`–`X3` apply increasing traction, `0` coasts, and `T1`–`T2`
apply increasing braking. The controller has a delayed physical position,
speed changes gradually up to 80 km/h. The procedural Ečs HUD is retained,
while the Ež3 layered mode leaves room for dedicated moving instruments.

The game has a moving tunnel, moving sleepers and platform elements, trackside
signals with perspective changes, and a looping **DEPO → CENTRUM → LUKA**
route. Demonstration ARS speed codes are **80/70/60/40/0**, with an
overspeed indicator and SOUND alert. Moving scene geometry is drawn in PPA-1 ASM; the static Ež3
assets are converted to indexed PIMG by ROMPACK.

**Note:** this is a simple game, not a faithful reproduction of Metrostroi's
electrical, pneumatic, EPK or interlocking systems.

## References

The behavior was inspired by MetrostroiAddon:
[KV-35 controller](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/metrostroi/systems/sys_kv_35.lua),
[track signals](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/entities/gmod_track_signal/init.lua),
and [rail network / ARS](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/metrostroi/sv_railnetwork.lua).

The implementation is independent; Metrostroi Lua code and game assets
are not included.
