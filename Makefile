# PPA-1 MetroDriver - self-contained build
# (c) 2026 Adam Cir (Adava), Adava Software, Adava Development
#
# No separate PPA-1_Emu checkout is required to build this game.
# The assembler is built from tools/asm/ppa-1_asm.c.

CC ?= cc
CFLAGS ?= -O2 -std=gnu11

ASM_SOURCE := tools/asm/ppa-1_asm.c
ASM_BIN := out/asm/ppa-1_asm
ROM_IMAGE := out/main.bin
INCLUDES := $(wildcard includes/*.inc)

.PHONY: all asm symbols clean
all: $(ROM_IMAGE)

$(ASM_BIN): $(ASM_SOURCE)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

$(ROM_IMAGE): main.asm $(INCLUDES) $(ASM_BIN)
	mkdir -p $(dir $@)
	$(ASM_BIN) main.asm $@

asm: $(ASM_BIN)

symbols: $(ASM_BIN) main.asm $(INCLUDES)
	mkdir -p out
	$(ASM_BIN) main.asm $(ROM_IMAGE) --symbols

clean:
	rm -rf out
