# PPA-1 MetroDriver

A metro-driving game written entirely in **PPA-1 assembly**. Current cab: **Ečs**.
The game runs on the emulated PPA-1 processor; VGA graphics, HUD, track,
keyboard, signals, and sound are produced by PPA-1 instructions.

Copyright (c) 2026 Adam Cír (Adava), Adava Software, Adava Development.

## Project files

```text
main.asm                    Game entry point, physics, ARS, renderer and sound
includes/ppa-vga.inc        PPA-VGA/1 interface (slot 1)
includes/ppa-ps2.inc        PPA-PS/2/1 interface (slot 2)
tools/asm/ppa-1_asm.c       Local PPA-1 assembler source
Makefile                    Standalone build instructions
```

The sound-card interface (slot 3) is defined in `main.asm`.

## Build

Linux / GCC or compatible C compiler and `make`:

```sh
git clone https://github.com/adamcir/PPA-1_MetroDriver.git
cd PPA-1_MetroDriver
make
```

This produces **`out/main.bin`**, a 2 MiB PPA-1 EEPROM image, and
`out/asm/ppa-1_asm` (the bundled assembler). You do **not** need a separate
copy of the emulator source to compile the game.

Additional targets: `make asm`, `make symbols`, `make clean`.

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
