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


;-------------------------------------------------------------
; serial communication 9K6
;-------------------------------------------------------------
sercomm1:	movw	r24,YL			;send length
		andi	r25,0x03		;limit to 1K
		call	api_resetptr
		adiw	r24,1
		;send
sercomm1_1:	sbiw	r24,1
		breq	sercomm1_2
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
		call	api_buf_bread		;get char
		rcall	send3_9600
		rjmp	sercomm1_1
		;receive
sercomm1_2:	call	api_resetptr
		in	r24,GPIOR1
		in	r25,GPIOR2
		andi	r25,0x03		;limit to 1K
		adiw	r24,1

sercomm1_3:	sbiw	r24,1
		breq	sercomm1_4
		rcall	recv4_9600
		brtc	sercomm1_e
		call	api_buf_bwrite
		rjmp	sercomm1_3

sercomm1_4:	jmp	main_loop_ok

sercomm1_e:	ldi	r16,0x91		;timeout
		jmp	main_loop


;-------------------------------------------------------------
; serial communication 38K4
;-------------------------------------------------------------
sercomm2:	movw	r24,YL			;send length
		andi	r25,0x03		;limit to 1K
		call	api_resetptr
		adiw	r24,1
		;send
sercomm2_1:	sbiw	r24,1
		breq	sercomm2_2
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
		call	api_buf_bread		;get char
		rcall	send3_38400
		rjmp	sercomm2_1
		;receive
sercomm2_2:	call	api_resetptr
		in	r24,GPIOR1
		in	r25,GPIOR2
		andi	r25,0x03		;limit to 1K
		adiw	r24,1

sercomm2_3:	sbiw	r24,1
		breq	sercomm2_4
		rcall	recv4_38400
		brtc	sercomm2_e
		call	api_buf_bwrite
		rjmp	sercomm2_3

sercomm2_4:	jmp	main_loop_ok

sercomm2_e:	ldi	r16,0x91		;timeout
		jmp	main_loop

;-------------------------------------------------------------
; serial communication 115K
;-------------------------------------------------------------
sercomm3:	movw	r24,YL			;send length
		andi	r25,0x07		;limit to 2K
		call	api_resetptr
		adiw	r24,1
		;send
sercomm3_1:	sbiw	r24,1
		breq	sercomm3_2
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
		call	api_buf_bread		;get char
		rcall	send3_115k
		rjmp	sercomm3_1
		;receive
sercomm3_2:	call	api_resetptr
		in	r24,GPIOR1
		in	r25,GPIOR2
		andi	r25,0x07		;limit to 2K
		adiw	r24,1

sercomm3_3:	sbiw	r24,1
		breq	sercomm3_4
		rcall	recv4_115k
		brtc	sercomm3_e
		call	api_buf_bwrite
		rjmp	sercomm3_3

sercomm3_4:	jmp	main_loop_ok

sercomm3_e:	ldi	r16,0x91		;timeout
		jmp	main_loop

;-------------------------------------------------------------
; serial communication 500k
;-------------------------------------------------------------
sercomm4:	movw	r24,YL			;send length
		andi	r25,0x03		;limit to 1K
		call	api_resetptr
		adiw	r24,1
		;send
sercomm4_1:	sbiw	r24,1
		breq	sercomm4_2
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
		call	api_buf_bread		;get char
		rcall	send3_500k
		rjmp	sercomm4_1
		;receive
sercomm4_2:	call	api_resetptr
		in	r24,GPIOR1
		in	r25,GPIOR2
		andi	r25,0x03		;limit to 1K
		adiw	r24,1

sercomm4_3:	sbiw	r24,1
		breq	sercomm4_4
		rcall	recv4_500k
		ldi	ZL,3			;9
sercomm4_5:	dec	ZL
		brne	sercomm4_5
		brtc	sercomm4_e
		call	api_buf_bwrite
		rjmp	sercomm4_3

sercomm4_4:	jmp	main_loop_ok

sercomm4_e:	ldi	r16,0x91		;timeout
		jmp	main_loop

