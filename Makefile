# PPA-1 MetroDriver: C ROM packer + assembler + optional GIMP BMP.
# (c) 2026 Adam Cir (Adava), Adava Software, Adava Development
CC ?= cc
CFLAGS ?= -O2 -std=gnu11

ASM_SOURCE := tools/asm/ppa-1_asm.c
ASM_BIN := out/asm/ppa-1_asm
ROMPACK_SOURCE := tools/rompack/ppa_rompack.c
ROMPACK_BIN := out/tools/ppa_rompack
ROM_PROGRAM := out/main.prg
ROM_IMAGE := out/main.bin
# Green (#00FF00) opens onto track; blue (#0000FF) reserves panel space.
# Asset in 0001: optional pult-less cab with transparent windows (future).
# Asset in 0002: independent panel. GIMP BMP overrides the bundled fallback.
PANEL_SOURCE := $(firstword $(wildcard assets/pult_ezh3.bmp))
PANEL_ARCHIVE := $(firstword $(wildcard assets/pult_ezh3.bmp.gz.b64))
PANEL_BMP := $(if $(PANEL_SOURCE),$(PANEL_SOURCE),$(if $(PANEL_ARCHIVE),out/assets/pult_ezh3.bmp))
LAYER_CAB_BMP := $(firstword $(wildcard assets/cab_ezh3_layer.bmp) $(wildcard assets/cab.bmp))
LEGACY_CAB_BMP := $(firstword $(wildcard assets/cab_ezh3.bmp) $(wildcard assets/cab_ecs.bmp))
CAB_BMP := $(if $(PANEL_BMP),$(LAYER_CAB_BMP),$(if $(LAYER_CAB_BMP),$(LAYER_CAB_BMP),$(LEGACY_CAB_BMP)))
INCLUDES := $(wildcard includes/*.inc)

.PHONY: all asm rompack symbols clean FORCE
all: $(ROM_IMAGE)

$(ASM_BIN): $(ASM_SOURCE)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

$(ROMPACK_BIN): $(ROMPACK_SOURCE)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -Wall -Wextra $< -o $@

# Stage 1: PPA-1 ASM -> single 64 KiB executable bank (not an EEPROM yet).
$(ROM_PROGRAM): main.asm $(INCLUDES) $(ASM_BIN)
	mkdir -p $(dir $@)
	$(ASM_BIN) main.asm $@ --program

# The original 24-bit uploaded BMP is kept losslessly in a short
# text archive so the build works even before the user uploads an editable BMP.
# Put a newer GIMP export at assets/pult_ezh3.bmp to override the archive.
out/assets/pult_ezh3.bmp: assets/pult_ezh3.bmp.gz.b64 tools/assets/restore_bmp.py
	mkdir -p $(dir $@)
	python3 tools/assets/restore_bmp.py $< $@

# Stage 2: program + optional cab/panel -> complete 2 MiB EEPROM image.
# With an independently drawn panel, do not bundle the legacy photographed
# cab (it already contains its own panel and would cause visual overlap).
$(ROM_IMAGE): $(ROM_PROGRAM) $(ROMPACK_BIN) $(if $(PANEL_SOURCE),,$(if $(PANEL_ARCHIVE),out/assets/pult_ezh3.bmp)) FORCE
	mkdir -p $(dir $@)
	$(ROMPACK_BIN) $(ROM_PROGRAM) $@ $(if $(CAB_BMP),--bmp 0001:$(CAB_BMP)) $(if $(PANEL_BMP),--bmp 0002:$(PANEL_BMP))

asm: $(ASM_BIN)
rompack: $(ROMPACK_BIN)

symbols: $(ASM_BIN) main.asm $(INCLUDES)
	mkdir -p out
	$(ASM_BIN) main.asm $(ROM_PROGRAM) --program --symbols
	$(MAKE) $(ROM_IMAGE)

clean:
	rm -rf out

FORCE:

.PHONY: test-rompack
test-rompack: $(ROMPACK_BIN)
	python3 tools/rompack/test_rompack.py $(ROMPACK_BIN)
