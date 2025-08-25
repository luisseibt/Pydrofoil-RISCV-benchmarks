.globl _start

.text

_start:
# Linux requirements: https://docs.kernel.org/arch/riscv/boot.html
add		a0,zero,zero		# hartid

# load 0x82200000 into a1: location of device tree
li      a1,0x82200000

# set satp to 0: disable mmu
csrw    satp,zero

# load 0x80200000 into a5: location of Linux kernel entry
li      a5,0x80200000

# jump to address in a5 with no offset and don't store the return address
jalr	zero,a5,0

_end:
j _end
