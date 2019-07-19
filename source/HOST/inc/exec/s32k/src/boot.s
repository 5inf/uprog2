################################################################################
#                                                                              #
#   Bootloader for S32K                                                        #
#                                                                              #
################################################################################
		.include "regdefs.asm"
		
		.text
		.thumb
		.cpu cortex-m0

		.org 0
	
reset_vector:

		.word 0x20000FFC	// start SP
		.word 0x20000009	// start PC

main_start:
################################################################################
# init clock system 
################################################################################
			cpsie	i			//disable interrupts
			ldr	r5, =WDOG_BASE		//WDOG base
			ldr	r3, =0x00002900		//disable
			ldr	r4, =0x0000FFFF		//init TOVAL
			str	r3, [r5,#WDOG_CS]
			str	r4, [r5,#WDOG_TOVAL]
			
			ldr	r5, =PCC_BASE2		//port A enable in PCC
			ldr	r2, =PCC_ACTIVE
			str	r2, [r5,#PCC_PORTA]


			ldr	r5, =PORTA_BASE		//port A in PORT
			ldr	r2, =0x140
			str	r2, [r5,#PCR10]
			str	r2, [r5,#PCR11]
			
			ldr	r5, =GPIOA_BASE		//port A in GPIO
			ldr	r2, =0xC00
			str	r2, [r5,#PDDR]
			
################################################################################
# the main loop
################################################################################
main_loop:		ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x400		// LED 1
			str	r2, [r5,#PDOR]

			ldr	r1, =0x20000c00		// CMD/ADDR
			mov	r2, #0
			str	r2, [r1,#0]
			
main_loop_wait:		ldr	r0, [r1,#0]
			cmp	r0,r2
			beq	main_loop_wait
			mov	r3,r0
			ldr	r2, =0xFFFFFF00
			and	r3,r2			// this is our address
			mov	r2,#0xFF
			and	r0,r2			// this is our cmd

			cmp	r0,#0x52		// prog flash
			beq	prog_flash

			cmp	r0,#0x51		// read flash
			beq	read_flash
			
			b	main_loop

prog_flash:		ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x800		// LED 2
			str	r2, [r5,#PDOR]

			ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x100		// rows to do
prog_flash_1:		bl	prog_row
			sub	r7,#1
			bne	prog_flash_1
			b	main_loop
			
################################################################################
# program 8 bytes
# r3 = address
# r4 = pointer to SRAM 
################################################################################
prog_row:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70
			strb	r2, [r5,#FSTAT]
			movs	r2, #0x07
			strb	r2, [r5,#FCCOB0]
			mov	r2,r3
			strb	r2, [r5,#FCCOB3]
			lsr	r2,#8
			strb	r2, [r5,#FCCOB2]
			lsr	r2,#8
			strb	r2, [r5,#FCCOB1]
			ldr	r2, [r4,#0]
			str	r2, [r5,#FCCOB7]
			ldr	r2, [r4,#4]
			str	r2, [r5,#FCCOBB]
			movs	r2,#0x80
			strb	r2, [r5,#FSTAT]
			movs	r1, #0x80
prog_row_loop:		ldrb	r2, [r5,#FSTAT]
			and	r2, r1
			beq	prog_row_loop
			add	r3,#8
			add	r4,#8
			bx	lr
			
################################################################################
# read out 2K Flash
################################################################################
read_flash:		ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x200		// LW to do
read_flash_1:		ldr	r2,[r3,#0]
			str	r2,[r4,#0]
			add	r3,#4
			add	r4,#4
			sub	r7,#1
			bne	read_flash_1
			b	main_loop
					