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

.equ	NEC2_COMM_SOH	= 0x01
.equ	NEC2_COMM_STX	= 0x02
.equ	NEC2_COMM_ETX	= 0x03
.equ	NEC2_COMM_ETB	= 0x17

.equ	NEC2_CMD_MERASE	= 0x20
.equ	NEC2_CMD_BERASE	= 0x22
.equ	NEC2_CMD_BCHECK	= 0x32
.equ	NEC2_CMD_PROG	= 0x40
.equ	NEC2_CMD_VERIFY	= 0x13
.equ	NEC2_CMD_READID	= 0xC0
.equ	NEC2_CMD_SECURE	= 0xA0
.equ	NEC2_CMD_OSCSET	= 0x90
.equ	NEC2_CMD_RESET	= 0x00
.equ	NEC2_CMD_STATUS	= 0x70

.equ	NEC2_FLMD0	= SIG3
.equ	NEC2_COMM	= SIG2
.equ	NEC2_RST	= SIG1
.equ	NEC2_OUTMASK	= SIG1_OR | SIG2_OR | SIG3_OR

.macro	NEC2_SENDS
	ldi	XL,@0
	call	send2_9600
.endm

.macro	NEC2_SEND
	ldi	XL,@0
	call	send2_115K
.endm

.macro	NEC2_SENDC
	ldi	XL,@0
	sub	r19,XL
	call	send2_115K
.endm

.macro	NEC2_SENDD
	sub	r19,XL
	call	send2_115K
.endm

;------------------------------------------------------------------------------
; INIT 
;------------------------------------------------------------------------------
nec2_init_err1:	ldi	r16,0x41			;timeout at sync
		jmp	main_loop

nec2_init_err2:	ldi	r16,0x42			;wrong sync
		jmp	main_loop


nec2_init:	ldi	XL,NEC2_OUTMASK
		out	CTRLPORT,const_0		;alles aus
		out	CTRLDDR,XL

		call	api_vcc_on

		rcall	nec2_wait10ms

		sbi	CTRLPORT,NEC2_FLMD0		;FLMD0=1
		sbi	CTRLPORT,NEC2_COMM		;TOOL0=1

		rcall	nec2_wait10ms

		sbi	CTRLPORT,NEC2_RST		;RESET=1
		cbi	CTRLDDR,NEC2_COMM		;input

		call	recv2_9600
		brtc	nec2_init_err1
		cpi	XL,0x00
		brne	nec2_init_err2

		rcall	nec2_wait10ms

		NEC2_SENDS	0x00			;Pulse 1
		rcall	nec2_wait10ms

		NEC2_SENDS	0x00			;Pulse 2
		rcall	nec2_wait10ms

		;RESET
		NEC2_SENDS	NEC2_COMM_SOH
		NEC2_SENDS	0x01			;LEN
		NEC2_SENDS	0x00			;CMD
		NEC2_SENDS	0xFF			;CSUM
		NEC2_SENDS	NEC2_COMM_ETX

		rcall	nec2_wait10ms

		;BAUD RATE SETTING
		NEC2_SENDS	NEC2_COMM_SOH
		NEC2_SENDS	0x06			;LEN
		NEC2_SENDS	0x9A			;CMD
		NEC2_SENDS	0x00			;D01
		NEC2_SENDS	0x00			;D02H
		NEC2_SENDS	0x0A			;D02L
		NEC2_SENDS	0x00			;D03
		NEC2_SENDS	0x00			;D04
		NEC2_SENDS	0x56			;CSUM
		NEC2_SENDS	NEC2_COMM_ETX


		ldi	ZL,100
		ldi	ZH,0
		call	api_wait_ms

		;RESET
		NEC2_SEND	NEC2_COMM_SOH
		NEC2_SEND	0x01			;LEN
		NEC2_SEND	0x00			;CMD
		NEC2_SEND	0xFF			;CSUM
		NEC2_SEND	NEC2_COMM_ETX

		rcall	nec2_rack			;receive ack

		jmp	main_loop_ok

nec2_init_err3:	ldi	r16,0x43			;timeout
		jmp	main_loop

nec2_init_err4:	ldi	r16,0x44			;wrong answer
		jmp	main_loop


nec2_exit:	out	CTRLPORT,const_0	;alles aus
		rcall	nec2_wait10ms
		call	api_vcc_off
		rcall	nec2_wait10ms
		out	CTRLDDR,const_0
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; CHIP ERASE
;-------------------------------------------------------------------------------
nec2_cerase:	NEC2_SEND	NEC2_COMM_SOH
		NEC2_SEND	0x01			;LEN
		NEC2_SEND	0x20			;CMD
		NEC2_SEND	0xdF			;CSUM
		NEC2_SEND	NEC2_COMM_ETX

		rcall	nec2_rack			;receive ack

		jmp	main_loop_ok



;-------------------------------------------------------------------------------
; erase 1K block
; PAR1= block nr
;-------------------------------------------------------------------------------
nec2_berase:	ldi	r18,0x22			;CMD

		rcall	nec2_acmd
		rcall	nec2_rack			;receive ack

		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; Program 2K block
; PAR1= start addr M
; PAR2= start addr H
;-------------------------------------------------------------------------------
nec2_bprog:	ldi	r18,0x40			;CMD

		rcall	nec2_acmd
		rcall	nec2_rack			;receive ack

nec2_bprog_1:	call	api_resetptr

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETB
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		ldi	r18,NEC2_COMM_ETX
		rcall	nec2_dblock
		rcall	nec2_rack2			;receive ack

		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; Verify 2K block
; PAR1= start addr M
; PAR2= start addr H
;-------------------------------------------------------------------------------
nec2_bvfy:	ldi	r18,0x13			;CMD

		rcall	nec2_acmd
		rcall	nec2_rack			;receive ack

		rjmp	nec2_bprog_1



nec2_acmd:	clr	r19
		NEC2_SEND	NEC2_COMM_SOH
		NEC2_SENDC	0x07			;LEN
		mov	XL,r18				;CMD
		NEC2_SENDD
		mov	XL,r17				;AH
		NEC2_SENDD
		mov	XL,r16				;AM
		NEC2_SENDD
		NEC2_SENDC	0x00			;AL
		ldi	XL,7
		add	r16,XL
		adc	r17,const_0
		mov	XL,r17				;AH
		NEC2_SENDD
		mov	XL,r16				;AM
		NEC2_SENDD
		NEC2_SENDC	0xFF			;AL
		mov	XL,r19				;CSUM
		NEC2_SENDD
		NEC2_SEND	NEC2_COMM_ETX
		ret


nec2_dblock:	NEC2_SEND	NEC2_COMM_STX
		NEC2_SEND	0x00			;LEN=256
		clr	r19				;csum
		ldi	r24,0				;bytes to do
nec2_dblock_1:	push	r24
		call	api_buf_bread
		NEC2_SENDD
		pop	r24
		dec	r24
		brne	nec2_dblock_1
		mov	XL,r19				;CSUM
		NEC2_SENDD
		mov	XL,r18				;ETX/ETB
		NEC2_SENDD
		ret

;-------------------------------------------------------------------------------
; receive ack
;-------------------------------------------------------------------------------
nec2_rack:	call	recv2_115K
		brtc	nec2_rack_e1		;timeout
;		sts	0x100,XL
		cpi	XL,0x02
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
;		sts	0x101,XL
		cpi	XL,0x01
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
;		sts	0x102,XL
		cpi	XL,0x06
		brne	nec2_rack_e2
		call	recv2_115K
;		sts	0x103,XL
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0xF9
		brne	nec2_rack_e2
		call	recv2_115K
;		sts	0x104,XL
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x03
		brne	nec2_rack_e2
nec2_rack_w1:	push	ZL
		push	ZH
		ldi	ZL,0
		ldi	ZH,5
nec2_rack_w2:	sbiw	ZL,1
		brne	nec2_rack_w2
		pop	ZH
		pop	ZL
		ret

nec2_rack_e1:	pop	r16
		pop	r16
		ldi	r16,0x45		;timeout
		jmp	main_loop

nec2_rack_e2:	pop	r16
		pop	r16
		ldi	r16,0x46		;no ack
		jmp	main_loop

nec2_rack_e3:	pop	r16
		pop	r16
		ldi	r16,0x47		;verify failed
		jmp	main_loop

nec2_rack2:	call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x02
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x02
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x06
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x06
		brne	nec2_rack_e3
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0xF2
		brne	nec2_rack_e2
		call	recv2_115K
		brtc	nec2_rack_e1		;timeout
		cpi	XL,0x03
		brne	nec2_rack_e2
		rjmp	nec2_rack_w1



nec2_wait10ms:	ldi	ZL,10
		ldi	ZH,0
		jmp	api_wait_ms
