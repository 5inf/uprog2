################################################################################
#                                                                              #
#   SPX-Bootloader for EFM32                                                   #
#                                                                              #
#   (c) 2020 Joerg Wolfram                                                     #
#                                                                              #
################################################################################
		.include "regdefs.asm"		
		.include "config.asm"
		.include "predefine.asm"
		
		.text
		.thumb
		.cpu cortex-m3

		.globl reset_addr
	
reset_addr:

		.word 0x20000FFC
		.word 0x20000009		

main:
################################################################################
# init
################################################################################
			//enable ports+MSC in CMU
			
			ldr	r5, = CMU_CLKEN0
			ldr	r4, = 0x04000000	//enable GPIO
			str	r4,[r5,#0]
			ldr	r4, = 0x00020000	//enable MSC
			str	r4,[r5,#4]			

			ldr	r5, = GPIOA_CTRL
			ldr	r4, =0x4000 
			str	r4,[r5,#4]
			
			movs	r4, #8
			str	r4,[r5,#16]

						
################################################################################
# the main loop
################################################################################
main_loop:		ldr	r1, =0x20000c00		// CMD/ADDR
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

			cmp	r0,#0x54		// prog flash (256B)
			beq	prog_flash1

			ldr	r0,=10000
wx1:			sub	r0,#1
			bne	wx1
			
			b	main_loop
			
			
################################################################################
# program 2K
################################################################################
prog_flash:		ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x200		// lw to do
			ldr	r1, = MSC_BASE
			movs	r2,#1
			str	r2,[r1,#MSC_WRITECTRL]

prog_flash_1:		str	r3,[r1,#MSC_ADDRB]	//address
			ldr	r2,[r4,#0]
			str	r2,[r1,#MSC_WDATA]

prog_flash_2:		ldr	r2,[r1,#MSC_STATUS]
			movs	r5,#8
			and	r2,r5
			beq	prog_flash_2
		
			add	r3,#4
			add	r4,#4
			sub	r7,#1
			
			bne	prog_flash_1

			movs	r2,#0
			str	r2,[r1,#MSC_WRITECTRL]
			b	main_loop

			
################################################################################
# program 256 Bytes
################################################################################
prog_flash1:		ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x40		// lw to do
			ldr	r1, = MSC_BASE
			movs	r2,#1
			str	r2,[r1,#MSC_WRITECTRL]

prog_flash1_1:		str	r3,[r1,#MSC_ADDRB]	//address
			ldr	r2,[r4,#0]
			str	r2,[r1,#MSC_WDATA]

prog_flash1_2:		ldr	r2,[r1,#MSC_STATUS]
			movs	r5,#8
			and	r2,r5
			beq	prog_flash1_2
		
			add	r3,#4
			add	r4,#4
			sub	r7,#1
			
			bne	prog_flash1_1

			movs	r2,#0
			str	r2,[r1,#MSC_WRITECTRL]
			b	main_loop

################################################################################
# blink
################################################################################
blink:			ldr	r5, = GPIOA_CTRL
			ldr	r4, =0x4000 
			str	r4,[r5,#4]
			
p1:			movs	r4, #0
			str	r4,[r5,#16]
			ldr	r6, =1000000
p2:			sub	r6,#1
			bne	p2
						
p3:			movs	r4, #8
			str	r4,[r5,#16]
			ldr	r6, =100000
p4:			sub	r6,#1
			bne	p4
			
			b	p1			
								
			
			