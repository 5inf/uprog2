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
		.equ LED_DEBUG,0

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

.if LED_DEBUG == 1			
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
.endif
			
################################################################################
# the main loop
################################################################################
main_loop:	
.if LED_DEBUG == 1			
			ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x400		// LED 1
			str	r2, [r5,#PDOR]
.endif
			ldr	r1, =0x20000c00		// CMD/ADDR
			mov	r2, #0
			str	r2, [r1,#0]
			
main_loop_wait:		ldrb	r0, [r1,#0]
			cmp	r0,r2
			ldr	r0, [r1,#0]
			beq	main_loop_wait
			mov	r3,r0
			ldr	r2, =0xFFFFFF00
			and	r3,r2			// this is our address
			mov	r2,#0xFF
			and	r0,r2			// this is our cmd

			cmp	r0,#0x52		// prog flash
			beq	prog_flash

			cmp	r0,#0x54		// check flash
			beq	check_flash

			cmp	r0,#0x53		// erase sector
			beq	erase_sector

			cmp	r0,#0x51		// read flash
			beq	read_flash

			cmp	r0,#0x58		// partition data flash
			beq	part_dflash

			cmp	r0,#0x5A		// set flexram function
			beq	set_flexram_x

			cmp	r0,#0x5C		// wait for EE ready
			beq	wait_ee_rdy_x

			cmp	r0,#0x5D		// wait for FLASH ready
			beq	wait_fl_rdy_x

			cmp	r0,#0x5E		// write data to EEPROM (or RAM) 
			beq	write_eep_x
							
			b	main_loop

set_flexram_x:		b	set_flexram
wait_ee_rdy_x:		b	wait_ee_rdy
wait_fl_rdy_x:		b	wait_fl_rdy
write_eep_x:		b	write_eep

################################################################################
# program flash 
################################################################################
prog_flash:
.if LED_DEBUG == 1			
			ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x800		// LED 2
			str	r2, [r5,#PDOR]
.endif
			ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x100		// rows to do
prog_flash_1:		bl	prog_row
			sub	r7,#1
			bne	prog_flash_1
			b	main_loop


################################################################################
# margin check flash 
################################################################################
check_flash:		
.if LED_DEBUG == 1			
			ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x800		// LED 2
			str	r2, [r5,#PDOR]
.endif
			ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x200		// rows to do
check_flash_1:		bl	check_row
			sub	r7,#1
			bne	check_flash_1
			b	main_loop
			
						
################################################################################
# check 4 bytes
# r3 = address
# r4 = pointer to SRAM 
################################################################################
check_row:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70		//clear all flags
			strb	r2, [r5,#FSTAT]
			movs	r2, #0x02
			strb	r2, [r5,#FCCOB0]
			mov	r2,r3			// ADDR LO
			strb	r2, [r5,#FCCOB3]
			lsr	r2,#8			// ADDR MID
			strb	r2, [r5,#FCCOB2]
			lsr	r2,#8			// ADDR HI
			strb	r2, [r5,#FCCOB1]
			movs	r2,#0x02		// use factory levels
			strb	r2, [r5,#FCCOB4]
			ldr	r2, [r4,#0]		// data to check
			str	r2, [r5,#FCCOBB]
			movs	r2,#0x80		//start action
			strb	r2, [r5,#FSTAT]
	
check_row_loop:		ldrb	r2, [r5,#FSTAT]		//wait until done
			movs	r1, #0x80
			and	r1, r2
			beq	check_row_loop
			movs	r1, #0x7F
			and	r1, r2
			b	check_row_err
			add	r3,#4
			add	r4,#4
			bx	lr
			
							
check_row_err:		mov	r6,r3			//get addr
			lsl	r6,#16			//shift
			lsl	r1,#8			//shifted status
			orr	r6,r1

.if LED_DEBUG == 1						
			ldr	r5, =GPIOA_BASE		// port A in GPIO
			ldr	r2, =0x400		// LED 1
			str	r2, [r5,#PDOR]
.endif
			ldr	r1, =0x20000c00		// CMD/ADDR
			str	r6, [r1,#0]
			mov	r2, #0							
			b	main_loop_wait			
			

################################################################################
# erase sector
# r3 = address 
################################################################################
erase_sector:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70		//clear all flags
			strb	r2, [r5,#FSTAT]
			movs	r2, #0x09
			strb	r2, [r5,#FCCOB0]
			mov	r2,r3
			strb	r2, [r5,#FCCOB3]
			lsr	r2,#8
			strb	r2, [r5,#FCCOB2]
			lsr	r2,#8
			strb	r2, [r5,#FCCOB1]
			movs	r2,#0x80		//start action
			strb	r2, [r5,#FSTAT]
			ldrb	r2, [r5,#FSTAT]		//dummy read
		
erase_sector_loop:	ldrb	r2, [r5,#FSTAT]		//wait until done
			movs	r1, #0x80
			and	r1, r2
			bne	erase_sector_loop
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


################################################################################
# partition dflash
# r3 = mode
################################################################################
part_dflash:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70
			strb	r2, [r5,#FSTAT]
			movs	r2, #0x80		//partition code
			strb	r2, [r5,#FCCOB0]
			movs	r2, #0x00		//some zero bytes
			strb	r2, [r5,#FCCOB1]
			strb	r2, [r5,#FCCOB2]
			strb	r2, [r5,#FCCOB6]
			strb	r2, [r5,#FCCOB7]
			mov	r2,r3
			lsr	r2,#8			//flexram load enable
			strb	r2, [r5,#FCCOB3]
			lsr	r2,#8			//EEPROM size
			strb	r2, [r5,#FCCOB4]
			lsr	r2,#8			//Flexnvm partition
			strb	r2, [r5,#FCCOB5]
			movs	r2,#0x80
			strb	r2, [r5,#FSTAT]

part_dflash_loop:	ldrb	r2, [r5,#FSTAT]		//wait until done
			movs	r1, #0x80
			and	r1, r2
			beq	part_dflash_loop
			movs	r1, #0x7F
			and	r1, r2
			bne	part_dflash_err
			b	main_loop
			
							
part_dflash_err:	lsl	r1,#8			//shifted status
			ldr	r6,=0xDDEE0000
			orr	r1,r6
			ldr	r2, =0x20000c00		// CMD/ADDR
			str	r1, [r2,#0]
			mov	r2, #0							
			b	main_loop_wait			
			

################################################################################
# set flexram function
# r3 = 8..15 control, 16..23 FCNFG mask 
################################################################################
set_flexram:		ldr	r5, =FLASH_BASE		
			movs	r2,#0x70
			strb	r2, [r5,#FSTAT]
			movs	r2, #0x81		//function code
			strb	r2, [r5,#FCCOB0]
			lsr	r3,#8			//flexram load enable
			strb	r3, [r5,#FCCOB1]

			movs	r2,#0x80
			strb	r2, [r5,#FSTAT]

set_flexram_noee_l1:	ldrb	r2, [r5,#FSTAT]		//wait until done
			movs	r1, #0x80
			and	r1, r2
			beq	set_flexram_noee_l1
			movs	r1, #0x7F
			and	r1, r2
			bne	part_dflash_err
			lsr	r3,#8

set_flexram_noee_l2:	ldrb	r2, [r5,#FCNFG]		//wait until 
			movs	r1, #0x02		//RAMRDY
			and	r2, r3
			beq	set_flexram_noee_l2
			b	main_loop
			

################################################################################
# wait for EEPROM RDY
################################################################################
wait_ee_rdy:		ldr	r5, =FLASH_BASE		
			ldrb	r2, [r5,#FCNFG]		//wait until 
			movs	r1, #0x01		//EERDY
			and	r2, r1
			beq	wait_ee_rdy
			b	main_loop


################################################################################
# wait for FLASH RDY
################################################################################
wait_fl_rdy:		ldr	r5, =FLASH_BASE		
			ldrb	r2, [r5,#FSTAT]		//wait until 
			movs	r1, #0x80		//CCIF
			and	r2, r1
			beq	wait_fl_rdy
			b	main_loop
			

################################################################################
# write eeprom 
################################################################################
write_eep:		ldr	r4,=0x20000400		// buffer address
			ldr	r7,=0x200		// longs to do
write_eep_1:		ldr	r1,[r4,#0]
			str	r1,[r3,#0]
			add	r3,#4
			add	r4,#4
			sub	r7,#1
			bne	write_eep_1
			b	main_loop
			