# PPA-1 MetroDriver: C ROM packer + assembler + optional GIMP BMP.
# (c) 2026 Adam Cir (Adava), Adava Software, Adava Development
CC ?= cc
CFLAGS ?= -O2 -std=gnu11

ASM_SOURCE := tools/asm/ppa-1_asm.c
ASM_BIN := out/asm/ppa-1_asm
ROMPACK_SOURCE := tools/rompack/ppa_rompack.c
ROMPACK_BIN := out/tools/ppa_rompack
ROM_CODE := out/main.code.bin
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

$(ROM_CODE): main.asm $(INCLUDES) $(ASM_BIN)
	mkdir -p $(dir $@)
	$(ASM_BIN) main.asm $@

# Repack every call to 'make', including when the optional BMP is removed.
# Never pack into main.code.bin: keep the assembler output clean.
$(ROM_IMAGE): $(ROM_CODE) $(ROMPACK_BIN) FORCE
	mkdir -p $(dir $@)
	@if [ -f "$(CAB_BMP)" ]; then \
	  $(ROMPACK_BIN) $(ROM_CODE) $@ --bmp 0001:$(CAB_BMP); \
	else \
	  cp $(ROM_CODE) $@; \
	  echo "No $(CAB_BMP): built procedural ASM graphics (no BMP needed)."; \
	fi

asm: $(ASM_BIN)
rompack: $(ROMPACK_BIN)

symbols: $(ASM_BIN) main.asm $(INCLUDES)
	mkdir -p out
	$(ASM_BIN) main.asm $(ROM_CODE) --symbols
	$(MAKE) $(ROM_IMAGE)

clean:
	rm -rf out

FORCE:

.PHONY: test-rompack
test-rompack: $(ROMPACK_BIN)
	python3 tools/rompack/test_rompack.py $(ROMPACK_BIN)
