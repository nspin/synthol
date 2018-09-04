OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)

ENTRY(_start)

SECTIONS
{
    . = 0x00400000; /* make catching null pointers easier */

    .text : {
        __text_start = .;
        *(.text)
        *(.gnu.warning)
        . = ALIGN(4096);
        __text_end = .;
    } = 0x9090

    .rodata : {
        __rodata_start = .;
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4096);
        __rodata_end = .;
    }

    .data : {
        __data_start = .;
        *(.data)
        . = ALIGN(4096);
        __data_end = .;
    }

    . = ALIGN(4096);

    .bss : {
        __bss_start = .;
        *(.bss)
        . = ALIGN(4096);
        __bss_end = .;
    }

    /DISCARD/ : {
        *( .text.exit     )
        *( .data.exit     )
        *( .exitcall.exit )
      }

    .stab          0 : { *( .stab          ) }
    .stabstr       0 : { *( .stabstr       ) }
    .stab.excl     0 : { *( .stab.excl     ) }
    .stab.exclstr  0 : { *( .stab.exclstr  ) }
    .stab.index    0 : { *( .stab.index    ) }
    .stab.indexstr 0 : { *( .stab.indexstr ) }
    .comment       0 : { *( .comment       ) }
}
