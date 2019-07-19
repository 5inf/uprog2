/******************************************************************************/
/* LNK.CMD - COMMAND FILE FOR LINKING C PROGRAMS                              */
/*                                                                            */
/*      Usage:  cl2000 -z <obj files...> -o <out file> -m <map file> lnk.cmd  */
/*              cl2000 <src files...> -z -o <out file> -m <map file> lnk.cmd  */
/*                                                                            */
/*      Description: This file is a sample command file that can be used      */
/*                   for linking programs built with the C Compiler.          */
/*                   Use it as a guideline; you  may want to change the       */
/*                   allocation scheme according to the size of your program  */
/*                   and the memory layout of your target system.             */
/*                   This command file works for C27x and C28x.               */
/*                                                                            */
/******************************************************************************/

-c                    /* Use C linking conventions: auto-init vars at runtime */
-stack    0x0100      /* Primary stack size   */
-heap     0x0200      /* Heap area size       */
-farheap  0x0100      /* Far Heap area size   */

MEMORY
{
PAGE 0 : RESET      : origin = 0x000000, length =  0x00002
         VECTORS(R) : origin = 0x000002, length =  0x003FE
         OTP (RX)   : origin = 0x3d7800, length =  0x00400
         FLASH (RX) : origin = 0x3d8000, length =  0x20000
PAGE 0 : RAM1       : origin = 0x3f8000 , length = 0x01000
PAGE 1 : RAM0       : origin = 0x000200 , length = 0x00200
PAGE 1 : RAM1       : origin = 0x3f8000 , length = 0x00c00
PAGE 0 : RAM2       : origin = 0x3f9000 , length = 0x00400
PAGE 1 : RAM3       : origin = 0x3fa000 , length = 0x02000
}
 
SECTIONS
{
	vectors : load = VECTORS, PAGE = 0
	codestart: > RAM1, PAGE = 0
	.text    : > RAM1, PAGE = 0
	.data    : > RAM2, PAGE = 0
	.cinit   : > RAM1, PAGE = 0
	.bss     : > RAM2, PAGE = 0
	.ebss    : > RAM2, PAGE = 0
	.econst  : > RAM2, PAGE = 0
	.const   : > RAM2, PAGE = 0
	.reset   : > RESET, PAGE = 0
	.stack   : > RAM0, PAGE = 1
	.sysmem  : > RAM2, PAGE = 0
	.esysmem : > RAM2, PAGE = 0
}
