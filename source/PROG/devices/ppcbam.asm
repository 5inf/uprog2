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

.equ		PPCBAM_RESET	= SIG1
.equ		PPCBAM_TX	= SIG3
.equ		PPCBAM_RX	= SIG2
.equ		PPCBAM_FAB	= SIG5


.macro PPCBAM_BLSEND
		call	send3_9600
.endm

.macro PPCBAM_BLRECV
		call	recv2_9600
.endm

.macro PPCBAM_BLSEND19
		call	send3_19200
.endm

.macro PPCBAM_BLRECV19
		call	recv2_19200
.endm

.macro PPCBAM_BLSEND24
		call	send3_24000
.endm

.macro PPCBAM_BLRECV24
		call	recv2_24000
.endm

.macro PPCBAM_BLSEND48
		call	send3_48000
.endm

.macro PPCBAM_BLRECV48
		call	recv2_48000
.endm

.macro PPCBAM_B2SEND
		call	send3_500k
.endm

.macro PPCBAM_B2RECV
		call	recv2_500k
.endm

.macro PPCBAM_B2RECV_LT
		call	recv2_500k_lt
.endm


;-------------------------------------------------------------------------------
; init BM
;-------------------------------------------------------------------------------
ppcbam_init:		out	CTRLPORT,const_0		;all input
			sbi	CTRLDDR,PPCBAM_TX		;TX output
			sbi	CTRLDDR,PPCBAM_RESET		;RST output
			sbi	CTRLDDR,PPCBAM_FAB		;FAB output
			call	api_vcc_on			;power on
			sbi	CTRLPORT,PPCBAM_FAB		;FAB=1
			sbi	CTRLPORT,PPCBAM_TX		;tx high
			ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			ldi	ZL,10
			clr	ZH
			call	api_wait_ms
			sbi	CTRLPORT,PPCBAM_RESET		;release reset
;			cbi	CTRLDDR,PPCBAM_RESET		;reset tristate

ppcbam_init1:		sbic	CTRLPIN,PPCBAM_RESET
			jmp	main_loop_ok
			ldi	ZL,20
			clr	ZH
			call	api_wait_ms
			rjmp	ppcbam_init1

ppcbam_exit:		out	CTRLPORT,const_0
			ldi	ZL,50
			clr	ZH
			call	api_wait_ms
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; send BL data
; PAR1 = loader select
; PAR3 = LEN low
; PAR4 = LEN high
;-------------------------------------------------------------------------------
ppcbam_send:		call	api_resetptr
			movw	r24,r18			;get num of bytes

			;9K6
ppcbam_send1:		andi	r16,7
			brne	ppcbam_send2

ppcbam_send1a:		call	api_buf_bread
			mov	r22,XL
			ldi	ZL,0
			ldi	ZH,8
ppc_wx1:		sbiw	ZL,1
			brne	ppc_wx1
			PPCBAM_BLSEND
			clr	XL
			PPCBAM_BLRECV
			ldi	r16,0x43		;error timeout
			brtc	ppcbam_err1		;timeout
			ldi	r16,0x44		;error wrong echo
			cp	XL,r22
			brne	ppcbam_err1
			sbiw	r24,1
			brne	ppcbam_send1a
			jmp	main_loop_ok

ppcbam_err1:		jmp	main_loop

			;19K2
ppcbam_send2:		cpi	r16,1
			brne	ppcbam_send3

ppcbam_send2a:		call	api_buf_bread
			mov	r22,XL
			ldi	ZL,0
			ldi	ZH,2
ppc_wx2:		sbiw	ZL,1
			brne	ppc_wx2
			PPCBAM_BLSEND19
			clr	XL
			PPCBAM_BLRECV19
			ldi	r16,0x43		;error timeout
			brtc	ppcbam_err2		;timeout
			ldi	r16,0x44		;error wrong echo
			cp	XL,r22
			brne	ppcbam_err2			
			sbiw	r24,1
			brne	ppcbam_send2a
			jmp	main_loop_ok

ppcbam_err2:		jmp	main_loop


			;24K
ppcbam_send3:		cpi	r16,2
			brne	ppcbam_send4

ppcbam_send3a:		call	api_buf_bread
			mov	r22,XL
			ldi	ZL,0
			ldi	ZH,2
ppc_wx3:		sbiw	ZL,1
			brne	ppc_wx3
			PPCBAM_BLSEND24
			clr	XL
			PPCBAM_BLRECV24
			ldi	r16,0x43		;error timeout
			brtc	ppcbam_err3		;timeout
			ldi	r16,0x44		;error wrong echo
			cp	XL,r22
			brne	ppcbam_err3			
			sbiw	r24,1
			brne	ppcbam_send3a
			jmp	main_loop_ok

ppcbam_err3:		jmp	main_loop

			;48K
ppcbam_send4:		cpi	r16,3
			brne	ppcbam_send4

ppcbam_send4a:		call	api_buf_bread
			mov	r22,XL
			ldi	ZL,0
			ldi	ZH,2
ppc_wx4:		sbiw	ZL,1
			brne	ppc_wx4
			PPCBAM_BLSEND48
			clr	XL
			PPCBAM_BLRECV48
			ldi	r16,0x43		;error timeout
			brtc	ppcbam_err4		;timeout
			ldi	r16,0x44		;error wrong echo
			cp	XL,r22
			brne	ppcbam_err4			
			sbiw	r24,1
			brne	ppcbam_send4a
			jmp	main_loop_ok

ppcbam_err4:		jmp	main_loop


;-------------------------------------------------------------------------------
; read 2K data
;-------------------------------------------------------------------------------
ppcbam_read:		ldi	XL,0x51			;read
			rcall	ppcbam_sendh		;send header (address)

			ldi	r24,0
			ldi	r25,8

ppcbam_read_1:		PPCBAM_B2RECV
			call	api_buf_bwrite
			sbiw	r24,1
			brne	ppcbam_read_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; cflash program 2K data
;-------------------------------------------------------------------------------
ppcbam_cprog:		ldi	XL,0x52			;prog cflash
ppcbam_cprog_0:		rcall	ppcbam_sendh		;send header (address)

			ldi	r24,0
			ldi	r25,8

ppcbam_cprog_1:		call	api_buf_bread
			PPCBAM_B2SEND
			sbiw	r24,1
			brne	ppcbam_cprog_1
			rjmp	ppcbam_wait_result

;-------------------------------------------------------------------------------
; data flash program 2K data
;-------------------------------------------------------------------------------
ppcbam_dprog:		ldi	XL,0x62			;prog dflash
			rjmp	ppcbam_cprog_0

;-------------------------------------------------------------------------------
; shadow flash program 2K data
;-------------------------------------------------------------------------------
ppcbam_sprog:		ldi	XL,0x72			;prog dflash
			rjmp	ppcbam_cprog_0

;-------------------------------------------------------------------------------
; cflash erase
;-------------------------------------------------------------------------------
ppcbam_cerase:		ldi	XL,0x53			;erase
			PPCBAM_B2SEND			;send

ppcbam_wait_result:	PPCBAM_B2RECV_LT		;receive result
			ldi	r16,0x45		;timeout errcode
			brtc	ppcbam_wait_result_to	;branch if timed out
			mov	r16,XL			;get result code
ppcbam_wait_result_to:	jmp	main_loop		;end

;-------------------------------------------------------------------------------
; dflash erase
;-------------------------------------------------------------------------------
ppcbam_derase:		ldi	XL,0x63			;dflash erase
			PPCBAM_B2SEND			;send
			rjmp	ppcbam_wait_result

;-------------------------------------------------------------------------------
; shadow erase
;-------------------------------------------------------------------------------
ppcbam_serase:		ldi	XL,0x73			;erase
			PPCBAM_B2SEND			;send
			rjmp	ppcbam_wait_result


;-------------------------------------------------------------------------------
; send header
;-------------------------------------------------------------------------------
ppcbam_sendh:		PPCBAM_B2SEND
			mov	XL,r16
			PPCBAM_B2SEND
			mov	XL,r17
			PPCBAM_B2SEND
			mov	XL,r18
			PPCBAM_B2SEND
			mov	XL,r19
			PPCBAM_B2SEND
			jmp	api_resetptr

