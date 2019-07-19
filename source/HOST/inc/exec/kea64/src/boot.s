################################################################################
#                                                                              #
#  Bootloader for S9KEA64                                                      #
#                                                                              #
################################################################################
		.include "regdefs.asm"
		
		.text
		.thumb
		.cpu cortex-m0

		.org 0
	
reset_vector:

		.word 0x1FFFFFFC	// start SP
		.word 0x20000009	// start PC

main_start:
################################################################################
# init clock system 
################################################################################
			cpsie	i			//disable interrupts
			ldr	r5, =WDOG_BASE		//WDOG base
			ldr	r3, = 0x20C5
			strh	r3, [r5,#WDOG_CNTH]
			ldr	r3, = 0x28D9
			strh	r3, [r5,#WDOG_CNTH]

			ldr	r3, = 0x1000
			strh	r3, [r5,#WDOG_TOVALH]

			movs	r3, #0x00		//first
			strb	r3, [r5,#WDOG_CS2]
			strb	r3, [r5,#WDOG_CS1]

			// trim ICS to 8MHz
			ldr	r5, =ICS_BASE		
			mov	r2, #0x80
			strb	r2, [r5,#ICS_C3]

			ldr	r5, =FLASH_BASE		
			mov	r2, #0x0F		// 15,6-16,6 MHz
			strb	r2, [r5,#FCLKDIV]

################################################################################
# the main loop
################################################################################
main_loop:		ldr	r1, =0x20000000		// CMD/ADDR
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

			cmp	r0,#0x62		// prog eeprom
			beq	prog_eeprom

			cmp	r0,#0x61		// read eeprom
			beq	read_eeprom
			
			b	main_loop

prog_flash:		ldr	r4,=0x20000200		// buffer address
			ldr	r7,=0x80		// rows to do
prog_flash_1:		bl	prog_row
			sub	r7,#1
			bne	prog_flash_1
			b	main_loop

prog_eeprom:		ldr	r4,=0x20000200		// buffer address
			ldr	r7,=0x100		// bytes to do
prog_eeprom_1:		bl	prog_ebyte
			sub	r7,#1
			bne	prog_eeprom_1
			b	main_loop

			
################################################################################
# program 8 bytes
# r3 = address
# r4 = pointer to SRAM 
################################################################################
prog_row:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70
			strb	r2, [r5,#FSTAT]
			
			//FCCOB0
			movs	r2,#0			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldr	r2, =0x0006		// program Flash (block=0)
			strh	r2, [r5,#FCCOBHI]

			//FCCOB1
			movs	r2,#1			//PTR
			strb	r2, [r5,#FCCOBIX]
			mov	r2,r3
			strb	r2, [r5,#FCCOBLO]
			lsr	r2,#8
			strb	r2, [r5,#FCCOBHI]

			//FCCOB2
			movs	r2,#2			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldrb	r2, [r4,#0] 
			strb	r2, [r5,#FCCOBLO]
			ldrb	r2, [r4,#1] 
			strb	r2, [r5,#FCCOBHI]

			//FCCOB3
			movs	r2,#3			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldrb	r2, [r4,#2] 
			strb	r2, [r5,#FCCOBLO]
			ldrb	r2, [r4,#3] 
			strb	r2, [r5,#FCCOBHI]

			//FCCOB4
			movs	r2,#4			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldrb	r2, [r4,#4] 
			strb	r2, [r5,#FCCOBLO]
			ldrb	r2, [r4,#5] 
			strb	r2, [r5,#FCCOBHI]

			//FCCOB5
			movs	r2,#5			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldrb	r2, [r4,#6] 
			strb	r2, [r5,#FCCOBLO]
			ldrb	r2, [r4,#7] 
			strb	r2, [r5,#FCCOBHI]

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
# program 1 byte EEPROM
# r3 = address
# r4 = pointer to SRAM 
################################################################################
prog_ebyte:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70
			strb	r2, [r5,#FSTAT]
			
			//FCCOB0
			movs	r2,#0			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldr	r2, =0x0011		// program eeprom
			strh	r2, [r5,#FCCOBHI]

			//FCCOB1
			movs	r2,#1			//PTR
			strb	r2, [r5,#FCCOBIX]
			mov	r2,r3
			strb	r2, [r5,#FCCOBLO]
			lsr	r2,#8
			strb	r2, [r5,#FCCOBHI]

			//FCCOB2
			movs	r2,#2			//PTR
			strb	r2, [r5,#FCCOBIX]
			ldrb	r2, [r4,#0] 
			strb	r2, [r5,#FCCOBLO]
			strb	r2, [r5,#FCCOBHI]

			movs	r2,#0x80
			strb	r2, [r5,#FSTAT]
			movs	r1, #0x80
prog_ebyte_loop:	ldrb	r2, [r5,#FSTAT]
			and	r2, r1
			beq	prog_ebyte_loop
			add	r3,#1
			add	r4,#1
			bx	lr

			
################################################################################
# read out 1K Flash
################################################################################
read_flash:		ldr	r4,=0x20000200		// buffer address
			ldr	r7,=0x100		// LW to do
read_flash_1:		ldr	r2,[r3,#0]
			str	r2,[r4,#0]
			add	r3,#4
			add	r4,#4
			sub	r7,#1
			bne	read_flash_1
			b	main_loop

################################################################################
# read out 256 EEPROM
################################################################################
read_eeprom:		ldr	r4,=0x20000200		// buffer address
			ldr	r3,=0x10000000		// buffer address
			ldr	r7,=0x100		// bytes to do
read_eeprom_1:		ldrb	r2,[r3,#0]
			strb	r2,[r4,#0]
			add	r3,#1
			add	r4,#1
			sub	r7,#1
			bne	read_eeprom_1
			b	main_loop
					