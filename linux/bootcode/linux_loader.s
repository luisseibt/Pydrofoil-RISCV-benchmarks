.globl _start

.text
_start:
	# Linux requirements: https://docs.kernel.org/arch/riscv/boot.html
	add		a0,zero,zero		# hartid

	# load 0x80000200 into a1: location of device tree
	li      a1,0x1
	slli    a1,a1,35
	addi    a1,a1,0x200

	# set satp to 0: disable mmu
	csrw    satp,zero
	
	# load 0x880200000 into a5: location of Linux kernel entry
	li      a5,0x4401000
	slli    a5,a5,9

	# jump to address in a5 with no offset and don't store the return address
	jalr	zero,a5,0
