###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami  Nils Bosbach                                 #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################


CC     := riscv64-linux-gnu-gcc
OC     := riscv64-linux-gnu-objcopy
CFLAGS := -Wl,--build-id=none -T fw_jump.ld -nostdlib

O := .

ELFBIN := fw_jump.elf
RAWBIN := fw_jump.bin

.PHONY: all clean
all: dirs $(O)/$(RAWBIN)

clean:
	$(RM) $(O)/$(RAWBIN) $(O)/$(ELFBIN)

dirs: $(O)

$(O):
	mkdir -p $(O)

$(O)/$(RAWBIN): $(O)/$(ELFBIN)
	$(OC) -O binary $< $@

$(O)/$(ELFBIN): fw_jump.S fw_jump.ld
	$(CC) $(CFLAGS) $< -o $@
