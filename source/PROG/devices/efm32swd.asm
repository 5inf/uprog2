;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public License			#
;# as published by the Free Software Foundation; either version 2		#
;# of the License, or (at your option) any later version.			#
;#										#
;# This program is distributed in the hope that it will be useful,		#
;# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
;# General Public License for more details.					#
;#										#
;# You should have received a copy of the GNU General Public			#
;# License along with this library; if not, write to the			#
;# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
;# Boston, MA 02111-1307, USA.							#
;#										#
;################################################################################
.equ			EFM32_RST		= SIG1
.equ			EFM32_CLOCK		= SIG2
.equ			EFM32_DATA		= SIG3
.equ			EFM32_TRG		= SIG5

.equ			EFM32_ZERO_R		= 0				;none
.equ			EFM32_ONE_R		= SIG3_OR			;data
.equ			EFM32_ZERO		= SIG1_OR			;reset
.equ			EFM32_ONE		= (SIG3_OR + SIG1_OR)		;data + reset
.equ			EFM32_CLK		= SIG2_OR			;only clock


;SW-DP registers
.equ			EFM32_READ_IDCODE	= 0xa5
.equ			EFM32_WRITE_ABORT	= 0x81

.equ			EFM32_READ_CTRL		= 0xb1
.equ			EFM32_WRITE_CTRL	= 0x95

.equ			EFM32_READ_STAT		= 0xb5
.equ			EFM32_WRITE_SELECT	= 0x8d

.equ			EFM32_READ_RDBUFF	= 0xbd		;read buffer


; AHB-AP registers
.equ			EFM32_READ_CSW		= 0xe1
.equ			EFM32_WRITE_CSW		= 0xc5

.equ			EFM32_READ_TAR		= 0xF5
.equ			EFM32_WRITE_TAR		= 0xD1

.equ			EFM32_READ_BASE		= 0xED
.equ			EFM32_WRITE_BASE	= 0xC9

.equ			EFM32_READ_DRW		= 0xf9
.equ			EFM32_WRITE_DRW		= 0xdd

			
;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
efm32_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,EFM32_RST
			sbi		CTRLDDR,EFM32_CLOCK
			sbi		CTRLDDR,EFM32_DATA
			sbi		CTRLDDR,EFM32_TRG

			;we do a connect under reset
			call		api_vcc_on		;power on
;			sbi		CTRLPORT,EFM32_RST	;release reset
			ldi		ZL,100
			ldi		ZH,0
			call		api_wait_ms

efm32_init_1:		sbi		CTRLPORT,EFM32_CLOCK
			sbi		CTRLPORT,EFM32_DATA
			sbi		CTRLPORT,EFM32_RST	;release reset
			ldi		ZL,25
			ldi		ZH,0
			call		api_wait_ms


;			rcall		efm32_wait_1ms
;			sbi		CTRLPORT,EFM32_RST	;release reset
;			rcall		efm32_wait_1ms

			ldi		r16,0x41		;timeout

			rcall		efm32_reginit		;set registers for faster output
			ldi		YL,0
			ldi		YH,1

;			sbi		CTRLPORT,EFM32_TRG	;trigger LA			

			;INIT DP
efm32_idp:		call		swd32_reset		;reset state machine
			ldi		XL,EFM32_READ_IDCODE	;read ID code
			call		swd32_read_dap			
			cpi		XL,0x04			;check ack
			breq		efm32_init_2
			rjmp		efm32_init_err

efm32_init_2:		rcall		efm32_store_val		;store JTAG port ID

;			ldi		XL,150
;			rcall		efm32_wus
			ldi		r16,0x50		;error code

			;set pointer to table
			ldi		ZL,LOW(efm32_data_init1*2)
			ldi		ZH,HIGH(efm32_data_init1*2)


;			sbi		CTRLPORT,EFM32_TRG	;trigger LA			

			;init DP and read ID code
			rcall		efm32_write_dap_table	;clear flags
			rcall		efm32_write_dap_table	;set ctrlstat
			rcall		efm32_write_dap_table	;clear flags
			rcall		efm32_write_dap_table	;set ctrlstat
			call		swd32_read_ctrlstat
			cpi		r23,0xf0		;check for DP is powered
			brne		efm32_init_err
							
			;verify debug lock
;			sbi		CTRLPORT,EFM32_TRG	;trigger LA			
			ldi		r16,0x51		;error code
			rcall		efm32_write_dap_table	;select F0			
			ldi		XL,EFM32_READ_DRW	;dummy read IDR
			rcall		efm32_read_dap						
			ldi		XL,EFM32_READ_RDBUFF	;read buffer
			rcall		efm32_read_dap
			rcall		efm32_store_val		;store AHB-AP ID to buffer
			
			rcall		efm32_write_dap_table	;select 00			

			;init AHB AP
			sbi		CTRLPORT,EFM32_TRG	;trigger LA			
			ldi		r16,0x50		;error code
			rcall		efm32_write_dap_table	;write CSW
efm32_csww1:		rcall		efm32_write_dap_table	;write TAR
			call		swd32_read_drwx
			rcall		efm32_store_val		;store AHB-AP ID to buffer

			;halt target
			sbi		CTRLPORT,EFM32_TRG	;trigger LA			
			ldi		r16,0x50		;error code
			rcall		efm32_write_dap_table	;write CSW
			rcall		efm32_write_dap_table	;write CSW
			rcall		efm32_write_dap_table	;write CSW
			call		swd32_read_drwx


			jmp		main_loop_ok

			;test
			ldi		r24,7
efm32_ptest1:		rcall		efm32_write_dap_table	;write CSW
			dec		r24
			brne		efm32_ptest1		


			jmp		main_loop_ok

efm32_init_err:		sts		0x13F,XL
			jmp		main_loop


efm32_data_init1:	;init DP
			.db EFM32_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db EFM32_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db EFM32_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db EFM32_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			

			;read AP ID
			.db EFM32_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0xF0	;switch to Bank 0xF0			
			.db EFM32_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0x00	;switch to Bank 0x00			

			;init AHB AP
			.db EFM32_WRITE_CSW,	0x00,	0x23,0x00,0x00,0x02	;32 bit access
			.db EFM32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0x00	;DHCSR

			;Halt target
			.db EFM32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db EFM32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x03	;halt core and enable debug
			.db EFM32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;ID

			;test
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x00,0x80,0x64	;CMU_CLEKEN0
			.db EFM32_WRITE_DRW,	0x00,	0x04,0x00,0x00,0x00	;enable GPIO
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0xC0,0x04	;GPIOA_MODEL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x40,0x00	;enable PA3
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0xC0,0x10	;DOUT
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x08	;PA3=1
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x08	;PA3=1
			

;-------------------------------------------------------------------------------
; unlock
;-------------------------------------------------------------------------------
efm32_unlock:		out		CTRLPORT,const_0
			sbi		CTRLDDR,EFM32_RST
			sbi		CTRLDDR,EFM32_CLOCK
			sbi		CTRLDDR,EFM32_DATA
			sbi		CTRLDDR,EFM32_TRG

			;we do a connect under reset
			call		api_vcc_on		;power on
			ldi		ZL,100
			ldi		ZH,0
			call		api_wait_ms
			sts		0x100,const_0
			sts		0x101,const_1

efm32_unlock_1:		sbi		CTRLPORT,EFM32_CLOCK
			sbi		CTRLPORT,EFM32_DATA
			sbi		CTRLPORT,EFM32_RST	;release reset

			ldi		r16,0x41		;timeout

			rcall		efm32_reginit		;set registers for faster output
			ldi		YL,0
			ldi		YH,1

;			sbi		CTRLPORT,EFM32_TRG	;trigger LA			

			;get JTAG ID
			clr		r24
efm32_unlock_1a:	call		swd32_reset		;reset state machine
			ldi		XL,EFM32_READ_IDCODE	;read ID code	
			call		swd32_read_dap			
			cpi		XL,0x04			;check ack
			breq		efm32_unlock_2
			dec		r24
			brne		efm32_unlock_1a
			rjmp		efm32_init_err

efm32_unlock_2:		rcall		efm32_store_val		;store JTAG port ID

			ldi		r16,0x50		;error code

			;set pointer to table
			ldi		ZL,LOW(efm32_data_unlock*2)
			ldi		ZH,HIGH(efm32_data_unlock*2)


;			sbi		CTRLPORT,EFM32_TRG	;trigger LA			

			;init DP and read ID code
		;	rcall		efm32_write_dap_table	;select F0			
		;	ldi		XL,EFM32_READ_DRW	;dummy read IDR
		;	rcall		efm32_read_dap						
		;	ldi		XL,EFM32_READ_RDBUFF	;read buffer
		;	rcall		efm32_read_dap
		;	clr		r23
		;	rcall		efm32_store_val		;store AHB-AP ID to buffer

			ldi		r16,0x51		;error code

			rcall		efm32_write_dap_table	;switch to bank 0
			rcall		efm32_write_dap_table	;AAP_CMDEKEY
			rcall		efm32_write_dap_table	;AAP CMD
	;		rcall		efm32_write_dap_table	;set ctrlstat
	;		rcall		efm32_write_dap_table	;clear flags

			ldi		ZL,0
			ldi		ZH,2
			call		api_wait_ms

			jmp		main_loop_ok

;
efm32_data_unlock:	;unlock
		;	.db EFM32_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0xF0	;switch to Bank 0xF0			

			.db EFM32_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0x00	;switch to Bank 0x00			
			.db EFM32_WRITE_TAR,	0x00,	0xCF,0xAC,0xC1,0x18	;AAP_CMDKEY
			.db EFM32_WRITE_CSW,	0x00,	0x00,0x00,0x00,0x01	;AAP_CMD
			.db EFM32_WRITE_TAR,	0x00,	0x00,0x00,0x00,0x00	;AAP_CMDKEY exit			
			.db EFM32_WRITE_TAR,	0x00,	0x00,0x00,0x00,0x00	;AAP_CMDKEY exit			


;-------------------------------------------------------------------------------
; lock
;-------------------------------------------------------------------------------
efm32_lock:		ldi		ZL,LOW(efm32_data_lock*2)
			ldi		ZH,HIGH(efm32_data_lock*2)
			ldi		r16,0x56

			ldi		r24,9
efm32_lock_1:		rcall		efm32_write_dap_table
			dec		r24
			brne		efm32_lock_1

			ldi		r24,0
			ldi		r25,16			;max. 4s
			
efm32_lock_2:		rcall		efm32_wait_1ms
			call		swd32_read_drwx		;read SR
			andi		r20,0x01
			breq		efm32_lock_3
			sbiw		r24,1
			brne		efm32_lock_2
			ldi		r16,0x58
			jmp		main_loop

efm32_lock_3:		rcall		efm32_write_dap_table
			rcall		efm32_write_dap_table

			cbi		CTRLPORT,EFM32_RST	;hard reset
			ldi		ZL,25
			ldi		ZH,0
			call		api_wait_ms
			sbi		CTRLPORT,EFM32_RST	;release reset
			ldi		ZL,250
			ldi		ZH,0
			call		api_wait_ms


			jmp		main_loop_ok


			
efm32_data_lock:	.db EFM32_WRITE_TAR,	0x00,	0x40,0x00,0x80,0x68	;CMU_CLEKEN0
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x02,0x00,0x00	;enable MSC
	
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;WREN active
		
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x14	;ADDRB		
			.db EFM32_WRITE_DRW,	0x00,	0x0F,0xE0,0x41,0xFC	;DEBUG LOCK WORD
			
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x18	;WDATA
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;lock

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x1C	;STATUS

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;WREN inactive
		



;-------------------------------------------------------------------------------
; main merase
;-------------------------------------------------------------------------------
efm32_merase:		ldi		ZL,LOW(efm32_data_merase*2)
			ldi		ZH,HIGH(efm32_data_merase*2)
			ldi		r16,0x56

			ldi		r24,7
efm32_merase_1:		rcall		efm32_write_dap_table
			dec		r24
			brne		efm32_merase_1

			ldi		r24,0
			ldi		r25,16			;max. 4s
			
efm32_merase_2:		rcall		efm32_wait_1ms
			call		swd32_read_drwx		;read SR
			andi		r20,0x01
			breq		efm32_merase_3
			sbiw		r24,1
			brne		efm32_merase_2
			ldi		r16,0x57
			jmp		main_loop

efm32_merase_3:		rcall		efm32_write_dap_table
			rcall		efm32_write_dap_table

			jmp		main_loop_ok

			
efm32_data_merase:	.db EFM32_WRITE_TAR,	0x00,	0x40,0x00,0x80,0x68	;CMU_CLEKEN0
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x02,0x00,0x00	;enable MSC

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;WREN active
		
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x10	;WRITECMD
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x01,0x00	;merase

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x1C	;STATUS

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;WREN inactive
		

;-------------------------------------------------------------------------------
; erase PAR1-4page  address
;-------------------------------------------------------------------------------
efm32_perase:		ldi		ZL,LOW(efm32_data_perase*2)
			ldi		ZH,HIGH(efm32_data_perase*2)
			ldi		r16,0x56

			ldi		r24,5
efm32_perase_1:		rcall		efm32_write_dap_table
			dec		r24
			brne		efm32_perase_1
			
			movw		r20,r16
			movw		r22,r18
			ldi		XL,EFM32_WRITE_DRW
			call		swd32_write_dap
			
			rcall		efm32_write_dap_table
			rcall		efm32_write_dap_table
			rcall		efm32_write_dap_table
			
			ldi		r24,0
			ldi		r25,16			;max. 4s
			
efm32_perase_2:		rcall		efm32_wait_1ms
			call		swd32_read_drwx		;read SR
			andi		r20,0x01
			breq		efm32_perase_3
			sbiw		r24,1
			brne		efm32_perase_2
			ldi		r16,0x57
			jmp		main_loop

efm32_perase_3:		ldi		ZL,50
			ldi		ZH,0
			call		api_wait_ms
			rcall		efm32_write_dap_table
			rcall		efm32_write_dap_table



			jmp		main_loop_ok

			
efm32_data_perase:	.db EFM32_WRITE_TAR,	0x00,	0x40,0x00,0x80,0x68	;CMU_CLEKEN0
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x02,0x00,0x00	;enable MSC

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;WREN active
		
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x14	;ADDRB		
	
		
			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x10	;WRITECMD
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x02	;page erase

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x1C	;STATUS

			.db EFM32_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x0C	;WRITECTRL
			.db EFM32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;WREN inactive
		
			

;-------------------------------------------------------------------------------
; header
; XL=config in
; XL=ack out
;-------------------------------------------------------------------------------
efm32_head:		ldi		XH,8			;bits to do
efm32_head_1:	;	sbrc		XL,7
			mov		r12,r14			;one
			sbrs		XL,7
			mov		r12,r13			;zero
			
			out		CTRLPORT,r12
			lsl		XL
			dec		XH
			out		CTRLPIN,r15
			brne		efm32_head_1

			cbi		CTRLDDR,EFM32_DATA
			cbi		CTRLPORT,EFM32_CLOCK	;TRN
			nop
			nop
			sbi		CTRLPORT,EFM32_CLOCK

			ldi		XL,5
efm32_shd2:		dec		XL
			brne		efm32_shd2	

		
			;get ack
			clr		XL
			ldi		XH,3
efm32_head_2:		out		CTRLPORT,r14		;ONE (is pull-up)
			lsl		XL
			nop
			sbic		CTRLPIN,EFM32_DATA
			inc		XL
			out		CTRLPIN,r15		;CLOCK
			dec		XH
			brne		efm32_head_2
			ret


;-------------------------------------------------------------------------------
; some wait routines
;-------------------------------------------------------------------------------
efm32_wait_1ms:		push	ZH
			push	ZL
			ldi	ZL,1
			clr	ZH
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret

efm32_wait_1s:		push	ZH
			push	ZL
			ldi	ZL,0
			ldi	ZH,2
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret

efm32_wus:		push	ZH
			dec	XL
efm32_wus_1:		ldi	ZH,6
efm32_wus_2:		dec	ZH
			brne	efm32_wus_2
			dec	XL
			brne	efm32_wus_1
			pop	ZH
			ret		
			


efm32_w0:		ldi	ZL,33
efm32_w0_1:		dec	ZL
			brne	efm32_w0_1
efm32_w0_2:		ret


efm32_wait_5ms:		push	ZL
			push	ZH
			ldi	ZL,20
			ldi	ZH,0
			call	api_wait_ms
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------------------------
; define registers for faster output
;-------------------------------------------------------------------------------
efm32_reginit:		jmp		swd32_reginit

efm32_reginit_reset:	jmp		swd32_reginit_reset


efm32_read_ctrlstat:	ldi		XL,EFM32_READ_CTRL	;read CTRLSTAT
			jmp		swd32_read_dap


efm32_wait_ctrlstat:	movw		r0,XL			;mask ad target
			ldi		r24,0
			ldi		r25,0
efm32_wait_ctrlstat_1:	sbiw		r24,1
			breq		efm32_wait_ctrlstat_e
			ldi		XL,EFM32_READ_CTRL	;read CTRLSTAT
			call		swd32_read_dap		
			and		r23,r0
			cp		r23,r1
			brne		efm32_wait_ctrlstat_1		
efm32_wait_ctrlstat_e:	ret


efm32_store_val:	st		Y+,r20			;return ID
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23
			ret


efm32_write_dap_table:	call		swd32_write_dap_table
		;	call		efm32_add_clk
			cpi		XL,4
			brne		efm32_wdap_err
			ret
			
efm32_wdap_err:		sts		0x13F,XL
			pop 		r0
			pop		r0
			jmp		main_loop

;-------------------------------------------------------------------------------
; add 8 clocks for transaction
;-------------------------------------------------------------------------------
efm32_read_dap:		jmp		swd32_read_dap
						
efm32_add_clk:		push		XL
			ldi		XL,1
			
efm32_add_clk_1:	out		CTRLPORT,r13
			nop
			nop
			nop
			out		CTRLPIN,r15
			dec		XL
			brne		efm32_add_clk_1
			pop		XL
			ret
