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

.equ		J9500_TMS	= SIG1
.equ		J9500_TCK	= SIG2
.equ		J9500_TDI	= SIG3
.equ		J9500_TDO	= SIG4

.equ		xc9500_buffer	= 0x0a00

;------------------------------------------------------------------------------
; init JTAG interface and read device id
;------------------------------------------------------------------------------
xc9500_init:		out	CTRLPORT,const_0
			sbi	CTRLDDR,J9500_TMS
			sbi	CTRLDDR,J9500_TCK
			sbi	CTRLDDR,J9500_TDI
			cbi	CTRLDDR,J9500_TDO
			call	api_vcc_on
			ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,J9500_TMS	;->reset
			ldi	r24,16
			ldi	r25,0
xc9500_init_1:		rcall	xc9500_stck
			sbiw	r24,1
			brne	xc9500_init_1
			cbi	CTRLPORT,J9500_TMS	;->run-test-idle
			ldi	r24,16
			ldi	r25,0
xc9500_init_2:		rcall	xc9500_stck
			sbiw	r24,1
			brne	xc9500_init_2
			
			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xfe
			rcall	xc9500_shift		
	
			clr	r16
			clr	r17
			clr	r18
			clr	r19
			ldi	r24,32			;32 bits
			clt				;DR shift
			rcall	xc9500_shift		
			
			andi	r23,0x0f
			sts	0x100,r20
			sts	0x101,r21
			sts	0x102,r22
			sts	0x103,r23
			
			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xff
			rcall	xc9500_shift		
			andi	r20,0xe3
			sts	0x104,r20
			
			ldi	r24,16			;16 bits
			set				;IR shift
			ldi	r17,0xff
			ldi	r16,0xaa
			rcall	xc9500_shift		
			andi	r20,0xe3			
			sts	0x105,r20
			sts	0x106,r21
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; exit
;------------------------------------------------------------------------------
xc9500_exit:		sbi	CTRLPORT,J9500_TMS	;->reset
			ldi	r24,100
			ldi	r25,0
xc9500_exit_1:		rcall	xc9500_stck
			sbiw	r24,1
			brne	xc9500_exit_1

			out	CTRLPORT,const_0
			out	CTRLDDR,const_0
			call	api_vcc_off
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; bulk erase for xc9500
; PAR1/2=time
;------------------------------------------------------------------------------
xc9500_erase:		movw	r4,r16
			movw	r6,r18
			sts	0x100,const_0
			sts	0x101,const_0
			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xe8		;"ispen"
			rcall	xc9500_shift		

			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xed		;"fbulk"
			rcall	xc9500_shift		

			ldi	r24,27			;27 bits
			clt				;DR shift
			ldi	r16,0xfe
			ldi	r17,0xff
			ldi	r18,0x3f
			ldi	r19,0x00
			rcall	xc9500_shift		

			movw	ZL,r4
			call	api_wait_ms
			
			ldi	r24,27			;27 bits
			clt				;DR shift
			ldi	r16,0xfe
			ldi	r17,0xff
			ldi	r18,0x3f
			ldi	r19,0x00
			rcall	xc9500_shift
			sts	0x100,r20		
			andi	r20,0x03
			cpi	r20,0x03
			brne	xc9500_erase_err

			ldi	r24,27			;27 bits
			clt				;DR shift
			ldi	r16,0xfe
			ldi	r17,0xff
			ldi	r18,0x7f
			ldi	r19,0x00
			rcall	xc9500_shift		

			movw	ZL,r6
			call	api_wait_ms
			
			ldi	r24,27			;27 bits
			clt				;DR shift
			ldi	r16,0xfe
			ldi	r17,0xff
			ldi	r18,0x7f
			ldi	r19,0x00
			rcall	xc9500_shift		
			sts	0x101,r20		
			andi	r20,0x03
			cpi	r20,0x03
			brne	xc9500_erase_err

xc9500_erase_2:		ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xf0		;"conld"
			rcall	xc9500_shift		

			jmp	main_loop_ok
						
xc9500_erase_err:	ldi	r16,0x54		;erase failed
			jmp	main_loop

;------------------------------------------------------------------------------
; bulk erase for xc9500XL
;------------------------------------------------------------------------------
xc9500xl_erase:		movw	r4,r16
			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xe8		;"ispen"
			rcall	xc9500_shift		

			ldi	r24,6			;8 bits
			clt				;DR shift
			ldi	r16,0x05
			rcall	xc9500_shift		

			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xed		;"fbulk"
			rcall	xc9500_shift		

			ldi	r24,18			;18 bits
			clt				;DR shift
			ldi	r16,0xff
			ldi	r17,0xff
			ldi	r18,0x03
			rcall	xc9500_shift		

			ldi	XL,8
			mov	r12,XL

xc9500xl_erase_wait:	ldi	ZL,0
			ldi	ZH,2
			call	api_wait_ms
			
			ldi	r24,18			;18 bits
			clt				;DR shift
			ldi	r16,0xfd
			ldi	r17,0xff
			ldi	r18,0x03
			rcall	xc9500_shift
			sts	0x100,r20		
			sts	0x101,r21		
			sts	0x102,r22				
			andi	r20,0x03
			cpi	r20,0x01
			breq	xc9500xl_erase_end
			dec	r12
			breq	xc9500_erase_err
			rjmp	xc9500xl_erase_wait	

xc9500xl_erase_end:	ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xf0		;"conld"
			rcall	xc9500_shift		

			ldi	r17,1			;1000 additional clocks
			rcall	xc9500xl_prog_time

			jmp	main_loop_ok
						

;------------------------------------------------------------------------------
; program xc9500
; PAR1=shift size
; PAR2=pause
; PAR3/4 number of shifts
;------------------------------------------------------------------------------
xc9500_prog_start:	ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xe8		;"ispen"
			rcall	xc9500_shift		

			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xea		;"fpgm"
			rcall	xc9500_shift		
			jmp	main_loop_ok

xc9500_prog:		mov	XL,r16			;shift size
			subi	XL,0xf9			;+7
			lsr	XL			;/8
			lsr	XL
			lsr	XL			
			mov	r10,XL			;bytes per chunk
			clr	r12			;error indicator

			movw	r4,r16			;copy shift size & pause
			movw	r6,r18			;copy number of chunks
			call	api_resetptr		;set pointer to start
			mov	r24,r16			;size
			rcall	xc9500_mshift		;first shift	
			rcall	xc9500_prog_time	;double time
			rcall	xc9500_prog_time	
	
			movw	r24,r6
			sbiw	r24,1
			movw	r6,r24	
			
xc9500_prog_1:		ldi	XL,32			;repeat counter
			mov	r11,XL

xc9500_prog_2:		mov	r24,r16			;size
			rcall	xc9500_mshift		;first shift	
			rcall	xc9500_prog_time	
			cpi	r20,0x03
			breq	xc9500_prog_next
			
			dec	r11			;repeat counter
			breq	xc9500_prog_next_e
			sub	YL,r10			;rewind pointer
			sbc	YH,const_0
			rjmp	xc9500_prog_2		;next try
			
xc9500_prog_next_e:	or	r12,const_1		;set error
xc9500_prog_next:	movw	r24,r6
			sbiw	r24,1
			movw	r6,r24
			brne	xc9500_prog_1
			;error?
			cp	r12,const_0		
			brne	xc9500_prog_err
			jmp	main_loop_ok		;OK, all done
			
xc9500_prog_err:	ldi	r16,0x60		;set prog error
			jmp	main_loop		;done


xc9500_prog_end:	ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xf0		;"conld"
			rcall	xc9500_shift		

			jmp	main_loop_ok

xc9500_prog_time:	push	ZL
			push	ZH
			ldi	ZL,67
			mul	ZL,r17
			movw	ZL,r0
xc9500_prog_time_1:	sbiw	ZL,1
			brne	xc9500_prog_time_1
			pop	ZH
			pop	ZL
			ret

;------------------------------------------------------------------------------
; program xc9500xl
; PAR1=shift size
; PAR2=pause
; PAR3/4 number of shifts
;------------------------------------------------------------------------------
xc9500xl_prog_start:	ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xe8		;"ispen"
			rcall	xc9500_shift		

			ldi	r24,6			;8 bits
			clt				;DR shift
			ldi	r16,0x05
			rcall	xc9500_shift		

			ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xea		;"fpgm"
			rcall	xc9500_shift
			
			jmp	main_loop_ok


xc9500xl_prog:		movw	r4,r16			;copy parameters
			movw	r6,r18			;copy count of chunks
			call	api_resetptr		;set pointer to start

			mov	XL,r16			;shift size
			subi	XL,0xf9			;+7
			lsr	XL			;/8
			lsr	XL
			lsr	XL			
			mov	r10,XL			;bytes per chunk

xc9500xl_prog_1:	rcall	xc9500_mshift0		;shift 1	
			rcall	xc9500_mshift0		;shift 2	
			rcall	xc9500_mshift0		;shift 3	
			rcall	xc9500_mshift0		;shift 4	
			rcall	xc9500_mshift0		;shift 5	
			rcall	xc9500_mshift0		;shift 6	
			rcall	xc9500_mshift0		;shift 7	
			rcall	xc9500_mshift0		;shift 8	
			rcall	xc9500_mshift0		;shift 9	
			rcall	xc9500_mshift0		;shift 10	
			rcall	xc9500_mshift0		;shift 11	
			rcall	xc9500_mshift0		;shift 12	
			rcall	xc9500_mshift0		;shift 13	
			rcall	xc9500_mshift0		;shift 14	
			rcall	xc9500_mshift0		;shift 15	

			ldi	XL,128			;tries
			mov	r12,XL

xc9500xl_prog_wait:	ldi	ZL,12
			ldi	ZH,0
			call	api_wait_ms
							
			rcall	xc9500_mshift0		;shift 16	
			cpi	r20,0x01
			breq	xc9500xl_prog_next
			dec	r12		
			breq	xc9500xl_prog_err
			sub	YL,r10
			sbc	YH,const_0
			rjmp	xc9500xl_prog_wait

xc9500xl_prog_next:	movw	r24,r6
			sbiw	r24,16
			movw	r6,r24
			brne	xc9500xl_prog_1
				
			jmp	main_loop_ok
			
xc9500xl_prog_err:	ldi	r16,0x60
			add	r16,r20
			jmp	main_loop

xc9500xl_prog_end:	ldi	r24,8			;8 bits
			set				;IR shift
			ldi	r16,0xf0		;"conld"
			rcall	xc9500_shift		

			ldi	r17,1			;1000 additional clocks
			rcall	xc9500xl_prog_time

			jmp	main_loop_ok

			;r17 x 5000 TCK clocks with 1 MHz
xc9500xl_prog_time:	push	ZL
			push	ZH
			push	XL
			ldi	ZL,50
			mul	ZL,r17
			movw	ZL,r0
xc9500xl_prog_time_1:	ldi	XL,100
xc9500xl_prog_time_2:	sbi	CTRLPORT,J9500_TCK	;2
			rcall	xc9500xl_prog_time_3	;7
			cbi	CTRLPORT,J9500_TCK	;2			
			rcall	xc9500xl_prog_time_3	;7
			dec	XL			;1
			brne	xc9500xl_prog_time_2	;2
			sbiw	ZL,1
			brne	xc9500xl_prog_time_1
			pop	XL
			pop	ZH
			pop	ZL
			ret

xc9500xl_prog_time_3:	ret


;------------------------------------------------------------------------------
; do IR/DR SHIFT (1-255 Bits)
; T=0 -> DR SCAN
; T=1 -> IR SCAN
; r16-r19	Data to send
; r20-r23	Data read
; r24		Bits to shift
;------------------------------------------------------------------------------
xc9500_shift:		clr	r20
			clr	r21
			clr	r22
			clr	r23
			ldi	r25,0x20
			sub	r25,r24				;r25=result shift
			sbi	CTRLPORT,J9500_TMS
			rcall	xc9500_stck			;-> DR-scan
			brtc	xc9500_shift_1
			rcall	xc9500_stck			;-> IR-scan
xc9500_shift_1:		cbi	CTRLPORT,J9500_TMS
			rcall	xc9500_stck			;-> CAPTURE
			rcall	xc9500_stck			;-> SHIFT

xc9500_shift_2:		sbrc	r16,0				;skip if zero
			sbi	CTRLPORT,J9500_TDI
			sbrs	r16,0				;skip if one
			cbi	CTRLPORT,J9500_TDI
			cpi	r24,1				;is this the last?
			brne	xc9500_shift_3
			sbi	CTRLPORT,J9500_TMS		;last bit -> exit IR
xc9500_shift_3:		sbi	CTRLPORT,J9500_TCK	;2			
			lsr	r19
			ror	r18
			ror	r17
			ror	r16

			lsr	r23
			ror	r22
			ror	r21
			ror	r20
			
			sbic	CTRLPIN,J9500_TDO
			ori	r23,0x80			;set bit
			cbi	CTRLPORT,J9500_TCK	;2			
			dec	r24				;bit counter
			brne	xc9500_shift_2			;shift loop

			rcall	xc9500_stck			;-> UPDATE
			cbi	CTRLPORT,J9500_TMS		;
			rcall	xc9500_stck			;-> run-test-idle
			
xc9500_shift_4:		cpi	r25,0
			breq	xc9500_shift_5
			lsr	r23
			ror	r22
			ror	r21
			ror	r20
			dec	r25
			rjmp	xc9500_shift_4
					
xc9500_shift_5:		ret


;------------------------------------------------------------------------------
; do DR SHIFT (1-255 Bits)
; [buffer]	Data to send (starting with LSB first)
; r24		Bits to shift
; r20		result
;------------------------------------------------------------------------------
xc9500_mshift0:		mov	r24,r4
xc9500_mshift:		sbi	CTRLPORT,J9500_TMS
			rcall	xc9500_stck			;-> DR-scan
			cbi	CTRLPORT,J9500_TMS
			rcall	xc9500_stck			;-> CAPTURE
			rcall	xc9500_stck			;-> SHIFT
			call	api_buf_bread			;read first byte
			ldi	r25,6				;bits per byte -2
			subi	r24,2				;-2 bits
			clr	r20				;result=0

			;bit 0
xc9500_mshift_1:	sbrc	XL,0				;skip if zero
			sbi	CTRLPORT,J9500_TDI
			sbrs	XL,0				;skip if one
			cbi	CTRLPORT,J9500_TDI
			sbi	CTRLPORT,J9500_TCK	;2			
			lsr	XL
			nop
			nop
			sbic	CTRLPIN,J9500_TDO
			ori	r20,0x01			;set bit 0 in result
			cbi	CTRLPORT,J9500_TCK	;2			
	
			sbrc	XL,0				;skip if zero
			sbi	CTRLPORT,J9500_TDI
			sbrs	XL,0				;skip if one
			cbi	CTRLPORT,J9500_TDI
			sbi	CTRLPORT,J9500_TCK	;2			
			lsr	XL
			nop
			nop
			sbic	CTRLPIN,J9500_TDO
			ori	r20,0x02			;set bit 1
			cbi	CTRLPORT,J9500_TCK	;2			
	
xc9500_mshift_2:	sbrc	XL,0				;skip if zero
			sbi	CTRLPORT,J9500_TDI
			sbrs	XL,0				;skip if one
			cbi	CTRLPORT,J9500_TDI
			lsr	XL	
			
			cpi	r24,1				;is this the last?
			brne	xc9500_mshift_3
			sbi	CTRLPORT,J9500_TMS		;last bit -> exit IR
xc9500_mshift_3:	sbi	CTRLPORT,J9500_TCK	;2
			dec	r25
			brne	xc9500_mshift_4			
			call	api_buf_bread			;read first byte
			ldi	r25,8				;bits per byte

xc9500_mshift_4:	cbi	CTRLPORT,J9500_TCK	;2
			dec	r24				;bit counter
			brne	xc9500_mshift_2			;shift loop

			rcall	xc9500_stck			;-> UPDATE
			cbi	CTRLPORT,J9500_TMS		;
			rcall	xc9500_stck			;-> run-test-idle

xc9500_mshift_5:	ret


;------------------------------------------------------------------------------
; do one tck clock
;------------------------------------------------------------------------------
xc9500_stck:		sbi	CTRLPORT,J9500_TCK	;2
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			cbi	CTRLPORT,J9500_TCK	;2
			nop				;1 filling
			ret



