# PPA-1 MetroDriver

A metro-driving game written entirely in **PPA-1 assembly**. Current cab: **Ečs**.
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

### GIMP BMP resources in EEPROM

To use a detailed VGA background for the Ečs cab, export a **320×200**
**uncompressed BMP** from GIMP (indexed 8-bit or RGB 24/32-bit). Save it as:

```text
assets/cab_ecs.bmp
```

Now run `make` again. The build converts the BMP into a **PIMG** image in
EEPROM **bank 0001**. On boot the ASM graphics library
(`includes/ppa-gfx.inc`) loads the palette and transfers 64,000 pixels
to VGA VRAM (slot 1, bank 2001). The tunnel/rails, ARS, speedometer and
moving controls continue to be animated by ASM; the static cab background
comes from the BMP. Without the BMP the game falls back to its original
procedural Ečs panel.

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
speed changes gradually up to 80 km/h, and the speed and controller
position are shown on the VGA desk.

The game has a moving tunnel, moving sleepers and platform elements, trackside
signals with perspective changes, and a looping **DEPO → CENTRUM → LUKA**
route. Demonstration ARS speed codes are **80/70/60/40/0**, with an
overspeed indicator and SOUND alert. All rendering uses PPA-1 ASM rather
than externally generated images.

**Note:** this is a simple game, not a faithful reproduction of Metrostroi's
electrical, pneumatic, EPK or interlocking systems.

## References

The behavior was inspired by MetrostroiAddon:
[KV-35 controller](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/metrostroi/systems/sys_kv_35.lua),
[track signals](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/entities/gmod_track_signal/init.lua),
and [rail network / ARS](https://github.com/metrostroi-repo/MetrostroiAddon/blob/dev/lua/metrostroi/sv_railnetwork.lua).

The implementation is independent; Metrostroi Lua code and game assets
are not included.
