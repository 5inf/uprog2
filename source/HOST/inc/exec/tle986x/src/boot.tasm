################################################################################
#                                                                              #
#   Bootloader for TLE986x                                                     #
#                                                                              #
#   (c) 2022 Joerg Wolfram                                                     #
#                                                                              #
################################################################################
		.include "regdefs.asm"		
		
		.text
		.thumb
		.cpu cortex-m3

		.globl main
	
reset_addr:
		.word 0x180003FC	//
		.word 0x18000009		

main:
################################################################################
# init
################################################################################			
//			ldr	r5, =GPIO_BASE
			
//			mov	r1, #0x01
//			strb	r1,[r5,#GPIO_P1_DIR]
			
//			mov	r1, #0x01
//			strb	r1,[r5,#GPIO_P1_DATA]


################################################################################
# the main loop
################################################################################
main_loop:		ldr	r1, =0x18000c00		//cmd word
			mov	r2,#0		
			str	r2,[r1,#0]		//set to zero

main_loop_wait:		ldr	r0, [r1,#0]
			cmp	r0, r2
			beq	main_loop_wait
			
			mov	r7,r0
			ldr	r2,=0xFFFFFF00
			and	r7,r2
			mov	r2,#0xFF
			and	r0,r2
			
			cmp	r0, #0x54		// prog main flash
			beq	erase_flash

			cmp	r0, #0x52		// prog main flash
			beq	prog_flash

tloop:			b	main_loop

################################################################################
# erase 2K flash (16 pages) 
################################################################################
erase_flash:		mov	r6,#16			//pages to erase
erase_flash_1:		mov	r0,r7			//copy address
			ldr	r5,=0x38D5		//erase page
			blx	r5
			mov	r2,#0x80
			add	r7,r2
			sub	r6,#1
			bne	erase_flash_1
			b	main_loop			
			
################################################################################
# program 2K flash
################################################################################
prog_flash:		ldr	r4, =0x18000400		//buffer base
			mov	r6, #16			//pages to do			

prog_flash_1:		mov	r0,r7			//param
			ldr	r5,=0x38e5		//open
			blx	r5

			mov	r1,#32
prog_flash_2:		ldr	r2,[r4,#0]
			str	r2,[r7,#0]
			add	r4,#4
			add	r7,#4
			sub	r1,#1
			bne	prog_flash_2
			
			mov	r0,#0
			ldr	r5,=0x38DD
			blx	r5
			
			sub	r6,#1
			bne	prog_flash_1
			b	main_loop			

			.align 2
		

		