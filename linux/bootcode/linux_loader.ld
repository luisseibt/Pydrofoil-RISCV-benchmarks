ENTRY(_start)

PHDRS
{
  text PT_LOAD FLAGS (R + X);
  data PT_LOAD FLAGS (R + W);
}


SECTIONS
{
	. = 0x0;

	.text : { *(.text) } : text /* place text, i.e. code first */
	.data : { *(.data) } : data /* no data exists */
	.bss  : { *(.bss) }  : data  /* no bss exists */

	. = ALIGN(0x1000);
}
