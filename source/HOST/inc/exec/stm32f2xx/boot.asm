		.include "include/regdefs.asm"

		.text
		.thumb

		.org 0x00000
	
reset_vector:

		.word 0x20001000	// start SP
		.word 0x20000009	// start PC

main_start:
################################################################################
# set rcc
################################################################################

			
################################################################################
# set wait states
################################################################################
			ldr	r4, =FLASH_BASE
			mov	r3,#0x31		//1 wait state
			str	r3,[r4,#FLASH_ACR]

################################################################################
# the main loop
################################################################################
main_loop:		ldr	r1, =0x20000c00		//cmd word
			mov	r2,#0		
			str	r2,[r1,#0]		//et to zero

main_loop_wait:		ldr	r0, [r1,#0]
			cmp	r0, r2
			beq	main_loop_wait
			mov	r7,r0			//address
			ldr	r2,=0xFFFFFF00
			and	r7,r2
			mov	r2,#0xff
			and	r0,r2			

			cmp	r0, #0x52		// prog main flash
			beq	prog_flash

			cmp	r0, #0x72		// prog option bytes
			beq	prog_opt

tloop:			b	main_loop

		
################################################################################
# program 2K flash
################################################################################
prog_flash:		ldr	r2, =0x80000		//512K limit
			mov	r3,r7			//addr
			and	r3,r2
			cmp	r3,r2
			beq	prog_flash1		//use block 1

			ldr	r1, =0x20000400		//buffer base
			ldr	r6, =0x400		//halfwords to do
			ldr	r4, =FLASH_BASE
			ldr	r2, =0x45670123		//key 1
			ldr	r3, =0xCDEF89AB		//key 2
			str	r2,[r4,#FLASH_KEYR]	//write key 1	
			str	r3,[r4,#FLASH_KEYR]	//write key 2	
			mov	r3,#0
			str	r3,[r4,#FLASH_CR]
			
			
prog_flash_1:		ldrh	r0,[r1,#0]		//get data
			ldr	r3,=0xFFFF		//empty
			cmp	r0,r3
			beq	prog_flash_3a		//nothing to do

			ldr	r2, [r4,#FLASH_CR]
			mov	r3,#0x01		//set PG
			orr	r2,r3
			str	r2, [r4,#FLASH_CR]

			strh	r0,[r7,#0]		//store half word
			lsr	r0,#16

			mov	r3,#0x01		//BSY
prog_flash_3:		ldr	r2, [r4,#FLASH_SR]
			tst	r2,r3
			bne	prog_flash_3

prog_flash_3a:		add	r7,#2			//flash addr
			add	r1,#2			//buffer addr

prog_flash_4:		sub	r6,#1
			bne	prog_flash_1			
			
			b	main_loop

################################################################################
# program 1K flash (block 1)
################################################################################
prog_flash1:		ldr	r1, =0x20000400		//buffer base
			ldr	r6, =0x400		//halfwords to do
			ldr	r4, =FLASH_BASE
			mov	r3,#0
			str	r3,[r4,#FLASH_CR2]
			ldr	r2, =0x45670123		//key 1
			ldr	r3, =0xCDEF89AB		//key 2
			str	r2,[r4,#FLASH_KEYR2]	//write key 1	
			str	r3,[r4,#FLASH_KEYR2]	//write key 2	
			
			
prog_flash1_1:		ldrh	r0,[r1,#0]		//get data
			ldr	r3,=0xFFFF		//empty
			cmp	r0,r3
			beq	prog_flash1_3a		//nothing to do

			ldr	r2, [r4,#FLASH_CR2]
			mov	r3,#0x01		//set PG
			orr	r2,r3
			str	r2, [r4,#FLASH_CR2]

			strh	r0,[r7,#0]		//store half word
			lsr	r0,#16

			mov	r3,#0x01		//BSY
prog_flash1_3:		ldr	r2, [r4,#FLASH_SR2]
			tst	r2,r3
			bne	prog_flash1_3

prog_flash1_3a:		add	r7,#2			//flash addr
			add	r1,#2			//buffer addr

prog_flash1_4:		sub	r6,#1
			bne	prog_flash1_1			
			
			b	main_loop



################################################################################
# program option bytes
################################################################################
prog_opt:		ldr	r1, =0x20000400		//buffer base
			ldr	r6, =0x08		//halfwords to do

			ldr	r4, =FLASH_BASE
			mov	r3,#0
			str	r3,[r4,#FLASH_CR]
			ldr	r2, =0x45670123		//key 1
			ldr	r3, =0xCDEF89AB		//key 2
			str	r2,[r4,#FLASH_KEYR]	//write key 1	
			str	r3,[r4,#FLASH_KEYR]	//write key 2	
			str	r2,[r4,#FLASH_OPTKEYR]	//write key 1	
			str	r3,[r4,#FLASH_OPTKEYR]	//write key 2	

prog_opt_1:		ldrh	r0,[r1,#0]		//get data
			
			//program half-word
			ldr	r2, [r4,#FLASH_CR]
			mov	r3,#0x10		//set OPTPG
			orr	r2,r3
			str	r2, [r4,#FLASH_CR]
			
			strh	r0,[r7,#0]	

			mov	r3,#1			//BSY
prog_opt_3:		ldr	r2, [r4,#FLASH_SR]
			tst	r2,r3
			bne	prog_opt_3


prog_opt_4:		add	r7,#2
			add	r1,#2
			sub	r6,#1
			bne	prog_opt_1			

			//disable
			mov	r3,#0x00		//reset PG
			str	r3, [r4,#FLASH_CR]
			
			b	main_loop

					
			.align 2
		

		