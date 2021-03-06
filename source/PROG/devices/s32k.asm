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
.equ			S32K_RST		= SIG1
.equ			S32K_CLOCK		= SIG2
.equ			S32K_DATA		= SIG3
.equ			S32K_TRIGGER		= SIG5

.equ			S32K_ZERO_R		= 0				;none
.equ			S32K_ONE_R		= SIG3_OR			;data
.equ			S32K_ZERO		= SIG1_OR			;reset
.equ			S32K_ONE		= (SIG3_OR + SIG1_OR)		;data + reset
.equ			S32K_CLK		= SIG2_OR			;only clock


;SW-DP registers
.equ			S32K_READ_IDCODE	= 0xa5
.equ			S32K_WRITE_ABORT	= 0x81

.equ			S32K_READ_CTRL		= 0xb1
.equ			S32K_WRITE_CTRL		= 0x95

.equ			S32K_READ_SELECT	= 0xa9
.equ			S32K_WRITE_SELECT	= 0x8d

.equ			S32K_READ_RDBUFF	= 0xbd		;read buffer
.equ			S32K_WRITE_RDBUFF	= 0x99


; AHB-AP registers
.equ			S32K_READ_CSW		= 0xe1		;00
.equ			S32K_WRITE_CSW		= 0xc5

.equ			S32K_READ_TAR		= 0xf5		;04
.equ			S32K_WRITE_TAR		= 0xd1

.equ			S32K_READ_IDR		= 0xed		;08
.equ			S32K_WRITE_IDR		= 0xc9

.equ			S32K_READ_DRW		= 0xf9		;0C
.equ			S32K_WRITE_DRW		= 0xdd

			
;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
s32k_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,S32K_RST
			sbi		CTRLDDR,S32K_CLOCK
			sbi		CTRLDDR,S32K_DATA
			sbi		CTRLDDR,S32K_TRIGGER

			;we do a connect under reset
			call		api_vcc_on		;power on
			ldi		ZL,100
			ldi		ZH,0
			call		api_wait_ms

s32k_init_1:		cbi		CTRLPORT,S32K_CLOCK
			cbi		CTRLPORT,S32K_DATA
			clr		ZL
			rcall		s32k_w0_1

			ldi		r16,0x41		;timeout

			rcall		s32k_reginit_reset	;set registers for faster output
			ldi		YL,0
			ldi		YH,1

			;now get chip id
			ldi		r24,0
			ldi		r25,4			;1024 tries
s32k_init_2:		rcall		swd32_reset		;reset state machine

			ldi		XL,S32K_READ_IDCODE	;read ID code
			rcall		s32k_read_dap
			
			sts		0x100,XL
			cpi		XL,0x04			;no ack -> exit
			breq		s32k_init_3
			rcall		s32k_wait_1ms		;next try
			sbiw		r24,1
			brne		s32k_init_2
			rjmp		s32k_init_err

s32k_init_3:		st		Y+,r20			;return ID
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23

			cpi		r19,0x55
			breq		s32k_init_end

			ldi		ZL,LOW(s32k_data_init1*2)
			ldi		ZH,HIGH(s32k_data_init1*2)

			rcall		s32k_read_ctrlstat			

			;DebugPortStart
			ldi		r24,5
s32k_init_3a:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_init_3a

			;debug core start
			ldi		r24,3
s32k_init_3b:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_init_3b
		
			;set reset vector catch
			ldi		r24,3
s32k_init_3c:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_init_3c
			
;			rcall		s32k_read_drwx
			sbi		CTRLPORT,S32K_RST	;release reset

			ldi		ZL,50
			ldi		ZH,0
;			call		api_wait_ms

			rcall		s32k_reginit		;set registers for faster output

s32k_init_end:		jmp		main_loop_ok
		
s32k_init_err:		ldi		r16,0x41
			out		CTRLDDR,const_0
			out		CTRLPORT,const_0
			jmp		main_loop

s32k_data_init1:	;DebugPortStart
			.db S32K_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db S32K_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0x00	;switch to Bank 0x00			
			.db S32K_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db S32K_WRITE_CTRL,	0x00,	0x54,0x00,0x00,0x00	;request debug reset
			.db S32K_WRITE_CTRL,	0x00,	0x50,0x00,0x0F,0x00	;init AP transfer mode

			;DebugCoreStart
			.db S32K_WRITE_CSW,	0x00,	0x23,0x00,0x00,0x02	;32 bit access
			.db S32K_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db S32K_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;halt CPU and enable debug
			
			;set reset vector catch
			.db S32K_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xFC	;DEMCR
			.db S32K_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;enable reset vector catch
			.db S32K_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;enable reset vector catch		


;-------------------------------------------------------------------------------
; read device ID
;-------------------------------------------------------------------------------
s32k_readid:		ldi		YL,0
			ldi		YH,1
			movw		r20,r16
			movw		r22,r18			
;			ldi		r20,0x24
;			ldi		r21,0x80
;			ldi		r22,0x04
;			ldi		r23,0x40
			ldi		XL,S32K_WRITE_TAR
			rcall		s32k_write_dap

			rcall		s32k_read_drwx		;dummy value
			st		Y+,r20
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23
			
			jmp		main_loop_ok

;-------------------------------------------------------------------------------
; go
; P1-P4 = Address
;-------------------------------------------------------------------------------
s32k_go:		ldi		YL,0
			ldi		YH,1

			;write SP/PC	
			rcall		swd32_wsp		;write stack pointer			
			rcall		swd32_wpc		;write pc			
			rcall		swd32_readregs
			
s32k_sgo:		ldi		ZL,LOW(s32k_data_go*2)
			ldi		ZH,HIGH(s32k_data_go*2)
			ldi		r24,3
s32k_go_3:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_go_3

			jmp		main_loop_ok			
			
s32k_data_go:		.db S32K_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db S32K_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;run CPU (clear halt)
			.db S32K_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;run CPU (clear halt)

;-------------------------------------------------------------------------------
; prepare
; P1-P4 = Address
;-------------------------------------------------------------------------------
s32k_prepare:		ldi		YL,0
			ldi		YH,1

			;write SP/PC	
			rcall		swd32_wsp		;write stack pointer			
			rcall		swd32_wpc		;write pc			
			rcall		swd32_readregs
			
			jmp		main_loop_ok
			
;-------------------------------------------------------------------------------
; exit debug mode
;-------------------------------------------------------------------------------
s32k_exit_debug:	ldi		ZL,LOW(s32k_data_exit*2)
			ldi		ZH,HIGH(s32k_data_exit*2)
			ldi		r24,3
s32k_exit_1:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_exit_1

			cbi		CTRLPORT,S32K_RST	;set reset

			rcall		s32k_wait_1ms
			
			sbi		CTRLPORT,S32K_RST	;set reset
			
			jmp		main_loop_ok			


s32k_data_exit:		.db S32K_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db S32K_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x00	;run CPU (clear halt+debug)
			.db S32K_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x00	;run CPU (clear halt+debug)

;-------------------------------------------------------------------------------
; erase
;-------------------------------------------------------------------------------
s32k_erase2:		ldi		ZL,LOW(s32k_data_erase2*2)
			ldi		ZH,HIGH(s32k_data_erase2*2)
			ldi		r24,6

s32k_erase2_1:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_erase2_1
			ldi		r24,100

s32k_erase2_2:		ldi		ZL,10
			ldi		ZH,0
			call		api_wait_ms
			dec		r24
			breq		s32k_erase2_3
;			rjmp		s32k_erase2_2
			
			rcall		s32k_read_drwx		;dummy value
			mov		r16,r20
			andi		r20,0x80
			brne		s32k_erase2_2
;			andi		r16,0x7f
			mov		r16,r24
			jmp		main_loop
		
s32k_erase2_3:		ldi		r16,0x42			;erase timeout
			jmp		main_loop
			
s32k_data_erase2:	.db S32K_WRITE_TAR,	0x00,	0x40,0x02,0x00,0x00	;FSTAT			
			.db S32K_WRITE_DRW,	0x00,	0x70,0x00,0x00,0x80	;clear flags
			.db S32K_WRITE_TAR,	0x00,	0x40,0x02,0x00,0x04	;FCCOB			
			.db S32K_WRITE_DRW,	0x00,	0x0B,0x00,0x00,0x00	;start erase (was: 49)
			.db S32K_WRITE_TAR,	0x00,	0x40,0x02,0x00,0x00	;FSTAT			
			.db S32K_WRITE_DRW,	0x00,	0x80,0x00,0x00,0x80	;start erase

;-------------------------------------------------------------------------------
; erase
;-------------------------------------------------------------------------------
s32k_erase:		ldi		ZL,LOW(s32k_data_erase*2)
			ldi		ZH,HIGH(s32k_data_erase*2)
			ldi		r24,5
s32k_erase_0:		rcall		s32k_write_dap_table
			dec		r24
			brne		s32k_erase_0

			sbi		CTRLPORT,S32K_TRIGGER		

			ldi		r24,20
s32k_erase_2:		ldi		ZL,20
			ldi		ZH,1
			call		api_wait_ms
		
s32k_erase_3:		ldi		XL,S32K_READ_TAR
			rcall		s32k_read_dap		;status register
			ldi		XL,S32K_READ_TAR
			rcall		s32k_read_dap		;control register
			andi		r20,0x01
			breq		s32k_erase_4
			dec		r24
			brne		s32k_erase_2
s32_erase_timeout:	ldi		r16,0x42			;erase timeout
			sts		0x100,r24
			jmp		main_loop

s32_erase_err:		ldi		r16,0x43			;erase timeout
			sts		0x100,r24
			jmp		main_loop

			
s32k_erase_4:		sts		0x100,r24
			jmp		main_loop_ok

s32k_data_erase:	.db S32K_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db S32K_WRITE_SELECT,	0x00,	0x01,0x00,0x00,0x00	;switch to MDM-AP
			.db S32K_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db S32K_WRITE_CTRL,	0x00,	0x54,0x00,0x00,0x00	;request debug reset
			.db S32K_WRITE_TAR,	0x00,	0x00,0x00,0x00,0x01	;initiate erase			


;-------------------------------------------------------------------------------
; erase S9KEA
;-------------------------------------------------------------------------------
s9kea_erase:		ldi		ZL,LOW(s9kea_data_erase*2)
			ldi		ZH,HIGH(s9kea_data_erase*2)
			ldi		r24,3
s9kea_erase_0:		rcall		s32k_write_dap_table
			dec		r24
			brne		s9kea_erase_0

			rcall		s32k_read_drwx			;read IDR and check for 0x1C0020
			cpi		r20,0x20
			brne		s32_erase_err
			cpi		r21,0x00
			brne		s32_erase_err
			cpi		r22,0x1c
			brne		s32_erase_err

			sbi		CTRLPORT,S32K_TRIGGER		
			rcall		s32k_write_dap_table		;switch to MDM CTRL/STAT DAP
			rcall		s32k_write_dap_table

			rcall		s32k_reginit			;RESET HIGH

			rcall		s32k_w20ms

			ldi		r24,20
s9kea_erase_1:		ldi		XL,S32K_READ_CSW
			rcall		s32k_read_dap		;status register
			ldi		XL,S32K_READ_CSW
			rcall		s32k_read_dap		;status register
			andi		r20,0x02
			brne		s9kea_erase_1e
			rcall		s32k_w20ms
			dec		r24
			brne		s9kea_erase_1
			rjmp		s32_erase_err	

s9kea_erase_1e:		rcall		s32k_write_dap_table

			ldi		r24,20
s9kea_erase_2:		rcall		s32k_w20ms
		
s9kea_erase_3:		ldi		XL,S32K_READ_TAR
			rcall		s32k_read_dap		;status register
			ldi		XL,S32K_READ_TAR
			rcall		s32k_read_dap		;control register
			andi		r20,0x01
			breq		s32k_erase_4
			dec		r24
			brne		s9kea_erase_2
s9kea_erase_timeout:	ldi		r16,0x42			;erase timeout
			sts		0x100,r24
			jmp		main_loop

s9kea_erase_err:	ldi		r16,0x43			;erase timeout
			sts		0x100,r24
			jmp		main_loop

s9kea_erase_4:		sts		0x100,r24
			jmp		main_loop_ok


s9kea_data_erase:	.db S32K_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db S32K_WRITE_SELECT,	0x00,	0x01,0x00,0x00,0xF0	;switch to MDM-AP
			.db S32K_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
;			.db S32K_WRITE_CTRL,	0x00,	0x55,0x00,0x00,0x00	;request debug reset
		
			.db S32K_WRITE_SELECT,	0x00,	0x01,0x00,0x00,0x00	;switch to MDM-AP
			.db S32K_WRITE_TAR,	0x00,	0x00,0x00,0x00,0x08	;initiate erase			
			.db S32K_WRITE_TAR,	0x00,	0x00,0x00,0x00,0x01	;initiate erase			



;-------------------------------------------------------------------------------
; header
; XL=config in
; XL=ack out
;-------------------------------------------------------------------------------
s32k_head:		ldi		XH,8			;bits to do
s32k_head_1:		mov		r12,r14			;one
			sbrs		XL,7
			mov		r12,r13			;zero
			
			out		CTRLPORT,r12
			lsl		XL
			dec		XH
			out		CTRLPIN,r15
			brne		s32k_head_1

			cbi		CTRLPORT,S32K_CLOCK	;TRN
			cbi		CTRLDDR,S32K_DATA
			sbi		CTRLPORT,S32K_CLOCK

			ldi		XL,10
xshd2:			dec		XL
			brne		xshd2	

		
			;get ack
			clr		XL
			ldi		XH,3
s32k_head_2:		out		CTRLPORT,r14		;ONE (is pull-up)
			lsl		XL
			nop
			sbic		CTRLPIN,S32K_DATA
			inc		XL
			out		CTRLPIN,r15		;CLOCK
			dec		XH
			brne		s32k_head_2
			ret


;-------------------------------------------------------------------------------
; write fixed 32 bit data word (LSB first)
; (Z+0)=config in
; XL=ack out
; (Z+2...Z+3) data in
;-------------------------------------------------------------------------------
s32k_write_dap_table:	lpm		XL,Z+		;CMD
			adiw		ZL,1		;skip additional byte
			lpm		r23,Z+		;data
			lpm		r22,Z+
			lpm		r21,Z+
			lpm		r20,Z+

;-------------------------------------------------------------------------------
; write 32 bit data word (LSB first)
; XL=config in
; XL=ack out
; r20-r23 data in
;-------------------------------------------------------------------------------
s32k_write_dap:		mov		r9,XL
			rcall		s32k_head		;send header

			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			sbi		CTRLDDR,S32K_DATA
			out		CTRLPIN,r15		;CLOCK

s32k_wd_0:		clr		r4			;parity
			ldi		XH,32			;bits to do
s32k_wd_1:		mov		r12,r14			;one
			sbrs		r20,0
			mov		r12,r13			;zero
			out		CTRLPORT,r12
			lsr		r23
			ror		r22
			ror		r21
			ror		r20
			out		CTRLPIN,r15	
			adc		r4,const_0
			dec		XH
			brne		s32k_wd_1
			;now send parity bit
			mov		r12,r14			;one
			sbrs		r4,0
			mov		r12,r13			;zero
			out		CTRLPORT,r12
			rcall		s32k_wd_2
			out		CTRLPIN,r15	
s32k_wd_2:		ret

;-------------------------------------------------------------------------------
; read
; XL=config in
; XL=ack out
; r20-r23 data out
;-------------------------------------------------------------------------------
s32k_read_drwx:		ldi		XL,S32K_READ_DRW
			rcall		s32k_read_dap		;first dummy read
s32k_read_drwx1:	ldi		XL,S32K_READ_DRW
			
s32k_read_dap:		mov		r9,XL
			rcall		s32k_head		;send header

			cpi		XL,0x02			;WAIT
			brne		s32k_rd_0
	
			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			sbi		CTRLDDR,S32K_DATA
			out		CTRLPIN,r15		;CLOCK
	
			mov		XL,r9
			rjmp		s32k_read_dap		;read again 			

s32k_rd_0:		ldi		XH,32
s32k_rd_1:		out		CTRLPORT,r14		;ONE (is pull-up)
			lsr		r23
			ror		r22
			ror		r21
			ror		r20
			sbic		CTRLPIN,S32K_DATA
			ori		r23,0x80
			out		CTRLPIN,r15		;CLOCK
			dec		XH
			brne		s32k_rd_1

			;ignore parity
			out		CTRLPORT,r14		;ONE (is pull-up)
			nop
			nop
			nop
			nop
			out		CTRLPIN,r15		;CLOCK
			nop
			nop
			nop
			nop

			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			nop
			nop
			nop
			nop
			sbi		CTRLPORT,S32K_DATA
			sbi		CTRLDDR,S32K_DATA
			out		CTRLPIN,r15		;CLOCK
			ret

;-------------------------------------------------------------------------------
; some wait routines
;-------------------------------------------------------------------------------
s32k_wait_1ms:		push	ZH
			push	ZL
			ldi	ZL,1
			clr	ZH
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret

s32k_wait_1s:		push	ZH
			push	ZL
			ldi	ZL,0
			ldi	ZH,4
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret


s32k_w0:		ldi	ZL,33
s32k_w0_1:		dec	ZL
			brne	s32k_w0_1
s32k_w0_2:		ret


s32k_wait_5ms:		ldi	ZL,5
			ldi	ZH,0
			jmp	api_wait_ms

;-------------------------------------------------------------------------------
; define registers for faster output
;-------------------------------------------------------------------------------
s32k_reginit:		ldi	XL,S32K_ZERO
			mov	r13,XL
			ldi	XL,S32K_ONE
			mov	r14,XL
			ldi	XL,S32K_CLK
			mov	r15,XL
			ret

s32k_reginit_reset:	ldi	XL,S32K_ZERO_R
			mov	r13,XL
			ldi	XL,S32K_ONE_R
			mov	r14,XL
			ldi	XL,S32K_CLK
			mov	r15,XL
			ret


s32k_read_ctrlstat:	ldi		XL,S32K_READ_CTRL	;read CTRLSTAT
			rjmp		s32k_read_dap


s32k_wait_ctrlstat:	movw		r0,XL			;mask ad target
			ldi		r24,0
			ldi		r25,0
s32k_wait_ctrlstat_1:	sbiw		r24,1
			breq		s32k_wait_ctrlstat_e
			ldi		XL,S32K_READ_CTRL	;read CTRLSTAT
			rcall		s32k_read_dap		
			and		r23,r0
			cp		r23,r1
			brne		s32k_wait_ctrlstat_1		
s32k_wait_ctrlstat_e:	ret


s32k_w20ms:		push		ZL
			push		ZH
			ldi		ZL,20
			ldi		ZH,0
			call		api_wait_ms
			pop		ZH
			pop		ZL
			ret
			

