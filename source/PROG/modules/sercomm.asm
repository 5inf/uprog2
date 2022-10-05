;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2021 Joerg Wolfram (joerg@jcwolfram.de)			#
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
; PAR 1/2 TXLEN (0= skip)
; PAR 3/3 RXLEN (0= skip)
;-------------------------------------------------------------
sercomm9600:		call	api_resetptr
			movw	r24,r16			;send length
			adiw	r24,1

			;send
sercomm9600_1:		sbiw	r24,1
			breq	sercomm9600_2
			call	api_buf_bread		;get char
			rcall	send3_9600
			rjmp	sercomm9600_1

sercomm9600_2:		call	api_resetptr
			movw	r24,r18			;recv length
			adiw	r24,1

			;receive
sercomm9600_3:		sbiw	r24,1
			breq	sercomm9600_4
			rcall	recv4_9600
			brtc	sercomm9600_e
			call	api_buf_bwrite
			rjmp	sercomm9600_3

sercomm9600_4:		jmp	main_loop_ok

sercomm9600_e:		ldi	r16,0x41		;timeout
			jmp	main_loop


;-------------------------------------------------------------
; serial communication 38K4
; PAR 1/2 TXLEN (0= skip)
; PAR 3/3 RXLEN (0= skip)
;-------------------------------------------------------------
sercomm38k4:		call	api_resetptr
			movw	r24,r16			;send length
			adiw	r24,1

			;send
sercomm38k4_1:		sbiw	r24,1
			breq	sercomm38k4_2
			call	api_buf_bread		;get char
			rcall	send3_38400
			rjmp	sercomm38k4_1

sercomm38k4_2:		call	api_resetptr
			movw	r24,r18			;recv length
			adiw	r24,1

			;receive
sercomm38k4_3:		sbiw	r24,1
			breq	sercomm38k4_4
			rcall	recv4_38400
			brtc	sercomm38k4_e
			call	api_buf_bwrite
			rjmp	sercomm38k4_3

sercomm38k4_4:		jmp	main_loop_ok

sercomm38k4_e:		ldi	r16,0x41		;timeout
			jmp	main_loop

;-------------------------------------------------------------
; serial communication 115K
; PAR 1/2 TXLEN (0= skip)
; PAR 3/3 RXLEN (0= skip)
;-------------------------------------------------------------
sercomm115k:		call	api_resetptr
			movw	r24,r16			;send length
			adiw	r24,1

			;send
sercomm115k_1:		sbiw	r24,1
			breq	sercomm115k_2
			call	api_buf_bread		;get char
			rcall	send3_115k
			rjmp	sercomm115k_1

sercomm115k_2:		call	api_resetptr
			movw	r24,r18			;recv length
			adiw	r24,1

			;receive
sercomm115k_3:		sbiw	r24,1
			breq	sercomm115k_4
			rcall	recv4_115k
			brtc	sercomm115k_e
			call	api_buf_bwrite
			rjmp	sercomm115k_3

sercomm115k_4:		jmp	main_loop_ok

sercomm115k_e:		ldi	r16,0x41		;timeout
			jmp	main_loop

;-------------------------------------------------------------
; serial communication 500k
; PAR 1/2 TXLEN (0= skip)
; PAR 3/3 RXLEN (0= skip)
;-------------------------------------------------------------
sercomm500k:		call	api_resetptr
			movw	r24,r16			;send length
			adiw	r24,1

			;send
sercomm500k_1:		sbiw	r24,1
			breq	sercomm500k_2
			call	api_buf_bread		;get char
			rcall	send3_500k
			rjmp	sercomm500k_1

sercomm500k_2:		call	api_resetptr
			movw	r24,r18			;recv length
			adiw	r24,1

			;receive
sercomm500k_3:		sbiw	r24,1
			breq	sercomm500k_4
			rcall	recv4_500k
			brtc	sercomm500k_e
			call	api_buf_bwrite
			rjmp	sercomm500k_3

sercomm500k_4:		jmp	main_loop_ok

sercomm500k_e:		ldi	r16,0x41		;timeout
			jmp	main_loop

