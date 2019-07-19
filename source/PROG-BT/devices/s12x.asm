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

;-------------------------------------------------------------------------------
; exec
; ADDRL,ADDRH,ignore,ignore
;-------------------------------------------------------------------------------
s12x_active:		ldi	XL,0xd5			;background
			call	bdm_send_byte
			call	bdm_wait160
			ldi	XL,0x90			;background
			call	bdm_send_byte
			call	bdm_wait160
			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; write to RAM
;-------------------------------------------------------------------------------
s12x_wram:		call	bdm_prepare
			call	api_resetptr
			movw	r24,r18			;LEN (words)
		
			ldi	XL,0x45			;write X
			call	bdm_send_byte
			movw	XL,r16
			sbiw	XL,2			;X will be incremented before write
			call	bdm_send_word
			call	bdm_wait160

s12x_wram_1:		ldi	XL,0x42			;write next
			call	bdm_send_byte
			call	api_buf_bread		;read date byte from buffer
			mov	XH,XL
			call	api_buf_bread		;read date byte from buffer
			call	bdm_send_word
			call	bdm_wait160
			sbiw	r24,1
			brne	s12x_wram_1

			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; exec
; ADDRL,ADDRH,ignore,ignore
;-------------------------------------------------------------------------------
s12x_exec:		call	bdm_prepare

			ldi	XL,0x43			;write PC
			call	bdm_send_byte
			movw	XL,r16
			call	bdm_send_word
			call	bdm_wait160

			ldi	XL,0x08			;GO
			call	bdm_send_byte

			jmp	main_loop_ok


;-------------------------------------------------------------------------------
; exec and wait
;-------------------------------------------------------------------------------
s12x_execw:		call	bdm_prepare

			ldi	XL,0x43			;write PC
			call	bdm_send_byte
			movw	XL,r16
			call	bdm_send_word
			call	bdm_wait160

			ldi	XL,0x08			;GO
			call	bdm_send_byte

			clr	r16
			ldi	r24,0
			ldi	r25,0
s12x_execw_2:		call	bdm_status
			sbrs	XL,6
			jmp	main_loop
			ldi	XL,0
s12x_execw_3:		dec	XL
			brne	s12x_execw_3
			sbiw	r24,1
			brne	s12x_execw_2
			ldi	r16,0x03		;timeout
			jmp	main_loop
