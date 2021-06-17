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
#			ldr	r4, =RCC_BASE
#			mov	r3,#0x04		//PORTC enable
#			str	r3,[r4,#RCC_AHB1ENR]

#			ldr	r5, =PORTC_BASE
#			ldr	r3, =0x00050000		//PORTC enable
#			str	r3,[r5,#PORTC_MODER]
#			ldr	r3, =0x0300		//PORTC set
#			str	r3,[r5,#PORTC_ODR]
					
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
			str	r2,[r1,#0]		//set to zero
#			ldr	r3, =0x0100		//PORTC set
#			str	r3,[r5,#PORTC_ODR]


main_loop_wait:		ldr	r0, [r1,#0]
			cmp	r0, r2
			beq	main_loop_wait
			
			ldr	r4, =FLASH_BASE
#			ldr	r3, =0x0200		//PORTC set
#			str	r3,[r5,#PORTC_ODR]
			
			mov	r7,r0			//address
			ldr	r2,=0xFFFFFF00
			and	r7,r2
			mov	r2,#0xff
			and	r0,r2			

			cmp	r0, #0x52		// prog main flash
			beq	prog_flash

			cmp	r0, #0x72		// prog option bytes
			beq	x_prog_opt

tloop:			b	main_loop

x_prog_opt:		b	prog_opt			
			

################################################################################
# program 2K flash
################################################################################
prog_flash:		bl	main_unlock		//unlock

			ldr	r1, =0x20000400		//buffer base
			ldr	r6, =0x200		//words to do			
			
prog_flash_1:		ldr	r0,[r1,#0]		//get data
			ldr	r3,=0xFFFFFFFF		//empty
			cmp	r0,r3
			beq	prog_flash_4		//nothing to do

			ldr	r2, [r4,#FLASH_CR]
			ldr	r3, =0x200		//x32
			orr	r2,r3
			str	r2, [r4,#FLASH_CR]
			mov	r3,#0x01		//set PG
			orr	r2,r3
			str	r2, [r4,#FLASH_CR]

			str	r0,[r7,#0]		//store word

			ldr	r3, =0x010000		//BSY
prog_flash_3:		ldr	r2, [r4,#FLASH_SR]
			tst	r2,r3
			bne	prog_flash_3

prog_flash_4:		add	r7,#4			//flash addr
			add	r1,#4			//buffer addr

			sub	r6,#1
			bne	prog_flash_1			
			
			b	main_loop


################################################################################
# program option bytes
################################################################################
prog_opt:		ldr	r2, =0x08192A3B		//key 1
			ldr	r3, =0x4C5D6E7F		//key 2
//			str	r2,[r4,#FLASH_KEYR]	//write key 1	
//			str	r3,[r4,#FLASH_KEYR]	//write key 2	
			str	r2,[r4,#FLASH_OPTKEYR]	//write key 1	
			str	r3,[r4,#FLASH_OPTKEYR]	//write key 2	
	
			ldr	r1, =0x20000400		//buffer base

			ldr	r4, =FLASH_BASE
			mov	r3,#0
			str	r3,[r4,#FLASH_CR]

prog_opt_1:		ldr	r0,[r1,#0]		//get data
			ldr	r2, = 0xFFFFFFFC
			and	r0,r2
			str	r0,[r4,#FLASH_OPTCR]
			mov	r2,#0x02
			orr	r0,r2
			str	r0,[r4,#FLASH_OPTCR]
			
			ldr	r3, =0x010000		//BSY
prog_opt_3:		ldr	r2, [r4,#FLASH_SR]
			tst	r2,r3
			bne	prog_opt_3
			
			b	main_loop


################################################################################
# unlock main flash
################################################################################
main_unlock:		ldr	r4, =FLASH_BASE
			ldr	r2,[r4,#FLASH_CR]
			ldr	r3,=0x80000000
			and	r2,r3
			cmp	r3,r2
			bne	main_unlock_1		//is already unlocked
			
			ldr	r2, =0x45670123		//key 1
			ldr	r3, =0xCDEF89AB		//key 2
			str	r2,[r4,#FLASH_KEYR]	//write key 1	
			str	r3,[r4,#FLASH_KEYR]	//write key 2	
main_unlock_1:		mov	r3,#0
			str	r3,[r4,#FLASH_CR]

			bx	lr
					
			.align 2
		

		