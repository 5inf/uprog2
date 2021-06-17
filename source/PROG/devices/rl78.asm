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

.equ	rl78_COMM_SOH	= 0x01
.equ	rl78_COMM_STX	= 0x02
.equ	rl78_COMM_ETX	= 0x03
.equ	rl78_COMM_ETB	= 0x17

.equ	rl78_CMD_MERASE	= 0x20
.equ	rl78_CMD_BERASE	= 0x22
.equ	rl78_CMD_BCHECK	= 0x32
.equ	rl78_CMD_PROG	= 0x40
.equ	rl78_CMD_VERIFY	= 0x13
.equ	rl78_CMD_READID	= 0xC0
.equ	rl78_CMD_SECURE	= 0xA0
.equ	rl78_CMD_OSCSET	= 0x90
.equ	rl78_CMD_RESET	= 0x00
.equ	rl78_CMD_STATUS	= 0x70
.equ	rl78_CMD_CSUM	= 0xB0

.equ	rl78_TOOL0	= SIG2
.equ	rl78_RST	= SIG1
.equ	rl78_OUTMASK	= SIG2_OR | SIG1_OR | SIG4_OR


;------------------------------------------------------------------------------
; some macros
;------------------------------------------------------------------------------
.macro	rl78_SENDS
	ldi	XL,@0
	call	send2_9600
.endm

.macro	rl78_SEND
	ldi	XL,@0
	call	send2_115K
.endm

.macro	rl78_SENDC
	ldi	XL,@0
	sub	r19,XL
	call	send2_115K
.endm

.macro	rl78_SENDCSUM
	mov	XL,r19
	call	send2_115K
.endm

.macro	rl78_SENDD
	sub	r19,XL
	call	send2_115K
.endm

.macro	rl78_SEND25
	ldi	XL,@0
	call	send2_500k
	rcall	rl78_xgap
.endm

.macro	rl78_SEND25L
	ldi	XL,@0
	call	send2l_500k
.endm

.macro	rl78_SEND25C
	ldi	XL,@0
	sub	r19,XL
	call	send2_500k
	rcall	rl78_xgap
.endm

.macro	rl78_SEND25CSUM
	mov	XL,r19
	call	send2_500k
	rcall	rl78_xgap
.endm

.macro	rl78_SEND25D
	sub	r19,XL
	call	send2_500k
	rcall	rl78_xgap
.endm

;------------------------------------------------------------------------------
; INIT RL78
;------------------------------------------------------------------------------
rl78_init_err1:	ldi	r16,0x41			;timeout at sync
			jmp	main_loop

rl78_init_err2:	ldi	r16,0x42			;wrong sync
			jmp	main_loop


rl78_init:		ldi	XL,rl78_OUTMASK
			out	CTRLPORT,const_0	;alles aus
			out	CTRLDDR,XL

			call	api_vcc_on

			rcall	rl78_wait10ms

			sbi	CTRLPORT,rl78_RST		;RESET=1

			rcall	rl78_wait10ms

			sbi	CTRLPORT,rl78_TOOL0		;TOOL0=1

			rcall	rl78_wait10ms

			rl78_SEND	0x3a			;single wire mode

			rcall	rl78_wait10ms

			;BAUD RATE SETTING
			clr		r19			;clear CSUM
			rl78_SEND	rl78_COMM_SOH
			rl78_SENDC	0x03			;LEN
			rl78_SENDC	0x9A			;CMD

			rl78_SENDC	0x02			;D01 (500k)
			rl78_SENDC	0x20			;D02 (3,2V)
			rl78_SENDCSUM				;CSUM
			rl78_SEND	rl78_COMM_ETX
			cbi	CTRLDDR,rl78_TOOL0		;TOOL0=INPUT

			ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms

			;RESET
			clr		r19			;clear CSUM
			rl78_SEND25	rl78_COMM_SOH
			rl78_SEND25C	0x01			;LEN
			rl78_SEND25C	0x00			;CMD
			rl78_SEND25CSUM			;CSUM
			rl78_SEND25L	rl78_COMM_ETX

			rcall	rl78_rack			;receive ack

			jmp	main_loop_ok

rl78_init_err3:	ldi	r16,0x43			;timeout
			jmp	main_loop

rl78_init_err4:	ldi	r16,0x44			;wrong answer
			jmp	main_loop


rl78_exit:		out	CTRLPORT,const_0	;alles aus
			rcall	rl78_wait10ms
			call	api_vcc_off
			rcall	rl78_wait10ms
			out	CTRLDDR,const_0
			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; blocks ERASE
;-------------------------------------------------------------------------------
rl78_erase:	
rl78_erase_1:	clr	r19				;clear csum
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x04			;LEN
		rl78_SEND25C	0x22			;CMD (block erase)
		rl78_SEND25C	0x00			;AL
		mov	XL,r16				;AH
		rl78_SEND25D
		mov	XL,r17				;AM
		rl78_SEND25D
		rl78_SEND25CSUM
		rl78_SEND25L	rl78_COMM_ETX

		rcall	rl78_rack			;receive ack

		ldi	r19,4
		add	r16,r19
		adc	r17,const_0
		dec	r18
		brne	rl78_erase_1

		sts	0x100,const_1
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; checksum
; r16/r17	start_addr >> 8
; r18/r19	end_addr >> 8
;-------------------------------------------------------------------------------
rl78_csum:	movw	r24,r18				;save this
		sbiw	r24,1
		clr	r19				;clear csum
		rl78_SEND25	rl78_COMM_SOH		;SOH
		rl78_SEND25C	0x07			;LEN
		rl78_SEND25C	rl78_CMD_CSUM		;CMD (checksum)
		
		rl78_SEND25C	0x00			;SAL
		mov	XL,r16				;SAM
		rl78_SEND25D
		mov	XL,r17				;SAH
		rl78_SEND25D

		rl78_SEND25C	0xFF			;EAL
		mov	XL,r24				;EAM
		rl78_SEND25D
		mov	XL,r25				;EAH
		rl78_SEND25D
				
		rl78_SEND25CSUM				;CSUM
		rl78_SEND25L	rl78_COMM_ETX		;ETX

		rcall	rl78_rack			;receive ack

		ldi	YL,2				;data from 0x102
		ldi	YH,1
		ldi	r24,6

rl78_csum_1:	call	recv2_500k
		brtc	rl78_csum_err		;timeout
		st	Y+,XL
		dec	r24
		brne	rl78_csum_1
		jmp	main_loop_ok

rl78_csum_err:	ldi	r16,0x48
		jmp	main_loop

;-------------------------------------------------------------------------------
; release security
;-------------------------------------------------------------------------------
rl78_secrel:	clr	r19				;clear csum
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x01			;LEN
		rl78_SEND25C	0xA2			;CMD (release security)
		rl78_SEND25CSUM
		rl78_SEND25L	rl78_COMM_ETX

		rcall	rl78_rack			;receive ack

		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read silicon signature
;-------------------------------------------------------------------------------
rl78_readsig:	clr	r19				;clear csum
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x01			;LEN
		rl78_SEND25C	0xC0			;CMD (read silicon signature)
		rl78_SEND25CSUM
		rl78_SEND25L	rl78_COMM_ETX

		call	api_resetptr
		ldi	r19,31
		clr	r16
rl78_rsig_1:	call	recv2_500k
		brts	rl78_rsig_2		;no timeout
		ldi	r16,0x48		;timeout
rl78_rsig_2:	call	api_buf_bwrite
		dec	r19
		brne	rl78_rsig_1
		jmp	main_loop


;-------------------------------------------------------------------------------
; Program 2K block
; PAR1= start addr M
; PAR2= start addr H
;-------------------------------------------------------------------------------
rl78_bprog:	call	api_resetptr
		ldi	r18,0x40			;CMD
		rcall	rl78_acmd
		rcall	rl78_rack			;receive ack
		rcall	rl78_wait1ms
		ldi	r23,8				;blocks to do

rl78_bprog_1:	rcall	rl78_wait1ms
		rcall	rl78_dblock
		rcall	rl78_rack2			;receive ack

		dec	r23
		brne	rl78_bprog_1

		rcall	rl78_rack			;receive ack

		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; Blank check 2K block
; PAR1= start addr M
; PAR2= start addr H
;-------------------------------------------------------------------------------
rl78_bcheck:	ldi	r18,0x32			;CMD
		clr	r24				;only this block
		rcall	rl78_acmd2
		rcall	rl78_rack			;receive ack
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; get security
;-------------------------------------------------------------------------------
rl78_getsec:	clr	r19
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x01			;LEN
		rl78_SEND25C	0xA1			;CMD
		rl78_SEND25CSUM
		ldi	XL,rl78_COMM_ETX
		call	send2l_500k

		call	api_resetptr
		ldi	r19,17
		clr	r16
rl78_gsec_1:	call	recv2_500k
		brts	rl78_gsec_2		;no timeout
		ldi	r16,0x48		;timeout
rl78_gsec_2:	call	api_buf_bwrite
		dec	r19
		brne	rl78_gsec_1
		jmp	main_loop


;-------------------------------------------------------------------------------
; Verify 2K block
; PAR1= start addr M
; PAR2= start addr H
;-------------------------------------------------------------------------------
rl78_bvfy:	call	api_resetptr
		ldi	r18,0x13			;CMD
		rcall	rl78_acmd
		rcall	rl78_rack			;receive ack
		rcall	rl78_wait1ms
		ldi	r23,8				;blocks to do

rl78_bvfy_1:	sbi	CTRLPORT,SIG4
		rcall	rl78_dblock
		cbi	CTRLPORT,SIG4
		rcall	rl78_rack2			;receive ack

		rcall	rl78_wait1ms

		dec	r23
		brne	rl78_bvfy_1

		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; send r/w command for 1K block
; R18=CMD
;-------------------------------------------------------------------------------
rl78_acmd:	clr	r19
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x07			;LEN
		mov	XL,r18				;CMD
		rl78_SEND25D
		rl78_SEND25C	0x00			;AL
		mov	XL,r16				;AM
		rl78_SEND25D
		mov	XL,r17				;AH
		rl78_SEND25D
		subi	r16,0xf9
		rl78_SEND25C	0xFF			;AL
		mov	XL,r16				;AM
		rl78_SEND25D
		mov	XL,r17				;AH
		rl78_SEND25D
rl78_acmd_1:	rl78_SEND25CSUM
		ldi	XL,rl78_COMM_ETX
		jmp	send2l_500k


rl78_acmd2:	clr	r19
		rl78_SEND25	rl78_COMM_SOH
		rl78_SEND25C	0x08			;LEN
		mov	XL,r18				;CMD
		rl78_SEND25D
		rl78_SEND25C	0x00			;AL
		mov	XL,r16				;AM
		rl78_SEND25D
		mov	XL,r17				;AH
		rl78_SEND25D
		subi	r16,0xf9
		rl78_SEND25C	0xFF			;AL
		mov	XL,r16				;AM
		rl78_SEND25D
		mov	XL,r17				;AH
		rl78_SEND25D
		mov	XL,r24				;D01
		rl78_SEND25D
		rjmp	rl78_acmd_1

;-------------------------------------------------------------------------------
; send data block
; R18=ETB/ETX
;-------------------------------------------------------------------------------
rl78_dblock:	rl78_SEND25	rl78_COMM_STX
		rl78_SEND25	0x00			;LEN=256
		clr	r19				;csum
		ldi	r24,0				;bytes to do
rl78_dblock_1:	call	api_buf_bread
		rl78_SEND25D
		dec	r24
		brne	rl78_dblock_1
		rl78_SEND25CSUM
		cpi	r23,0x01			;last block?
		breq	rl78_dblock_2
		ldi	XL,rl78_COMM_ETB
		jmp	send2l_500k
rl78_dblock_2:	ldi	XL,rl78_COMM_ETX
		jmp	send2l_500k


;-------------------------------------------------------------------------------
; send data block
; R18=ETB/ETX
;-------------------------------------------------------------------------------
rl78_dblock2:	rl78_SEND25	rl78_COMM_STX
		clr	r19				;csum
		ldi	XL,0x90
		rl78_SEND25D				;LEN=144
		ldi	r24,0x90			;bytes to do
rl78_dblck2_1:	call	api_buf_bread
		rl78_SEND25D
		dec	r24
		brne	rl78_dblck2_1
		rl78_SEND25CSUM
		cpi	r23,0x01			;last block?
		breq	rl78_dblck2_2
		ldi	XL,rl78_COMM_ETB
		jmp	send2l_500k
rl78_dblck2_2:	ldi	XL,rl78_COMM_ETX
		jmp	send2l_500k


;-------------------------------------------------------------------------------
; receive ack (cmd frame)
;-------------------------------------------------------------------------------
rl78_rack:	ldi	XL,0xFF
		sts	0xc00,XL
		sts	0xc01,XL
		sts	0xc02,XL
		sts	0xc03,XL
		sts	0xc04,XL
		cbi	GPIOR0,0		;no error
		
		call	recv2_500k
		brtc	rl78_rack_e1		;timeout
		sts	0xc00,XL		;STX -> data[2], if fails
		ldi	XH,0x02
		cpse	XH,XL
		sbi	GPIOR0,0		;compare error

		call	recv2_500k
		brtc	rl78_rack_e1		;timeout
		sts	0xc01,XL		;LEN -> data[3], if fails
		ldi	XH,0x01
		cpse	XH,XL
		sbi	GPIOR0,0		;compare error

		call	recv2_500k
		brtc	rl78_rack_e1		;timeout
		sts	0xc02,XL		;ACK -> data[4], if fails
		ldi	XH,0x06
		cpse	XH,XL
		sbi	GPIOR0,0		;compare error

		call	recv2_500k
		brtc	rl78_rack_e1		;timeout
		sts	0xc03,XL		;CSUM -> data[5], if fails
		ldi	XH,0xF9
		cpse	XH,XL
		sbi	GPIOR0,0		;compare error

		call	recv2_500k
		brtc	rl78_rack_e1		;timeout
		sts	0xc04,XL		;ETX -> data[6], if fails
		ldi	XH,0x03
		cpse	XH,XL
		sbi	GPIOR0,0		;compare error

		sbic	GPIOR0,0
		rjmp	rl78_rack_e2
		
rl78_rack_w1:	push	ZL
		push	ZH
		ldi	ZL,0
		ldi	ZH,5
rl78_rack_w2:	sbiw	ZL,1
		brne	rl78_rack_w2
		pop	ZH
		pop	ZL
		ret

rl78_rack_e1:	rcall	rl78_copyres
		pop	r16
		pop	r16
		ldi	r16,0x45		;timeout cmd
		jmp	main_loop

rl78_rack_e2:	rcall	rl78_copyres
		pop	r16
		pop	r16
		ldi	r16,0x46		;no ack cmd
		jmp	main_loop

rl78_rack_e1d:	pop	r16
		pop	r16
		ldi	r16,0x48		;timeout data
		jmp	main_loop

rl78_rack_e2d:	pop	r16
		pop	r16
		ldi	r16,0x49		;no ack data
		jmp	main_loop

rl78_rack_e3:	pop	r16
		pop	r16
		ldi	r16,0x47		;verify failed
		jmp	main_loop

;-------------------------------------------------------------------------------
; receive ack (data frame)
;-------------------------------------------------------------------------------
rl78_rack2:	call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x102,XL
		cpi	XL,0x02
		brne	rl78_rack_e2d
		call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x103,XL
		cpi	XL,0x02
		brne	rl78_rack_e2d
		call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x104,XL
		cpi	XL,0x06
		brne	rl78_rack_e2d
		call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x105,XL
		cpi	XL,0x06
		brne	rl78_rack_e3
		call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x106,XL
		cpi	XL,0xF2
		brne	rl78_rack_e2d
		call	recv2_500k
		brtc	rl78_rack_e1d		;timeout
		sts	0x107,XL
		cpi	XL,0x03
		brne	rl78_rack_e2d
		rjmp	rl78_rack_w1

;-------------------------------------------------------------------------------
; some timing subroutines
;-------------------------------------------------------------------------------
rl78_wait10ms:	ldi	ZL,10
		ldi	ZH,0
		jmp	api_wait_ms

rl78_wait5ms:	ldi	ZL,5
		ldi	ZH,0
		jmp	api_wait_ms

rl78_wait1ms:	ldi	ZL,1
		ldi	ZH,0
		jmp	api_wait_ms

rl78_fill:	call	api_resetptr
rl78_fill_1:	movw	XL,YL
		call	api_buf_mwrite
		cpi	YH,4
		brne	rl78_fill_1
		ret

rl78_fill1:	call	api_resetptr
rl78_fill1_1:	movw	XL,YL
		call	api_buf_mwrite
		cpi	YH,4
		brne	rl78_fill1_1
		ret

		; copy result to data[2]...data[6] 
rl78_copyres:	lds	XL,0xc00
		sts	0x102,XL
		lds	XL,0xc01
		sts	0x103,XL
		lds	XL,0xc02
		sts	0x104,XL
		lds	XL,0xc03
		sts	0x105,XL
		lds	XL,0xc04
		sts	0x106,XL
		ret

rl78_xgap:	ldi	r21,40
rl78_xgap_1:	dec	r21
		brne	rl78_xgap_1
		ret
				
				
;-------------------------------------------------------------------------------
; receive dump
;-------------------------------------------------------------------------------
rl78_gdump:	call	api_resetptr
		ldi	XL,0
		ldi	r24,0
		ldi	r25,8
		call	send2_38400s
rl78_gdump_1:	call	recv2_38400
		call	api_buf_bwrite
		sbiw	r24,1
		brne	rl78_gdump_1
		jmp	main_loop_ok
		
		

