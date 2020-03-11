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

.equ	NEC1_COMM_SOH	= 0x01
.equ	NEC1_COMM_STX	= 0x02
.equ	NEC1_COMM_ETX	= 0x03
.equ	NEC1_COMM_ETB	= 0x17

.equ	NEC1_CMD_MERASE	= 0x20
.equ	NEC1_CMD_BERASE	= 0x22
.equ	NEC1_CMD_BCHECK	= 0x32
.equ	NEC1_CMD_PROG	= 0x40
.equ	NEC1_CMD_VERIFY	= 0x13
.equ	NEC1_CMD_READID	= 0xC0
.equ	NEC1_CMD_SECURE	= 0xA0
.equ	NEC1_CMD_OSCSET	= 0x90
.equ	NEC1_CMD_RESET	= 0x00
.equ	NEC1_CMD_STATUS	= 0x70

.equ	NEC1_RESET	= SIG1
.equ	NEC1_SCK	= SIG2
.equ	NEC1_MOSI	= SIG3
.equ	NEC1_MISO	= SIG4
.equ	NEC1_FLMD0	= SIG5

;------------------------------------------------------------------------------
; INIT CSI MODE
; PAR1=number of FLMDO pulses
;------------------------------------------------------------------------------
nec1_init:		out	CTRLPORT,const_0		;alles aus
			ldi	XL,0x17				;FLMD0, NEC1_RESET, NEC1_MOSI, NEC1_SCK
			out	CTRLDDR,XL
			call	api_vcc_on			;VCC on
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,NEC1_FLMD0		;FLMD0=1
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,NEC1_RESET		;release RESET with FLMD0=1
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms

			;pulses for switching to csi mode
nec1_init_1:		cbi	CTRLPORT,NEC1_FLMD0		;FLMD0=0 (pulse start)
			ldi	ZL,0
nec1_init_2:		dec	ZL
			brne	nec1_init_2
			sbi	CTRLPORT,NEC1_FLMD0		;FLMD0=1 (pulse end)
			ldi	ZL,0
nec1_init_3:		dec	ZL
			brne	nec1_init_3
			dec	r16				;pulse counter
			brne	nec1_init_1

			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms

			rcall	nec1_send_soh			;SOH send
			ldi	XL,0x01
			rcall	nec1_sendbyte			;LEN
			ldi	XL,NEC1_CMD_RESET
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx			;ETX send

			ldi	ZL,1				;Twt0
			ldi	ZH,0
			call	wait_ms

			rcall	nec1_status
			brtc	nec1_init_err
			jmp	main_loop_ok

nec1_init_err:		ldi	r16,0x41			;timeout
			jmp	main_loop

;------------------------------------------------------------------------------
; EXIT
;------------------------------------------------------------------------------
nec1_exit:		out	CTRLPORT,const_0	;alles aus
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; MASS ERASE
; PAR1=max erase duration (x0,5s)
;------------------------------------------------------------------------------
nec1_merase:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x01
			rcall	nec1_sendbyte		;LEN
			ldi	XL,NEC1_CMD_MERASE
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden

			mov	r24,r16
nec1_merase_1:		ldi	ZL,LOW(500)
			ldi	ZH,HIGH(500)
			call	wait_ms

			rcall	nec1_status
			brts	nec1_merase_2		;OK
			dec	r24
			brne	nec1_merase_1

			ldi	r16,0x42		;erase timeout
			jmp	main_loop

nec1_merase_2:		jmp	main_loop_ok

;------------------------------------------------------------------------------
; PROGRAM
;------------------------------------------------------------------------------
nec1_prog:		ldi	r18,NEC1_CMD_PROG
			rcall	nec1_acmd1

			rcall	nec1_status
			brts	nec1_prog_1
			ldi	r16,0x44

nec1_prog_1:		ldi	YL,LOW(buffer)
			ldi	YH,HIGH(buffer)

			ldi	r16,3			;blocks
nec1_prog_2:		rcall	nec1_send_stx		;STX senden
			ldi	XL,0x00			;no of bytes
			rcall	nec1_sendbyte
			ldi	r17,0
nec1_prog_3:		ld	XL,Y+
			rcall	nec1_sendbyte
			dec	r17
			brne	nec1_prog_3
			rcall	nec1_send_csum
			rcall	nec1_send_etb		;ETB senden
			ldi	ZL,10
			ldi	ZH,0
			call	wait_ms
			rcall	nec1_status2
			brts	nec1_prog_4
			rjmp	nec1_init_err

nec1_prog_4:		dec	r16
			brne	nec1_prog_2

			rcall	nec1_send_stx		;STX senden
			ldi	XL,0x00			;no of bytes
			rcall	nec1_sendbyte
			ldi	r17,0
nec1_prog_5:		ld	XL,Y+
			rcall	nec1_sendbyte
			dec	r17
			brne	nec1_prog_5
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden
			ldi	ZL,15
			ldi	ZH,0
			call	wait_ms
			rcall	nec1_status2
			brts	nec1_prog_6
			rjmp	nec1_init_err
nec1_prog_6:		jmp	main_loop_ok

;------------------------------------------------------------------------------
; VERIFY
;------------------------------------------------------------------------------
nec1_verify:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x07
			rcall	nec1_sendbyte		;LEN
			ldi	XL,NEC1_CMD_VERIFY
			rcall	nec1_sendbyte
			mov	XL,r18			;start addr H
			rcall	nec1_sendbyte
			mov	XL,r17			;start addr M
			rcall	nec1_sendbyte
			mov	XL,r16			;start addr L
			rcall	nec1_sendbyte
			ldi	XL,0xff
			ldi	XH,0x03
			add	r16,XL
			adc	r17,XH
			adc	r18,const_0
			mov	XL,r18			;end addr H
			rcall	nec1_sendbyte
			mov	XL,r17			;end addr M
			rcall	nec1_sendbyte
			mov	XL,r16			;end addr L
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden

			rcall	nec1_status
			brts	nec1_verify_1
			rjmp	nec1_init_err

nec1_verify_1:		ldi	YL,LOW(buffer)
			ldi	YH,HIGH(buffer)

			ldi	r16,3			;blocks
nec1_verify_2:		rcall	nec1_send_stx		;STX senden
			ldi	XL,0x00			;no of bytes
			rcall	nec1_sendbyte
			ldi	r17,0
nec1_verify_3:		ld	XL,Y+
			rcall	nec1_sendbyte
			dec	r17
			brne	nec1_verify_3
			rcall	nec1_send_csum
			rcall	nec1_send_etb		;ETB senden
			ldi	ZL,10
			ldi	ZH,0
			call	wait_ms
			rcall	nec1_status2
			brts	nec1_verify_4
			rjmp	nec1_init_err

nec1_verify_4:		dec	r16
			brne	nec1_verify_2

			rcall	nec1_send_stx		;STX senden
			ldi	XL,0x00			;no of bytes
			rcall	nec1_sendbyte
			ldi	r17,0
nec1_verify_5:		ld	XL,Y+
			rcall	nec1_sendbyte
			dec	r17
			brne	nec1_verify_5
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden
			ldi	ZL,15
			ldi	ZH,0
			call	wait_ms
			rcall	nec1_status2
			brts	nec1_verify_6
			rjmp	nec1_init_err

nec1_verify_6:		jmp	main_loop_ok

;------------------------------------------------------------------------------
; SECURE
;------------------------------------------------------------------------------
nec1_secure:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x03
			rcall	nec1_sendbyte		;LEN
			ldi	XL,NEC1_CMD_SECURE
			rcall	nec1_sendbyte
			ldi	XL,0x00
			rcall	nec1_sendbyte
			ldi	XL,0x00
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden

			rcall	nec1_status
			brts	nec1_secure_1
			rjmp	nec1_init_err

nec1_secure_1:		ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x02
			rcall	nec1_sendbyte		;LEN
			ldi	XL,0xFD			;disable block erase
			rcall	nec1_sendbyte
			ldi	XL,0x03
			rcall	nec1_sendbyte
			ldi	XL,0x00
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden

			rcall	nec1_status
			brts	nec1_secure_2
			rjmp	nec1_init_err

nec1_secure_2:		ldi	ZL,15
			ldi	ZH,0
			call	wait_ms
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; start MCU
;------------------------------------------------------------------------------
nec1_run:		out	CTRLPORT,const_0	;alles aus
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,NEC1_RESET		;release RESET with FLMD0=0
			set
			jmp	main_loop_ok


nec1_acmd1:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x07
			rcall	nec1_sendbyte		;LEN
			mov	XL,r18
			rcall	nec1_sendbyte
			mov	XL,r17			;start addr H
			rcall	nec1_sendbyte
			mov	XL,r16			;start addr M
			rcall	nec1_sendbyte
			ldi	XL,0x00			;start addr L
			rcall	nec1_sendbyte
			subi	r16,0xfd		;+3
			mov	XL,r17			;end addr H
			rcall	nec1_sendbyte
			mov	XL,r16			;end addr M
			rcall	nec1_sendbyte
			ldi	XL,0xff			;end addr L
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rjmp	nec1_send_etx		;ETX senden



nec1_dblock:		rcall	nec1_send_stx		;STX senden
			ldi	XL,0x00			;no of bytes
			rcall	nec1_sendbyte
			ldi	r17,0
nec1_dblock_1:		call	api_buf_bread
			rcall	nec1_sendbyte
			dec	r17
			brne	nec1_dblock_1
			rcall	nec1_send_csum
			mov	XL,r18
			rjmp	nec1_sendbyte

;------------------------------------------------------------------------------
; status request (1 byte)
;------------------------------------------------------------------------------
nec1_status:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x01
			rcall	nec1_sendbyte		;LEN
			ldi	XL,NEC1_CMD_STATUS
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden
			ldi	ZL,100
nec1_status_1:		dec	ZL
			brne	nec1_status_1

			set				;no error

			rcall	nec1_send_zero
			ldi	XL,NEC1_COMM_STX
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0x01			;LEN
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0x06			;ACK
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0xF9			;CSUM
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,NEC1_COMM_ETX
			cpse	XL,XH
			clt				;error
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; status request (2 bytes)
;------------------------------------------------------------------------------
nec1_status2:		rcall	nec1_send_soh		;SOH senden
			ldi	XL,0x01
			rcall	nec1_sendbyte		;LEN
			ldi	XL,NEC1_CMD_STATUS
			rcall	nec1_sendbyte
			rcall	nec1_send_csum
			rcall	nec1_send_etx		;ETX senden
			ldi	ZL,100
nec1_status2_1:		dec	ZL
			brne	nec1_status2_1

			set

			rcall	nec1_send_zero
			ldi	XH,NEC1_COMM_STX
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0x02			;LEN
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0x06			;ACK
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0x06			;ACK
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,0xF2			;CSUM
			cpse	XL,XH
			clt				;error

			rcall	nec1_send_zero
			ldi	XH,NEC1_COMM_ETX
			cpse	XL,XH
			clt				;error

;###############################################################################
; some special bytes
;###############################################################################
nec1_send_zero:		clr	XL
			rjmp	nec1_sendbyte

nec1_send_soh:		ldi	XL,NEC1_COMM_SOH
			clr	r19
			rjmp	nec1_byte

nec1_send_stx:		ldi	XL,NEC1_COMM_STX
			clr	r19
			rjmp	nec1_byte

nec1_send_etx:		ldi	XL,NEC1_COMM_ETX
			rjmp	nec1_byte

nec1_send_etb:		ldi	XL,NEC1_COMM_ETB
			rjmp	nec1_byte

nec1_clear_csum:	clr	r5
			ret

nec1_send_csum:		mov	XL,r5
			rjmp	nec1_byte

;###############################################################################
; COMMUNICATION SUBROUTINE
;###############################################################################
nec1_sendbyte:		sub	r5,XL				;checksum


nec1_byte:		ldi	XH,0x08
nec1_byte_1:		cbi	CTRLPORT,NEC1_SCK		;2 SCK
			sbrc	XL,7				;1
			sbi	CTRLPORT,NEC1_MOSI		;2 data HIGH	
			sbrs	XL,7				;1
			cbi	CTRLPORT,NEC1_MOSI		;2 data LOW
			lsl	XL				;1 result
			sbic	CTRLPIN,NEC1_MISO		;1 MISO
			inc	XL				;1
			sbi	CTRLPORT,NEC1_SCK		;2 SCK
			dec	XH				;1
			brne	nec1_byte_1			;2/1
			ret

