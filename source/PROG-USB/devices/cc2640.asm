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
.equ		JCC_TMS	= SIG1
.equ		JCC_TCK	= SIG2
.equ		JCC_TDI	= SIG3
.equ		JCC_TDO	= SIG4
.equ		JCC_TRIG	= SIG5
.equ		JCC_RESET	= SIG6

.equ		JCC_buffer	= 0x0a00


.macro		JCC_CLOCK	
		sbi	CTRLPORT,JCC_TCK	;2
		nop
		cbi	CTRLPORT,JCC_TCK	;2
.endmacro

.macro		JCC_CLOCK2
		ldi	XH,2	
		rcall	jcc_nclock
.endmacro

.macro		JCC_CLOCK4
		ldi	XH,4	
		rcall	jcc_nclock
.endmacro

.macro		JCC_CLOCK5
		ldi	XH,5	
		rcall	jcc_nclock
.endmacro

.macro		JCC_CLOCK6
		ldi	XH,6	
		rcall	jcc_nclock
.endmacro


.macro		JCC_CLOCK7
		ldi	XH,7	
		rcall	jcc_nclock
.endmacro


.macro		JCC_CLOCK8
		ldi	XH,8	
		rcall	jcc_nclock
.endmacro


;-------------------------------------------------------------------------------
; init jtag and read device ID
;-------------------------------------------------------------------------------
cc2640_init:		ldi	YL,0
			ldi	YH,1
			out	CTRLPORT,const_0
			sbi	CTRLDDR,JCC_TMS
			sbi	CTRLDDR,JCC_TCK
			sbi	CTRLDDR,JCC_TDI
			sbi	CTRLDDR,JCC_TRIG
			cbi	CTRLDDR,JCC_TDO
			sbi	CTRLDDR,JCC_RESET	;set reset LO
			call	api_vcc_on
JCC_init_0:		ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,JCC_TMS
			sbi	CTRLPORT,JCC_RESET	;set reset HI

			ldi	r24,0
			ldi	r25,10
JCC_init_1:		JCC_CLOCK
			sbiw	r24,1
			brne	JCC_init_1
			cbi	CTRLPORT,JCC_TMS	;->run-test-idle
			ldi	r24,16
			ldi	r25,0
JCC_init_2:		JCC_CLOCK
			sbiw	r24,1
			brne	JCC_init_2

			rcall	cc2640_spause
			
			;bypass
			ldi	r16,0x3F
			ldi	r24,6
			set
			call	jppc_shift

			ldi	ZL,LOW(cc2640_inittab*2)
			ldi	ZH,HIGH(cc2640_inittab*2)
			ldi	r24,17
JCC_init_3:		lpm	XH,Z+
			lpm	XL,Z+
			rcall	cjtag_nshift
			dec	r24
			brne	JCC_init_3
			rcall	cc2640_spause

			sbi	CTRLPORT,JCC_TRIG
		
			;bypass
			ldi	r16,0x3F
			ldi	r24,6
			set
			call	jppc_shift

			;load idcode
			ldi	r16,0x04
			ldi	r24,6
			set
			call	jppc_shift
	
			clr	r16
			clr	r17
			clr	r18
			clr	r19
			ldi	r24,32			;32 bits
			clt				;DR shift
			call	jppc_shift		

			st	Y+,r20
			st	Y+,r21
			st	Y+,r22
			st	Y+,r23

			;public connect sequence
			ldi	r16,0x07		;CONNECT
			ldi	r24,6
			set
			call	jppc_shift

			ldi	r16,0x89		;write connect key
			ldi	r24,8
			clt
			call	jppc_shift

			
			jmp	main_loop_ok

cc2640_inittab:		.db	0xa0,0x04, 0xc0,0x03, 0xa0,0x04, 0xc0,0x03, 0xa0,0x04, 0xb0,0x05, 0xa0,0x04
			.db	0x4c,0x07, 0xa0,0x04, 0x90,0x05, 0x90,0x05, 0x90,0x05, 0x90,0x05
			.db	0xa0,0x04, 0xc0,0x03, 0xa0,0x04, 0xc0,0x03

;-------------------------------------------------------------------------------
; mass erase and enable WUC
;-------------------------------------------------------------------------------
cc2640_merase:	;	sbi	CTRLPORT,JCC_TRIG
			out	GPIOR0,r16
			;enable WUC
			ldi	r16,0x02
			ldi	r24,6
			set
			call	jppc_shift

			ldi	r16,0x00
			ldi	r17,0x01
			ldi	r18,0x00
			ldi	r19,0x95
			ldi	r24,32
			clt
			call	jppc_shift

			rcall	cc2640_spause

			JCC_CLOCK4


			sbis	GPIOR0,0
			rjmp	cc2640_merase_1

			;initiate mass erase
			ldi	r16,0xF1
			ldi	r17,0xFF
			ldi	r24,10
			set
			call	jppc_shift

			ldi	r16,0x02
			ldi	r17,0x00
			ldi	r24,9
			clt
			call	jppc_shift

			;initiate reset
			ldi	r16,0xF1
			ldi	r17,0xFF
			ldi	r24,10
			set
			call	jppc_shift

			ldi	r16,0x20
			ldi	r17,0x00
			ldi	r24,9
			clt
			call	jppc_shift

;			cbi	CTRLPORT,JCC_RESET	;set reset HI
			ldi	ZL,0
			ldi	ZH,3
			call	api_wait_ms

cc2640_merase_1:

			;setup MCU VD
			ldi	r16,0xFC
			ldi	r17,0xFF
			ldi	r24,10
			set
			call	jppc_shift

			ldi	r16,0x40
			ldi	r17,0x00
			ldi	r24,9
			clt
			call	jppc_shift

			rcall	cc2640_spause

			JCC_CLOCK4

			;disable WUC
			ldi	r16,0x02
			ldi	r24,6
			set
			call	jppc_shift

			ldi	r16,0x00
			ldi	r17,0x00
			ldi	r18,0x00
			ldi	r19,0x95
			ldi	r24,32
			clt
			call	jppc_shift
			
			rcall	cc2640_spause

			JCC_CLOCK4

			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; init core
;-------------------------------------------------------------------------------
cc2640_init_core:	ldi	YL,0
			ldi	YH,1
			;enable CM3 debug TAP
			ldi	r16,0x02	;connect
			ldi	r24,6
			set
			call	jppc_shift

			ldi	r16,0x00
			ldi	r17,0x01	;TAP visible
			ldi	r18,0x00
			ldi	r19,0xA0	;Write DEBUG TAP 0
			ldi	r24,32
			clt
			call	jppc_shift

			rcall	cc2640_spause

			JCC_CLOCK4


			;readout CM3 ID 
			ldi	r16,0x0E	;ACCESS ID CODE REGISTER
			call	cc2640_ishift

			rcall	cc2640_spause

			ldi	r24,32
			call	jppc_shift

			st	Y+,r20
			st	Y+,r21
			st	Y+,r22
			st	Y+,r23

;			sbi	CTRLPORT,JCC_TRIG

			JCC_CLOCK4

			ldi	ZL,LOW(cc2640_icore_data*2)
			ldi	ZH,HIGH(cc2640_icore_data*2)
			
			ldi	r21,18			;14
			rcall	cc2640_nstep		;set registers

			ldi	ZL,1
			ldi	ZH,4
			call	api_wait_ms

cc2640_icore_2:			
			st	Y+,XL
			st	Y+,r16
			st	Y+,r17
			st	Y+,r18
			st	Y+,r19			
			jmp	main_loop_ok


cc2640_icore_data:	.db	0x08,0x00,0x00,0x00,0x00,0x1e	;abort
			.db	0x0A,0x04,0x00,0x00,0x00,0x00	;select
			.db	0x0A,0x02,0x50,0x00,0x00,0x00	;write DP.CTRL/STAT
			.db	0x0A,0x02,0x54,0x00,0x00,0x00	;write DP.CTRL/STAT
			.db	0x0A,0x02,0x50,0x00,0x00,0x00	;AP transfer mode
			.db	0x0B,0x00,0x22,0x00,0x00,0x52	;CSW (32 bit, auto-increment)
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF0	;ADR (TAR) DHCSR
			.db	0x0B,0x06,0xA0,0x5F,0x00,0x0B	;0B DATA (DRW) enable debug
;			.db	0x0B,0x02,0xE0,0x00,0xED,0xFC	;ADR (TAR) DEMCR
;			.db	0x0B,0x06,0x00,0x00,0x00,0x01	;DATA (DRW) reset vector catch

			.db	0x0B,0x02,0x40,0x08,0x21,0x2c	;ADR (TAR)	PDCTL0
			.db	0x0B,0x06,0x00,0x00,0x00,0x06	;DATA (DRW)	PERIPH ON
			.db	0x0B,0x02,0x40,0x08,0x20,0x48	;ADR (TAR)	GPIOCLKR
			.db	0x0B,0x06,0x00,0x00,0x00,0x01	;DATA (DRW)	1
			.db	0x0B,0x02,0x40,0x08,0x20,0x28	;ADR (TAR)	CLKLOADCTL
			.db	0x0B,0x06,0x00,0x00,0x00,0x01	;DATA (DRW)	1

			.db	0x0B,0x02,0x40,0x02,0x20,0xD0	;ADR (TAR)	DOE
			.db	0x0B,0x06,0x00,0x00,0x00,0xC0	;DATA (DRW)	6+7
			.db	0x0B,0x02,0x40,0x02,0x20,0x80	;ADR (TAR)	DOUTSET
			.db	0x0B,0x06,0x00,0x00,0x00,0xC0	;DATA (DRW)	6+7

;-------------------------------------------------------------------------------
; write 2K code to memory
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_wcode:		ldi	YL,0
			ldi	YH,1
			push	r16
			rcall	cc2640_apacc		;accesse APACC register
			ldi	r25,0x02		;access TAR register (write)
			pop	r16
			rcall	cc2640_xshift
				
			ldi	ZL,4			;2048 bytes to do
			ldi	ZH,8			
cc2640_wcode_1:		ldi	r25,0x06		;access DRW register (write)
			ld	r16,Y+
			ld	r17,Y+
			ld	r18,Y+
			ld	r19,Y+
			rcall	cc2640_xshift
		
			sbiw	ZL,4
			brne	cc2640_wcode_1

cc2640_wcode_end:	jmp	main_loop_ok

;-------------------------------------------------------------------------------
; write 2K data to buffer
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_wdata:		ldi	YL,0
			ldi	YH,1			
			sts	0x900,r16		;store address
			sts	0x901,r17
			sts	0x902,r18
			sts	0x903,r19
		
			rcall	cc2640_apacc		;accesse APACC register
			ldi	r25,0x02		;access TAR register (write)			
			ldi	r16,0x00
			ldi	r17,0x20
			ldi	r18,0x00
			ldi	r19,0x20
			rcall	cc2640_xshift
			

			ldi	ZL,4			;2048 bytes to do
			ldi	ZH,8			
cc2640_wdata_1:		ldi	r25,0x06		;access DRW register (write)
			ld	r16,Y+
			ld	r17,Y+
			ld	r18,Y+
			ld	r19,Y+
			rcall	cc2640_xshift

			sbiw	ZL,4
			brne	cc2640_wdata_1

cc2640_wdata_end:	jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read 2K code from memory
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_read:		ldi	YL,0
			ldi	YH,1
			push	r16
			rcall	cc2640_apacc		;accesse APACC register
			ldi	r25,0x02		;access TAR register (write)
			pop	r16
			rcall	cc2640_xshift
			
			ldi	r25,0x07		;access DRW register (read)
			rcall	cc2640_xshift

			ldi	ZL,0			;bytes to do
			ldi	ZH,8			
cc2640_read_1:		ldi	r25,0x07		;access DRW register (read again)
			rcall	cc2640_xshift
			st	Y+,r16
			st	Y+,r17
			st	Y+,r18
			st	Y+,r19

			sbiw	ZL,4
			brne	cc2640_read_1
			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; read 1 long code from memory
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_read_single:	ldi	YL,0
			ldi	YH,1
			push	r16
			rcall	cc2640_apacc		;accesse APACC register
			ldi	r25,0x02		;access TAR register (write)
			pop	r16
			rcall	cc2640_xshift
			
			ldi	r25,0x07		;access DRW register (read)
			rcall	cc2640_xshift

			ldi	r25,0x07		;access DRW register (read again)
			rcall	cc2640_xshift
			st	Y+,r16
			st	Y+,r17
			st	Y+,r18
			st	Y+,r19
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read status
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_rstat:		ldi	ZL,0			;bytes to do
			ldi	ZH,8			
			rcall	cc2640_apacc		;accesse APACC register
			ldi	r25,0x02		;access TAR register (write)
			ldi	r16,0x00
			ldi	r17,0x28
			ldi	r18,0x00
			ldi	r19,0x20
			rcall	cc2640_xshift

			ldi	r25,0x07		;access DRW register (read)
			rcall	cc2640_xshift
			ldi	r25,0x07		;access DRW register (read again)
			rcall	cc2640_xshift
			jmp	main_loop
	
;-------------------------------------------------------------------------------
; start CPU
; r16-r19 = address
;-------------------------------------------------------------------------------
cc2640_start_core:	ldi	YL,0
			ldi	YH,1
			movw	r8,r16			;AL
			movw	r10,r18			;AH


			rcall	cc2640_apacc		;accesse APACC register
		
			ldi	ZL,LOW(cc2640_start_data*2)
			ldi	ZH,HIGH(cc2640_start_data*2)

			ldi	r21,5
			rcall	cc2640_nstep		;set registers

			ldi	r25,0x06		;access DRW register (write)
			movw	r16,r8			;addr loword
			movw	r18,r10			;addr hiword
			rcall	cc2640_xshift

			ldi	r21,8
			rcall	cc2640_nstep		;abort

			st	Y+,r16
			st	Y+,r17
			st	Y+,r18
			st	Y+,r19			

			jmp	main_loop_ok


cc2640_start_data:	.db	0x0B,0x02,0xE0,0x00,0xED,0xF8	;ADR (TAR) DCRDR		load SP data
			.db	0x0B,0x06,0x20,0x00,0x50,0x00	;set SP to end of RAM
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF4	;ADR (TAR) DCRSR
			.db	0x0B,0x06,0x00,0x01,0x00,0x0D	;DATA (DRW) stack pointer	write SP
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF8	;ADR (TAR) DCRDR		load PC data
			;... insert code start
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF4	;ADR (TAR) DCRSR		
			.db	0x0B,0x06,0x00,0x01,0x00,0x0F	;DATA (DRW) PC			write PC
			.db	0x0B,0x02,0xE0,0x00,0xED,0x0C	;ADR (TAR) AIRCR
			.db	0x0B,0x06,0xFA,0x05,0x00,0x04	;DATA (DRW) start (release) core

			.db	0x0B,0x02,0xE0,0x00,0xED,0xF0	;ADR (TAR) DHCSR
			.db	0x0B,0x06,0xA0,0x5F,0x00,0x09	;DATA (DRW) start (release) core
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF0	;ADR (TAR) DHCSR
			.db	0x0B,0x06,0xA0,0x5F,0x00,0x09	;DATA debug off
			
			

cc2640_read_pc:		ldi	YL,0
			ldi	YH,1


			ldi	ZL,LOW(cc2640_rpc_data*2)
			ldi	ZH,HIGH(cc2640_rpc_data*2)

			ldi	r21,5
			rcall	cc2640_nstep		;read PC

			rcall	cc2640_dbg_store

			ldi	r21,3
			rcall	cc2640_nstep		;read DHCSR

			rcall	cc2640_dbg_store

			ldi	r21,3
			rcall	cc2640_nstep		;read Code at start

			rcall	cc2640_dbg_store

			jmp	main_loop_ok


cc2640_rpc_data:	.db	0x0B,0x02,0xE0,0x00,0xED,0xF4	;ADR (TAR) DCRSR
			.db	0x0B,0x06,0x00,0x00,0x00,0x0F	;DATA (DRW) PC
			.db	0x0B,0x02,0xE0,0x00,0xED,0xF8	;ADR (TAR) DCRDR
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data

			.db	0x0B,0x02,0xE0,0x00,0xED,0xF0	;ADR DHCSR
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data


			.db	0x0B,0x02,0x20,0x00,0x00,0xC8	;ADR PDSTAT1
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data
			.db	0x0B,0x07,0x00,0x00,0x00,0x00	;read data


cc2640_dbg_store:	st	Y+,r16
			st	Y+,r17
			st	Y+,r18
			st	Y+,r19			
			ret

;-------------------------------------------------------------------------------
; 
;-------------------------------------------------------------------------------
cc2640_nstep:		rcall	cc2640_jstep		;abort
			rcall	cc2640_spause		
			dec	r21
			brne	cc2640_nstep	
			ret


cc2640_jstep:		lpm	r16,Z+
			sbrs	r16,7
			rcall	cc2640_xpacc
			lpm	r25,Z+
			lpm	r19,Z+
			lpm	r18,Z+
			lpm	r17,Z+
			lpm	r16,Z+
			rjmp	cc2640_xshift

;-------------------------------------------------------------------------------
; APACC Access
;-------------------------------------------------------------------------------
cc2640_apacc:		ldi	r16,0x0B	;ACCESS APACC REGISTER
			rjmp	cc2640_xpacc

;-------------------------------------------------------------------------------
; DPACC Access
;-------------------------------------------------------------------------------
cc2640_dpacc:		ldi	r16,0x0A	;ACCESS DPACC REGISTER
cc2640_xpacc:		rcall	cc2640_ishift
			rcall	cc2640_spause
			ret

;-------------------------------------------------------------------------------
; cjtag shifts
; XH = data (left justified)
; XL= num of shifts
;-------------------------------------------------------------------------------
cjtag_nshift:		sbrc	XH,7
			sbi	CTRLPORT,JCC_TMS
			sbrs	XH,7
			cbi	CTRLPORT,JCC_TMS
			sbi	CTRLPORT,JCC_TCK	;2
			nop				;1 filling
			cbi	CTRLPORT,JCC_TCK	;2
			lsl	XH
			dec	XL
			brne	cjtag_nshift
			ret
			
cc2640_spause:		ldi	r24,0x80	
cc2640_spause1:		dec	r24
			brne	cc2640_spause1
			ret

;------------------------------------------------------------------------------
; some single shifts
;------------------------------------------------------------------------------
cc2640_single_shift:	sbrc	r16,0				;skip if zero
			sbi	CTRLPORT,JPPC_TDI
			sbrs	r16,0				;skip if one
			cbi	CTRLPORT,JPPC_TDI
			sbi	CTRLPORT,JPPC_TCK	;2			
			nop
			nop
			cbi	CTRLPORT,JPPC_TCK	;2			
			ret

cc2640_shift_r25xl:	sbrc	r25,0				;skip if zero
			sbi	CTRLPORT,JPPC_TDI
			sbrs	r25,0				;skip if one
			cbi	CTRLPORT,JPPC_TDI
			sbi	CTRLPORT,JPPC_TCK	;2			
			sbic	CTRLPIN,JPPC_TDO
			ori	XL,0x80
			lsr	r25
			lsr	XL
			cbi	CTRLPORT,JPPC_TCK	;2			
			ret
		

;------------------------------------------------------------------------------
; do IR/DR SHIFT (1-255 Bits)
; T=0 -> DR SCAN
; T=1 -> IR SCAN
; r16		Data to send/read
; r24		Bits to shift
;------------------------------------------------------------------------------
cc2640_ishift:		sbi	CTRLPORT,JPPC_TDI
			sbi	CTRLPORT,JPPC_TMS
			JCC_CLOCK2			;-> DR-scan -> IR-scan
			cbi	CTRLPORT,JPPC_TMS
			JCC_CLOCK2			;-> CAPTURE -> SHIFT 6 (ICEPICK TAP)
			
			ldi	r24,4
cc2640_ishift_2:	rcall	cc2640_single_shift
			lsr	r16
			dec	r24				;bit counter
			brne	cc2640_ishift_2			;shift loop

			sbi	CTRLPORT,JPPC_TDI
			JCC_CLOCK5				;-> CAPTURE -> SHIFT 6 (ICEPICK TAP)
			sbi	CTRLPORT,JPPC_TMS		;last bit -> exit IR	
			JCC_CLOCK2				;-> UPDATE
			cbi	CTRLPORT,JPPC_TMS		;
			JCC_CLOCK4				;-> run-test-idle
			ret


;------------------------------------------------------------------------------
; do DR SHIFT (35+1 Bits) for write DPACC/APACC
; r25= ADDR 3:2
; r16-r19	Data to write
;------------------------------------------------------------------------------
cc2640_xshift:		sbi	CTRLPORT,JPPC_TMS
			JCC_CLOCK			;-> DR-scan
			cbi	CTRLPORT,JPPC_TMS
			JCC_CLOCK2			;-> CAPTURE

			ldi	r24,3
cc2640_xshift_1:	rcall	cc2640_shift_r25xl
			dec	r24
			brne	cc2640_xshift_1						
			lsr	XL
			swap	XL
			andi	XL,0x07
			
			ldi	r24,32

cc2640_xshift_2:	sbrc	r16,0				;skip if zero
			sbi	CTRLPORT,JPPC_TDI
			sbrs	r16,0				;skip if one
			cbi	CTRLPORT,JPPC_TDI
			sbi	CTRLPORT,JPPC_TCK	;2			
			lsr	r19
			ror	r18
			ror	r17
			ror	r16	
			sbic	CTRLPIN,JPPC_TDO
			ori	r19,0x80			;set bit					
			cbi	CTRLPORT,JPPC_TCK	;2			
			dec	r24				;bit counter
			brne	cc2640_xshift_2			;shift loop

			sbi	CTRLPORT,JPPC_TMS		;last bit -> exit DR
			JCC_CLOCK2				;-> EXIT DR, UPDATE DR
			cbi	CTRLPORT,JPPC_TMS		;
			JCC_CLOCK2				;-> run-test-idle
			ret
;-------------------------------------------------------------------------------
; clock cycle
;-------------------------------------------------------------------------------
jcc_clock:		ldi	XH,1
jcc_nclock:		sbi	CTRLPORT,JCC_TCK	;2
			nop				;1 filling
			cbi	CTRLPORT,JCC_TCK	;2
			dec	XH
			brne	jcc_nclock
			ret

			sbi	CTRLPORT,JCC_TCK	;2
			cbi	CTRLPORT,JCC_TCK	;2
		