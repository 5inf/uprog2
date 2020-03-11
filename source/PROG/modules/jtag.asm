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
.equ		JTAG_TMS	= SIG1
.equ		JTAG_TCK	= SIG2
.equ		JTAG_TDI	= SIG3
.equ		JTAG_TDO	= SIG4
.equ		JTAG_TRST	= SIG5

.equ		jtag_buffer	= 0x0a00

;------------------------------------------------------------------------------
; init JTAG interface and goto run-test-idle
;------------------------------------------------------------------------------
jtag_init:	out	CTRLPORT,const_0
		ldi	XL,0x0f			;all output except TDO
		out	CTRLDDR,XL
		call	api_vcc_on
		ldi	ZL,100
		ldi	ZH,10
		call	api_wait_ms
		sbi	CTRLPORT,JTAG_TMS
		ldi	r20,100
		ldi	r21,0
		rcall	jtag_ntck16		;->reset
		cbi	CTRLPORT,JTAG_TMS
		ldi	r21,10
		rcall	jtag_ntck16		;->run-test-idle
		jmp	main_loop_ok


jtag_exit:	out	CTRLPORT,const_0
		out	CTRLDDR,const_0
		call	api_vcc_off
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; the jtag code parser
;------------------------------------------------------------------------------
jtag_parser:	movw	YL,const_0		;set pointer to start

jtag_ploop:	ld	XL,Y+			;read one byte
		cpi	XL,0x00			;end?
		brne	jtag_ploop_1
		jmp	main_loop_ok		;regular end

		;RUNTEST 16 Bit
jtag_ploop_1:	cpi	XL,0x01
		brne	jtag_ploop_2
jtag_ploop_1a:	ld	r21,Y+			;HIGH
		ld	r20,Y+			;LOW
		rcall	jtag_ntck16
		rjmp	jtag_ploop

		;RUNTEST 32 Bit
jtag_ploop_2:	cpi	XL,0x02
		brne	jtag_ploop_4
		ld	r23,Y+			;E2
		ld	r22,Y+			;E1
		ld	r21,Y+			;HIGH
		ld	r20,Y+			;LOW
		rcall	jtag_ntck
		rjmp	jtag_ploop

		;DR shift (no verify)
jtag_ploop_4:	cpi	XL,0x04
		brne	jtag_ploop_5
		clt
		rcall	jtag_shift
		rjmp	jtag_ploop

		;IR shift (no verify)
jtag_ploop_5:	cpi	XL,0x05
		brne	jtag_ploop_6
		set
		rcall	jtag_shift
		rjmp	jtag_ploop

		;DR shift (verify)
jtag_ploop_6:	cpi	XL,0x06
		brne	jtag_ploop_7
		clt
		rcall	jtag_shift
		rcall	jtag_check
		rjmp	jtag_ploop

		;IR shift (verify)
jtag_ploop_7:	cpi	XL,0x07
		brne	jtag_ploop_8
		set
		rcall	jtag_shift
		rcall	jtag_check
jtag_ploop_8:	rjmp	jtag_ploop





;------------------------------------------------------------------------------
; do IR/DR SHIFT (1-255 Bits)
; T=0 -> DR SCAN
; T=1 -> IR SCAN
;------------------------------------------------------------------------------
jtag_shift:		movw	r4,YL				;save pointer
			ld	r24,Y+				;bits to shift
			ld	r25,Y+
			
jtag_shift_0:		ldi	ZL,LOW(jtag_buffer)		;temp buffer
			ldi	ZH,HIGH(jtag_buffer)

jtag_shift_01:		sbi	CTRLPORT,JTAG_TMS
			rcall	jtag_stck			;-> DR-scan
			brtc	jtag_shift_1
			rcall	jtag_stck			;-> IR-scan
jtag_shift_1:		cbi	CTRLPORT,JTAG_TMS
			rcall	jtag_stck			;-> CAPTURE
			rcall	jtag_stck			;-> SHIFT
			clr	r23				;bitcounter
			clr	XH				;out buffer

jtag_shift_2:		cpi	r23,0
			brne	jtag_shift_3
			ldi	r23,8				;bits per byte
			ld	XL,Y+				;get byte from in buffer
			st	Z+,XH				;store to out buffer

jtag_shift_3:		sbrc	XL,0				;skip if zero
			sbi	CTRLPORT,JTAG_TDI
			sbrs	XL,0				;skip if one
			cbi	CTRLPORT,JTAG_TDI
			cpi	r25,0				;is this the last?
			brne	jtag_shift_4
			cpi	r24,1				;is this the last?
			brne	jtag_shift_4
			sbi	CTRLPORT,JTAG_TMS		;last bit -> exit IR
jtag_shift_4:		rcall	jtag_stck			;SHIFT clock
			
			lsr	XL				;shift tdi buffer
			lsr	XH				;shift tdo buffer
			sbic	CTRLPIN,JTAG_TDO
			ori	XH,0x80				;set bit
			sbiw	r24,1				;bit counter
			brne	jtag_shift_2			;shift loop

			rcall	jtag_stck			;-> UPDATE
			cbi	CTRLPORT,JTAG_TMS		;
			rcall	jtag_stck			;-> run-test-idle
			
			movw	YL,r4				;restore pointer
			ret

;------------------------------------------------------------------------------
; check
;------------------------------------------------------------------------------
jtag_check:		movw	r4,YL				;save pointer
			ld	r24,Y+				;bits to shift
			ld	r25,Y+
			movw	XL,r24
			adiw	XL,7
			lsr	XH				;/8
			ror	XL
			lsr	XH
			ror	XL
			lsr	XH
			ror	XL
			mov	r21,XL				;bytes to do
			
			movw	XL,YL	
			
			
			ldi	r21,3
jtag_check_1s:		lsr	XH
			ror	XL
			dec	r21
	
			
jtag_check_0:		ldi	ZL,LOW(jtag_buffer)		;temp buffer
			ldi	ZH,HIGH(jtag_buffer)




		movw	XL,YL				;copy pointer
			movw	ZL,r24				;save bit counter


			add	YL,r21			;bytes
			adc	YL,const_0
			clr	r16
			mov	r20,r21
			;X=odata, Y=mask, Z=rdata, r21=bytes
jtag_check_1:		ld	r22,X+			;odata
			ld	r23,Z+			;rdata
			ld	r0,Y+			;mask
			and	r22,r0
			and	r23,r0
			cpse	r22,r23
			ldi	r16,1
			dec	r20
			brne	jtag_check_1
			cpi	r16,0
			brne	jtag_check_2
			ret

		pop	r0			;kill stack
		pop	r0
		sub	ZL,r21
		sbc	ZH,const_0
		sub	YL,r21
		sbc	YH,const_0
		sub	YL,r21
		sbc	YH,const_0
		sub	YL,r21
		sbc	YH,const_0
		movw	r0,YL
		movw	YL,const_0
		st	Y+,r21			;bytes
		st	Y+,r0			;low ptr
		st	Y+,r1			;high ptr
jtag_check_2:	ld	r0,Z+
		st	Y+,r0
		dec	r21
		brne	jtag_check_2
		ldi	r16,0x40
		jmp	main_loop

;------------------------------------------------------------------------------
; do one tck clock
; do r20-r21 tck clocks
; do r20-r23 tck clocks
;------------------------------------------------------------------------------
jtag_stck:		ldi	r20,1
			clr	r21
jtag_ntck16:		clr	r22
			clr	r23
jtag_ntck:		sbi	CTRLPORT,JTAG_TCK	;2
			sub	r20,const_1		;1
			sbc	r21,const_0		;1
			sbc	r22,const_0		;1
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			cbi	CTRLPORT,JTAG_TCK	;2
			sbc	r23,const_0		;1
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			brne	jtag_ntck		;2
			ret

