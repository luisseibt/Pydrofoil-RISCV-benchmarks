/******************************************************************************
 *                                                                            *
 * Copyright 2026 Chiara Ghinami  Nils Bosbach                                *
 *                                                                            *
 * This software is licensed under the MIT license found in the               *
 * LICENSE file at the root directory of this source tree.                    *
 *                                                                            *
 *****************************************************************************/

ENTRY(_start)
OUTPUT_ARCH(riscv)

PHDRS
{
  text PT_LOAD FLAGS (R + X);
  data PT_LOAD FLAGS (R + W);
}


SECTIONS
{
	. = 0x80000000;

	.text : { *(.text) } : text /* place text, i.e. code first */
	.data : { *(.data) } : data /* no data exists */
	.bss  : { *(.bss) }  : data  /* no bss exists */
}
