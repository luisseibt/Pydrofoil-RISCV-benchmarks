.globl _start

.text

_start:
# Linux requirements: https://docs.kernel.org/arch/riscv/boot.html
# a0 already contais the hart id

csrw satp,zero # set satp to 0: disable mmu
li a1,0x82200000 # device tree location in a1
li a5,0x80200000 # linux kernel entry in a5
jalr zero,a5,0 # jump to linux kernel

_end:
j _end
