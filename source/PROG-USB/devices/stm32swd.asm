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
.equ			SWD32_RST		= SIG1
.equ			SWD32_CLOCK		= SIG2
.equ			SWD32_DATA		= SIG3

.equ			SWD32_ZERO_R		= 0				;none
.equ			SWD32_ONE_R		= SIG3_OR			;data
.equ			SWD32_ZERO		= SIG1_OR			;reset
.equ			SWD32_ONE		= (SIG3_OR + SIG1_OR)		;data + reset
.equ			SWD32_CLK		= SIG2_OR			;only clock


;SW-DP registers
.equ			SWD32_READ_IDCODE	= 0xa5
.equ			SWD32_WRITE_ABORT	= 0x81

.equ			SWD32_READ_CTRL		= 0xb1
.equ			SWD32_WRITE_CTRL	= 0x95

.equ			SWD32_READ_STAT		= 0xb5
.equ			SWD32_WRITE_SELECT	= 0x8d

.equ			SWD32_READ_RDBUFF	= 0xbd		;read buffer


; AHB-AP registers

.equ			SWD32_READ_CSW		= 0xe1
.equ			SWD32_WRITE_CSW		= 0xc5

.equ			SWD32_READ_TAR		= 0xf5
.equ			SWD32_WRITE_TAR		= 0xd1

.equ			SWD32_READ_BASE		= 0xed
.equ			SWD32_READ_IDR		= 0xc9

.equ			SWD32_READ_DRW		= 0xf9
.equ			SWD32_WRITE_DRW		= 0xdd

			
;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
swd32_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,SWD32_RST
			sbi		CTRLDDR,SWD32_CLOCK
			sbi		CTRLDDR,SWD32_DATA

			;we do a connect under reset
			call		api_vcc_on		;power on
			ldi		ZL,200
			ldi		ZH,0
			call		api_wait_ms

swd32_init_1:		cbi		CTRLPORT,SWD32_CLOCK
			cbi		CTRLPORT,SWD32_DATA
			clr		ZL
			rcall		swd32_w0_1

			ldi		r16,0x41		;timeout

			rcall		swd32_reginit_reset	;set registers for faster output
			ldi		YL,0
			ldi		YH,1

			;now get chip id
			ldi		r24,0
			ldi		r25,4			;1024 tries
swd32_init_2:		rcall		swd32_reset		;reset state machine

			ldi		XL,SWD32_READ_IDCODE	;read ID code
			rcall		swd32_read_dap
			
			sts		0x100,XL
			cpi		XL,0x04			;no ack -> exit
			breq		swd32_init_3
			rcall		swd32_wait_1ms		;next try
			sbiw		r24,1
			brne		swd32_init_2
			rjmp		swd32_init_err

swd32_init_3:		st		Y+,r20			;return ID
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23


			ldi		ZL,LOW(swd32_data_init1*2)
			ldi		ZH,HIGH(swd32_data_init1*2)

			rcall		swd32_read_ctrlstat			

			;DebugPortStart
			ldi		r24,5
swd32_init_3a:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_init_3a

			;debug core start
			ldi		r24,3
swd32_init_3b:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_init_3b
		
			;set reset vector catch
			ldi		r24,3
swd32_init_3c:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_init_3c
			
;			rcall		swd32_read_drwx

			sbi		CTRLPORT,SWD32_RST	;release reset

			ldi		ZL,250
			ldi		ZH,0
			call		api_wait_ms

			rcall		swd32_reginit		;set registers for faster output

;			rcall		swd32_ptest		;I/O test

			jmp		main_loop_ok
		
swd32_init_err:		jmp		main_loop

swd32_data_init1:	;DebugPortStart
			.db SWD32_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db SWD32_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0x00	;switch to Bank 0x00			
			.db SWD32_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db SWD32_WRITE_CTRL,	0x00,	0x54,0x00,0x00,0x00	;request debug reset
			.db SWD32_WRITE_CTRL,	0x00,	0x50,0x00,0x0F,0x00	;init AP transfer mode

			;DebugCoreStart
			.db SWD32_WRITE_CSW,	0x00,	0x23,0x00,0x00,0x02	;32 bit access
			.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db SWD32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;halt CPU and enable debug
			
			;set reset vector catch
			.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xFC	;DEMCR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;enable reset vector catch
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;enable reset vector catch		

;-------------------------------------------------------------------------------
; reset and goto idle state
;-------------------------------------------------------------------------------
swd32_reset:		sbi		CTRLPORT,SWD32_DATA
			sbi		CTRLDDR,SWD32_DATA
			;min 50 clocks with TMS high
			ldi		XH,50
swd32_reset_1:		out		CTRLPORT,r14		;one
			dec		XH
			out		CTRLPIN,r15		;clock inactive
			brne		swd32_reset_1

			;switch to SWD mode
			ldi		XH,16
			ldi		ZH,0xE7			;switch code (LSB first)
			ldi		ZL,0x9E
swd32_reset_2:		mov		XL,r14			;one
			sbrs		ZL,0
			mov		XL,r13			;zero
			out		CTRLPORT,XL
			lsr		ZH
			ror		ZL
			out		CTRLPIN,r15		;clock inactive
			dec		XH
			brne		swd32_reset_2

			;min 50 clocks with TMS high
			sbi		CTRLPORT,SWD32_DATA
			ldi		XH,50
swd32_reset_3:		out		CTRLPORT,r14		;one
			dec		XH
			out		CTRLPIN,r15		;clock inactive
			brne		swd32_reset_3
		

			;goto run-test-idle
			cbi		CTRLPORT,SWD32_DATA
			ldi		XH,2
swd32_reset_4:		out		CTRLPORT,r13		;zero
			dec		XH
			out		CTRLPIN,r15		;clock inactive
			brne		swd32_reset_4
			ret

;-------------------------------------------------------------------------------
; write
; P1-P3 = Address
; P4=pages
;-------------------------------------------------------------------------------
swd32_write:		mov		r25,r16			;address l
			mov		r6,r17			;address m
			mov		r7,r18			;address h
			ldi		YL,0
			ldi		YH,1

swd32_write_1:		clr		r24
swd32_write_2:		movw		r20,r24
			movw		r22,r6
			ldi		XL,SWD32_WRITE_TAR
			rcall		swd32_write_dap
			
			ld		r20,Y+
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+

			ldi		XL,SWD32_WRITE_DRW
			rcall		swd32_write_dap
			
			subi		r24,0xfc		;+4
			brne		swd32_write_2

			add		r25,const_1
			adc		r6,const_0
			adc		r7,const_0

			dec		r19
			brne		swd32_write_1
			
			sbiw		YL,4			;set back pointer
			ld		r20,Y+
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+

			ldi		XL,SWD32_WRITE_DRW
			rcall		swd32_write_dap		;write last word again
			
			jmp		main_loop_ok


;-------------------------------------------------------------------------------
; read
; P1-P3 = Address
; P4=pages
;-------------------------------------------------------------------------------
swd32_read:		mov		r25,r16			;address l
			mov		r6,r17			;address m
			mov		r7,r18			;address h
			ldi		YL,0
			ldi		YH,1
			
swd32_read_1:		clr		r24
swd32_read_2:		movw		r20,r24
			movw		r22,r6
			ldi		XL,SWD32_WRITE_TAR
			rcall		swd32_write_dap

			rcall		swd32_read_drwx		;dummy value
			st		Y+,r20
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23
			
			subi		r24,0xfc		;+4
			brne		swd32_read_2
			
			add		r25,const_1
			adc		r6,const_0
			adc		r7,const_0

			dec		r19
			brne		swd32_read_1
			jmp		main_loop_ok

;-------------------------------------------------------------------------------
; go
; P1-P4 = Address
;-------------------------------------------------------------------------------
swd32_go:		ldi		YL,0
			ldi		YH,1

			;write SP/PC	
			rcall		swd32_wsp		;write stack pointer			
			rcall		swd32_wpc		;write pc			
			rcall		swd32_readregs
			
swd32_sgo:		ldi		ZL,LOW(swd32_data_go*2)
			ldi		ZH,HIGH(swd32_data_go*2)
			ldi		r24,3
swd32_go_3:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_go_3

			jmp		main_loop_ok			
			
swd32_data_go:		.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db SWD32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;run CPU (clear halt)
			.db SWD32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x09	;run CPU (clear halt)

;-------------------------------------------------------------------------------
; prepare
; P1-P4 = Address
;-------------------------------------------------------------------------------
swd32_prepare:		ldi		YL,0
			ldi		YH,1

			;write SP/PC	
			rcall		swd32_wsp		;write stack pointer			
			rcall		swd32_wpc		;write pc			
			rcall		swd32_readregs
			
			jmp		main_loop_ok
			
;-------------------------------------------------------------------------------
; unlocking and mass erase
;-------------------------------------------------------------------------------
swd32_exit_debug:	ldi		ZL,LOW(swd32_data_exit*2)
			ldi		ZH,HIGH(swd32_data_exit*2)
			ldi		r24,3
swd32_exit_1:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_exit_1

			cbi		CTRLPORT,SWD32_RST	;set reset

			rcall		swd32_wait_1ms
			
			sbi		CTRLPORT,SWD32_RST	;set reset
			
			jmp		main_loop_ok			


swd32_data_exit:	.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db SWD32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x00	;run CPU (clear halt+debug)
			.db SWD32_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x00	;run CPU (clear halt+debug)
		
;-------------------------------------------------------------------------------
; flash command etc
;-------------------------------------------------------------------------------
swd32_cmd1:		ldi		r20,0x00		;cmd word is at 0x20000000
			ldi		r21,0x00
			ldi		r22,0x00
			ldi		r23,0x20
			rjmp		swd32_cmd_0
			
swd32_cmd:		ldi		r20,0x00		;cmd word is at 0x20000c00
			ldi		r21,0x0c
			ldi		r22,0x00
			ldi		r23,0x20
swd32_cmd_0:		ldi		XL,SWD32_WRITE_TAR
			rcall		swd32_write_dap
			
			movw		r20,r16
			movw		r22,r18
			ldi		XL,SWD32_WRITE_DRW
			rcall		swd32_write_dap

			movw		r20,r16
			movw		r22,r18
			ldi		XL,SWD32_WRITE_DRW
			rcall		swd32_write_dap

swd32_cmd_1:		ldi		ZL,1
			ldi		ZH,0
			call		api_wait_ms

			rcall		swd32_read_drwx		;readout
			or		r21,r20
			or		r22,r20
			or		r23,r20
			brne		swd32_cmd_1		;wait until cmd word is zero
			
			jmp		main_loop_ok

;-------------------------------------------------------------------------------
; write stack pointer value
;-------------------------------------------------------------------------------
swd32_wsp:		adiw		YL,4
			ldi		r25,2
swd32_wsp_1:		ldi		ZL,LOW(swd32_data_wsp*2)
			ldi		ZH,HIGH(swd32_data_wsp*2)
			sbiw		YL,4

			ldi		r24,3
swd32_wsp_2:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_wsp_2

			ld		r20,Y+			;get stored SP value
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+

			ldi		XL,SWD32_WRITE_DRW	;write SP
			rcall		swd32_write_dap

			dec		r25
			brne		swd32_wsp_1
			ret

swd32_data_wsp:		.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF4	;DCRSR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x00,0x0D	;write, r13=SP
			.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF8	;DCRDR

;-------------------------------------------------------------------------------
; write PC value
;-------------------------------------------------------------------------------
swd32_wpc:		adiw		YL,4
			ldi		r25,2
swd32_wpc_1:		ldi		ZL,LOW(swd32_data_wpc*2)
			ldi		ZH,HIGH(swd32_data_wpc*2)
			sbiw		YL,4

			ldi		r24,3
swd32_wpc_2:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_wpc_2

			ld		r20,Y+			;get stored SP value
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+

			ldi		XL,SWD32_WRITE_DRW	;write SP
			rcall		swd32_write_dap

			dec		r25
			
			brne		swd32_wpc_1
			ret

swd32_data_wpc:		.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF4	;DCRSR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x00,0x0F	;write, r15=PC/debug return address
			.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF8	;DCRDR

;-------------------------------------------------------------------------------
; read registers for debug
;-------------------------------------------------------------------------------
swd32_readregs:		ldi		YL,0
			ldi		YH,1
			
			ldi		r24,0
swd32_readregs_1:	ldi		ZL,LOW(swd32_data_rregs*2)
			ldi		ZH,HIGH(swd32_data_rregs*2)
			rcall		swd32_write_dap_table			;DCRSR
			ldi		XL,SWD32_WRITE_DRW
			clr		r23
			clr		r22
			clr		r21
			mov		r20,r24
			rcall		swd32_write_dap			
			
			rcall		swd32_write_dap_table			;DCRDR
			rcall		swd32_read_to_buf			;read data

			inc		r24
			cpi		r24,0x10
			brne		swd32_readregs_1

			sbiw		YL,4

			;now read data at PC
			ld		r20,Y+
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+
			
			andi		r20,0xfc
			push		r20
			push		r21
			push		r22
			push		r23
			ldi		XL,SWD32_WRITE_TAR
			rcall		swd32_write_dap			
			rcall		swd32_read_to_buf			;read data

			pop		r23
			pop		r22
			pop		r21
			pop		r20

			ldi		XL,4
			add		r20,XL
			adc		r21,const_0
			adc		r22,const_0
			adc		r23,const_0
			ldi		XL,SWD32_WRITE_TAR
			rcall		swd32_write_dap			
			rcall		swd32_read_to_buf			;read data
		
			jmp		main_loop_ok
		
swd32_data_rregs:	.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF4	;DCRSR
			.db SWD32_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF8	;DCRDR
				
;-------------------------------------------------------------------------------
; single step for debug
;-------------------------------------------------------------------------------
swd32_step:		ldi		XL,SWD32_WRITE_TAR
			ldi		r23,0xE0
			ldi		r22,0x00
			ldi		r21,0xED
			ldi		r20,0xF0		;step
			rcall		swd32_write_dap
		
			ldi		XL,SWD32_WRITE_DRW
			ldi		r23,0xA0
			ldi		r22,0x5F
			ldi		r21,0x00
			ldi		r20,0x0D		;step
			rcall		swd32_write_dap

swd32_step_wait:	rcall		swd32_read_drwx		;read
			andi		r20,0x02		;halt bit
			breq		swd32_step_wait						
									
			rjmp		swd32_readregs		;done
			

swd32_read_to_buf:	rcall		swd32_read_drwx		;read
swd32_read_to_buf1:	st		Y+,r20
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23
			ret

;-------------------------------------------------------------------------------
; erase STM32 F0/F1/F2/F3/F4
;-------------------------------------------------------------------------------
swd32_erase1:		cpi		r16,1
			breq		swd32_erase2
			cpi		r16,2
			breq		swd32_erase3
			cpi		r16,4
			breq		swd32_erase4
			
			ldi		ZL,LOW(swd32_data_erase1*2)
			ldi		ZH,HIGH(swd32_data_erase1*2)

			ldi		r24,12
swd32_erase1_1:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_erase1_1
			
swd32_erase1_2:		rcall		swd32_read_drwx		;read SR
			andi		r20,0x01
			brne		swd32_erase1_2
			ldi		XL,0x55			
			sts		0x100,XL
			sts		0x101,XL
			sts		0x102,XL
			sts		0x103,XL
			jmp		main_loop_ok

			
swd32_erase2:		ldi		ZL,LOW(swd32_data_erase2*2)
			ldi		ZH,HIGH(swd32_data_erase2*2)

			ldi		r24,14
swd32_erase2_1:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_erase2_1

			
swd32_erase2_2:		ldi		ZL,100
			ldi		ZH,0
			call		api_wait_ms
			rcall		swd32_read_drwx		;read SR
			mov		r16,r22
			andi		r22,0x01
			brne		swd32_erase2_2		
			sts		0x100,r20
			sts		0x101,r21
			sts		0x102,r16
			sts		0x103,r23
			jmp		main_loop_ok

swd32_erase3:		ldi		ZL,LOW(swd32_data_erase3*2)
			ldi		ZH,HIGH(swd32_data_erase3*2)

			ldi		r24,14
			rjmp		swd32_erase2_1


swd32_erase4:		ldi		ZL,LOW(swd32_data_erase4*2)
			ldi		ZH,HIGH(swd32_data_erase4*2)

			ldi		r24,14
			rjmp		swd32_erase2_1


			
swd32_data_erase1:	.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;clear all
		
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0x45,0x67,0x01,0x23	;key 1
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0xCD,0xEF,0x89,0xAB	;key 2
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x04	;MER
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x44	;MER+STRT
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x44	;MER+STRT
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x0C	;SR
			

swd32_data_erase2:	.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;clear all
		
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0x45,0x67,0x01,0x23	;key 1
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0xCD,0xEF,0x89,0xAB	;key 2
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x00	;x32
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x04	;MER, x32
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x02,0x04	;MER+STRT
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x02,0x04	;MER+STRT
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x0C	;SR


swd32_data_erase3:	.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;clear all
		
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0x45,0x67,0x01,0x23	;key 1
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x04	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0xCD,0xEF,0x89,0xAB	;key 2
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x00	;x32
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x82,0x04	;MER/MER1, x32
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x10	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x82,0x04	;MER/MER1+STRT
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x82,0x04	;MER/MER1+STRT
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x3C,0x0C	;SR


swd32_data_erase4:	.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x14	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x00	;clear all
		
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x08	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0x45,0x67,0x01,0x23	;key 1
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x08	;KEYR
			.db SWD32_WRITE_DRW,	0x00,	0xCD,0xEF,0x89,0xAB	;key 2
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x14	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x00	;x32
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x14	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x80,0x04	;MER/MER1
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x14	;CR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x80,0x04	;MER/MER1+STRT
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x01,0x80,0x04	;MER/MER1+STRT
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x20,0x10	;SR

;-------------------------------------------------------------------------------
; header
; XL=config in
; XL=ack out
;-------------------------------------------------------------------------------
swd32_head:		ldi		XH,8			;bits to do
swd32_head_1:		mov		r12,r14			;one
			sbrs		XL,7
			mov		r12,r13			;zero
			
			out		CTRLPORT,r12
			lsl		XL
			dec		XH
			out		CTRLPIN,r15
			brne		swd32_head_1

			cbi		CTRLPORT,SWD32_CLOCK	;TRN
			cbi		CTRLDDR,SWD32_DATA
			sbi		CTRLPORT,SWD32_CLOCK

			ldi		XL,10
shd2:			dec		XL
			brne		shd2	

		
			;get ack
			clr		XL
			ldi		XH,3
swd32_head_2:		out		CTRLPORT,r14		;ONE (is pull-up)
			lsl		XL
			nop
			sbic		CTRLPIN,SWD32_DATA
			inc		XL
			out		CTRLPIN,r15		;CLOCK
			dec		XH
			brne		swd32_head_2
			ret


;-------------------------------------------------------------------------------
; write fixed 32 bit data word (LSB first)
; (Z+0)=config in
; XL=ack out
; (Z+2...Z+3) data in
;-------------------------------------------------------------------------------
swd32_write_dap_table:	lpm		XL,Z+		;CMD
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
swd32_write_dap:	mov		r9,XL
			rcall		swd32_head		;send header

			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			sbi		CTRLDDR,SWD32_DATA
			out		CTRLPIN,r15		;CLOCK

swd32_wd_0:		clr		r4			;parity
			ldi		XH,32			;bits to do
swd32_wd_1:		mov		r12,r14			;one
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
			brne		swd32_wd_1
			;now send parity bit
			mov		r12,r14			;one
			sbrs		r4,0
			mov		r12,r13			;zero
			out		CTRLPORT,r12
			out		CTRLPIN,r15	
			ret

;-------------------------------------------------------------------------------
; read
; XL=config in
; XL=ack out
; r20-r23 data out
;-------------------------------------------------------------------------------
swd32_read_drwx:	ldi		XL,SWD32_READ_DRW
			rcall		swd32_read_dap		;first dummy read
			ldi		XL,SWD32_READ_DRW
			
swd32_read_dap:		mov		r9,XL
			rcall		swd32_head		;send header

			cpi		XL,0x02			;WAIT
			brne		swd32_rd_0
	
			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			sbi		CTRLDDR,SWD32_DATA
			out		CTRLPIN,r15		;CLOCK
	
			mov		XL,r9
			rjmp		swd32_read_dap		;read again 			

swd32_rd_0:		ldi		XH,32
swd32_rd_1:		out		CTRLPORT,r14		;ONE (is pull-up)
			lsr		r23
			ror		r22
			ror		r21
			ror		r20
			sbic		CTRLPIN,SWD32_DATA
			ori		r23,0x80
			out		CTRLPIN,r15		;CLOCK
			dec		XH
			brne		swd32_rd_1

			;ignore parity
			out		CTRLPORT,r14		;ONE (is pull-up)
			nop
			out		CTRLPIN,r15		;CLOCK

			;TrN switch to output
			out		CTRLPORT,r14		;ONE (is pull-up)
			sbi		CTRLDDR,SWD32_DATA
			out		CTRLPIN,r15		;CLOCK
			ret

;-------------------------------------------------------------------------------
; some wait routines
;-------------------------------------------------------------------------------
swd32_wait_1ms:		push	ZH
			push	ZL
			ldi	ZL,1
			clr	ZH
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret

swd32_wait_1s:		push	ZH
			push	ZL
			ldi	ZL,0
			ldi	ZH,2
			call	api_wait_ms
			pop	ZL
			pop	ZH
			ret


swd32_w0:		ldi	ZL,33
swd32_w0_1:		dec	ZL
			brne	swd32_w0_1
swd32_w0_2:		ret


swd32_wait_5ms:		ldi	ZL,5
			ldi	ZH,0
			jmp	api_wait_ms


;-------------------------------------------------------------------------------
; define registers for faster output
;-------------------------------------------------------------------------------
swd32_reginit:		ldi	XL,SWD32_ZERO
			mov	r13,XL
			ldi	XL,SWD32_ONE
			mov	r14,XL
			ldi	XL,SWD32_CLK
			mov	r15,XL
			ret

swd32_reginit_reset:	ldi	XL,SWD32_ZERO_R
			mov	r13,XL
			ldi	XL,SWD32_ONE_R
			mov	r14,XL
			ldi	XL,SWD32_CLK
			mov	r15,XL
			ret


swd32_read_ctrlstat:	ldi		XL,SWD32_READ_CTRL	;read CTRLSTAT
			rjmp		swd32_read_dap


swd32_wait_ctrlstat:	movw		r0,XL			;mask ad target
			ldi		r24,0
			ldi		r25,0
swd32_wait_ctrlstat_1:	sbiw		r24,1
			breq		swd32_wait_ctrlstat_e
			ldi		XL,SWD32_READ_CTRL	;read CTRLSTAT
			rcall		swd32_read_dap		
			and		r23,r0
			cp		r23,r1
			brne		swd32_wait_ctrlstat_1		
swd32_wait_ctrlstat_e:	ret

;-------------------------------------------------------------------------------
; port test
;-------------------------------------------------------------------------------
swd32_ptest:		ldi		ZL,LOW(swd32_data_ptest0*2)
			ldi		ZH,HIGH(swd32_data_ptest0*2)

			ldi		r24,7
swd32_ptest_1:		rcall		swd32_write_dap_table
			dec		r24
			brne		swd32_ptest_1

			rcall		swd32_wait_1s
			rcall		swd32_write_dap_table

			rcall		swd32_wait_1s
			rcall		swd32_write_dap_table

			rcall		swd32_wait_1s
			rcall		swd32_write_dap_table
	
			rcall		swd32_wait_1s

			ret

swd32_data_ptest1:

			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x10,0x18	;APB2ENR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x10	;enable port c

			.db SWD32_WRITE_TAR,	0x00,	0x40,0x01,0x10,0x00	;CRL
			.db SWD32_WRITE_DRW,	0x00,	0x33,0x44,0x44,0x44	;PC6+PC7 output
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x01,0x10,0x0C	;ODR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0xC0	;PC6+PC7 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x80	;PC6+PC7 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x40	;PC6+PC7 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0xC0	;PC6+PC7 output


			.db SWD32_WRITE_TAR,	0x00,	0x20,0x00,0x10,0x00	;mem

swd32_data_ptest0:
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x10,0x14	;AHBENR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x08,0x00,0x14	;enable port c, SRAM,FLIT

			.db SWD32_WRITE_TAR,	0x00,	0x48,0x00,0x08,0x00	;MODER
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x05,0x00,0x00	;PC8+PC9 output
			
			.db SWD32_WRITE_TAR,	0x00,	0x48,0x00,0x08,0x14	;ODR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x03,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x01,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x03,0x00	;PC8+PC9 output


			.db SWD32_WRITE_TAR,	0x00,	0x20,0x00,0x10,0x00	;mem

swd32_data_ptest4:
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x38,0x30	;AHB1ENR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x04	;enable port c

			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x08,0x00	;MODER
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x05,0x00,0x00	;PC8+PC9 output
			
			.db SWD32_WRITE_TAR,	0x00,	0x40,0x02,0x08,0x14	;ODR
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x03,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x01,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x02,0x00	;PC8+PC9 output
			.db SWD32_WRITE_DRW,	0x00,	0x00,0x00,0x03,0x00	;PC8+PC9 output


			.db SWD32_WRITE_TAR,	0x00,	0x20,0x00,0x10,0x00	;mem
