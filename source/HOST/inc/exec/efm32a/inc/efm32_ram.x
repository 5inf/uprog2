   /* Entry Point */
   ENTRY(reset_addr)

   /* Specify the memory areas */
   MEMORY
   {
	RAM (rwx)	: ORIGIN = 0x20000000, LENGTH = 0x3800
   }

   /* define stack size and heap size here */
   stack_size = 1024;
   heap_size = 256;

   /* define beginning and ending of stack */
   _stack_start = ORIGIN(RAM)+LENGTH(RAM);
   _stack_end = _stack_start - stack_size;

   /* Define output sections */
   SECTIONS
   {
     .text :
     {
       . = ALIGN(4);
       *(.startup)	  /* .startup section */
       *(.text)           /* .text sections (code) */
       *(.text*)          /* .text* sections (code) */
       *(.libs)           /* .libs sections (code) */
       *(.rodata)         /* .rodata sections (constants, strings, etc.) */
       *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
       *(.glue_7)         /* glue arm to thumb code */
       *(.glue_7t)        /* glue thumb to arm code */
 
       . = ALIGN(4);
      _sdata = .;        /* create a global symbol at data start */
       *(.data)           /* .data sections */
       *(.data*)          /* .data* sections */
      _edata = .;        /* define a global symbol at data end */
 
     . = ALIGN(4);

       _sbss = .;         /* define a global symbol at bss start */
       *(.bss)
       *(.bss*)
       *(COMMON)
      _ebss = .;         /* define a global symbol at bss end */
 
       . = ALIGN(4);

       _etext = .;        /* define a global symbols at end of code */
     } >RAM

      .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >RAM
       .ARM : {
       __exidx_start = .;
         *(.ARM.exidx*)
         __exidx_end = .;
       } >RAM

     /* used by the startup to initialize data */
     _sidata = 0;
 
       __bss_start__ = _sbss;
       __bss_end__ = _ebss;

       . = ALIGN(4);
       .heap :
       {
           _heap_start = .;
           . = . + heap_size;
                   _heap_end = .;
       } > RAM

       .ARM.attributes 0 : { *(.ARM.attributes) }
   }
