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
CAB_BMP := assets/cab_ecs.bmp
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

# Stage 2: program + optional GIMP BMP -> complete 2 MiB EEPROM image.
# Run ROMPACK even without assets; it is the ONLY producer of the final .bin.
# FORCE also notices when the optional BMP has been added or removed.
$(ROM_IMAGE): $(ROM_PROGRAM) $(ROMPACK_BIN) FORCE
	mkdir -p $(dir $@)
	@if [ -f "$(CAB_BMP)" ]; then \
	  $(ROMPACK_BIN) $(ROM_PROGRAM) $@ --bmp 0001:$(CAB_BMP); \
	else \
	  $(ROMPACK_BIN) $(ROM_PROGRAM) $@; \
	fi

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
