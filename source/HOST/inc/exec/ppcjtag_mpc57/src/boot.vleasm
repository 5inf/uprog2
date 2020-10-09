#################################################################################
#										#
# SPC560P-Bootcode for uprog2 (JTAG mode)					#
# version 1.00									#
#										#
# copyright (c) 2016-2017 Joerg Wolfram (joerg@jcwolfram.de)			#
#										#
# This program is free software; you can redistribute it and/or			#
# modify it under the terms of the GNU General Public License			#
# as published by the Free Software Foundation; either version 2		#
# of the License, or (at your option) any later version.			#
#										#
# This program is distributed in the hope that it will be useful,		#
# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
# General Public License for more details.					#
#										#
# You should have received a copy of the GNU General Public			#
# License along with this library; if not, write to the				#
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
# Boston, MA 02111-1307, USA.							#
#										#
#################################################################################

			.section ".text","ax"

			.include "/usr/local/toolchain/powerpc-vle-elf/include_asm/regs_mpc574x.asm"


			.equ	block_size,2048


			.globl _start

################################################################################

_start:
			.text
			.org 0x0100
	
			
main_start:		#remove watchdog softlock
			e_lis		r24,SWT_BASE
			e_li		r25,SWT_SR		# service register
			se_or		r25,r24
			e_li		r28,0xc520		# passwd 1
			e_stw		r28,0(r25)
			e_li		r28,0xd928		# passwd2
			e_stw		r28,0(r25)

			#watchdog off
			e_li		r25,SWT_CR
			se_or		r25,r24
			e_lwz		r28,0(r25)
			e_clrrwi	r28,r28,1		# clear bit 0
			e_stw		r28,0(r25)


################################################################################
# set mode
################################################################################
			e_lis		r24,ME_BASE
			e_li		r25,0x8000
			se_or		r24,r25
			e_li		r25,ME_RUN_PC0
			se_or		r25,r24
			e_li		r28,0xfe
			e_stw		r28,0(r25)

			e_li		r25,ME_MCTL
			se_or		r25,r24
			e_lis		r29,0x3000		#DRUN
			e_li		r28,0x5af0
			se_or		r28,r29
			se_stw		r28,0(r25)
			e_li		r28,0xa50f
			se_or		r28,r29
			se_stw		r28,0(r25)


################################################################################
# fillup RAM for ECC init
################################################################################
			e_lis		r28,0x4000		#start addr
			e_li		r29,0x0800
			se_or		r28,r29
			e_li		r30,0x00
			e_li		r31,0x00
			e_li		r27,0x00
rfill_1:		e_stmw		r30,0(r28)
			e_add16i	r28,r28,8
			e_add16i	r27,r27,1
			e_cmp16i	r27,0x1000
			se_bne		rfill_1

			e_lis		rsp,0x4000		#set stack pointer
			e_or2i		rsp,0x2000


################################################################################
# unlock memory
################################################################################
			e_lis		r29,FLASH_BASE		#
			e_lis		r30,0x0000		# was 0x8000
			e_stw		r30,FLASH_LOCK0(r29)
			e_stw		r30,FLASH_LOCK1(r29)
			e_stw		r30,FLASH_LOCK2(r29)
			e_stw		r30,FLASH_LOCK3(r29)

################################################################################
# the main loop
################################################################################
main_xloop:
			e_li		r25,0x0000
			e_lis		r24,0x4000
			e_stw		r25,0x04F8(r24)		#store 0
wait_cmd_1:		e_lwz		r25,0x04F8(r24)		#get data	
			e_cmp16i	r25,0x0000
			se_beq		wait_cmd_1		#loop if no cmd


################################################################################
# 0x0D = program code/data
################################################################################
program:		e_cmp16i	r25,0x0D		# program main flash code
			se_bne		main_erase
			e_b		do_prog

################################################################################
# 0x15 = erase
################################################################################
main_erase:		e_cmp16i	r25,0x15		# erase?
			se_bne		data_erase

erase_main:		e_li		r31,0x0004
			se_stw		r31,FLASH_MCR(r29)

			e_lis		r31,0xFFFC		#low select
			e_or2i		r31,0xFFFC
			e_stw		r31,FLASH_SEL0(r29)
			e_li		r31,0x0000		#all select
			se_subi		r31,1			
			e_stw		r31,FLASH_SEL1(r29)
			e_stw		r31,FLASH_SEL2(r29)
			e_stw		r31,FLASH_SEL3(r29)
			e_lis		r31,0x00FA		#addr
			se_stw		r31,0(r31)
			e_li		r31,0x0005
			se_stw		r31,FLASH_MCR(r29)
prog_emf_loop:		se_lwz		r31,FLASH_MCR(r29)
			e_and2i.	r31,0x400
			se_beq		prog_emf_loop
			e_li		r31,0x0004
			se_stw		r31,FLASH_MCR(r29)
			e_li		r31,0x0000
			se_stw		r31,FLASH_MCR(r29)
			e_b		main_xloop


################################################################################
# 0x17 = erase data
################################################################################
data_erase:		e_cmp16i	r25,0x17		# data erase
			se_bne		utest_dword

erase_data:		e_li		r31,0x0004
			se_stw		r31,FLASH_MCR(r29)

			e_lis		r31,0x0003		#all select
			se_addi		r31,3
			e_stw		r31,FLASH_SEL0(r29)
			e_li		r31,0x0000		#all select
			e_stw		r31,FLASH_SEL1(r29)
			e_stw		r31,FLASH_SEL2(r29)
			e_stw		r31,FLASH_SEL3(r29)
			e_lis		r31,0x0080		#format addr
			se_stw		r31,0(r31)
			e_li		r31,0x0005
			se_stw		r31,FLASH_MCR(r29)
prog_edf_loop:		se_lwz		r31,FLASH_MCR(r29)
			e_and2i.	r31,0x400
			se_beq		prog_edf_loop
			e_li		r31,0x0004
			se_stw		r31,FLASH_MCR(r29)
			e_li		r31,0x0000
			se_stw		r31,FLASH_MCR(r29)
			e_b		main_xloop

################################################################################
# 0x1C = program utest dword
##############################################################################
utest_dword:		e_cmp16i	r25,0x1C		# utest program
			se_bne		nocmd

			e_lwz		r5,0x4FC(r24)		# get addr

			e_lis		r27,0x4000		# RAM buffer pointer
			e_or2i		r27,0x1000
			
			se_lwz		r6,0(r27)
			se_lwz		r7,4(r27)
			
			e_bl		prog_dw

nocmd:			e_b		main_xloop
			



################################################################################
# debug LEDs
################################################################################
.if DEBUG_LED == 1
led_green:
			se_li		r28,0x01
			e_stb		r28,GPDO32+1(r26)
			se_li		r28,0x00
			e_stb		r28,GPDO32+2(r26)
			se_blr

led_red:
			se_li		r28,0x00
			e_stb		r28,GPDO32+1(r26)
			se_li		r28,0x01
			e_stb		r28,GPDO32+2(r26)
			se_blr

led_both:
			se_li		r28,0x01
			e_stb		r28,GPDO32+1(r26)
			e_stb		r28,GPDO32+2(r26)
			se_blr

led_none:
			se_li		r28,0x00
			e_stb		r28,GPDO32+1(r26)
			e_stb		r28,GPDO32+2(r26)
			se_blr

.endif

################################################################################
# double word program
# r29	FLASH-BASE
# r5	ADDR
# r6	LOWER WORD
# r7	HIGHER WORD
################################################################################
prog_dw:		e_li		r31,0x0010
			se_stw		r31,FLASH_MCR(r29)
			se_stw		r6,0(r5)
			se_stw		r7,4(r5)
			e_li		r31,0x0011
			se_stw		r31,FLASH_MCR(r29)
prog_dw_loop:		se_lwz		r31,FLASH_MCR(r29)
			e_and2i.	r31,0x400
			se_beq		prog_dw_loop
			e_li		r31,0x0010
			se_stw		r31,FLASH_MCR(r29)
			e_li		r31,0x0000
			se_stw		r31,FLASH_MCR(r29)
			se_blr



			
################################################################################
# program routine
################################################################################
do_prog:		e_lwz		r6,0x4FC(r24)		# get addr

			se_li		r5,0			# counter
			e_lis		r27,0x4000		# RAM buffer pointer
			e_or2i		r27,0x1000

			#now prog
			se_li		r7,0x10			#set PGM
			se_stw		r7,FLASH_MCR(r29)

do_prog_2:		se_lwz		r30,0(r27)		# get from buffer
			se_stw		r30,0(r6)		# store
			se_lwz		r30,4(r27)		# get from buffer
			se_stw		r30,4(r6)		# store
			se_lwz		r30,8(r27)		# get from buffer
			se_stw		r30,8(r6)		# store
			se_lwz		r30,12(r27)		# get from buffer
			se_stw		r30,12(r6)		# store
			se_lwz		r30,16(r27)		# get from buffer
			se_stw		r30,16(r6)		# store
			se_lwz		r30,20(r27)		# get from buffer
			se_stw		r30,20(r6)		# store
			se_lwz		r30,24(r27)		# get from buffer
			se_stw		r30,24(r6)		# store
			se_lwz		r30,28(r27)		# get from buffer
			se_stw		r30,28(r6)		# store

			se_li		r7,0x11			# set PGM + EHV
			se_stw		r7,FLASH_MCR(r29)

wait_done_p:		se_lwz		r7,FLASH_MCR(r29)	# get mcr
			e_and2i.	r7,0x400
			se_beq		wait_done_p

			se_li		r7,0x10			# clear EHV
			se_stw		r7,FLASH_MCR(r29)

			se_addi		r27,32			# increment src addr
			se_addi		r6,32			# increment dst addr

			se_addi		r5,32			# counter
			e_cmp16i	r5,block_size
			se_blt		do_prog_2

			se_li		r27,0x00		#clear PGM
			se_stw		r27,FLASH_MCR(r29)
			
			e_stw		r6,0x4FC(r24)		# get addr

			e_b		main_xloop

