;################################################################################
;#										#
;# UPROG2 universal programmer							#
;# EEPROM/Flash memory interface						#
;# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public License			#
;# as published by the Free Software Foundation; either version 3		#
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

mem_spm:		in	r16,SPMCSR
			sbrc	r16,0
			rjmp	mem_spm
mem_spm1:		out	SPMCSR,XH
			spm
			ret
mem_spm2:		in	r16,SPMCSR
			sbrc	r16,0
			rjmp	mem_spm2
			ret

mem_waitrww:		in	r16,SPMCSR
			sbrs	r16,6
			ret
			ldi	XH,0x11
			rcall	mem_spm
			rjmp	mem_waitrww

;------------------------------------------------------------------------------
; save a block to Flash (r16)
;------------------------------------------------------------------------------
mem_wblock:		movw	ZL,r16			;startaddr = par 1
			cpi	ZH,124			;maximum page 
			brcs	mem_wpage
			jmp	main_loop_ok

mem_wpage:		lsl	ZL
			rol	ZH
			lds	r20,txlen_h		;pages to do
			clr	YL			;reset buffer pointer
			clr	YH

mem_wpageb:		ldi	XH,0x03			;page erase
			rcall	mem_spm
			rcall	mem_waitrww

			ldi	r21,0x80		;no. of words to copy
mem_wpage1:		rcall	buf_read
			mov	r0,XL
			rcall	buf_read
			mov	r1,XL
			ldi	XH,0x01			;write to buffer
			rcall	mem_spm
			adiw	ZL,2
			dec	r21
			brne	mem_wpage1
			sbiw	ZL,2

			ldi	XH,0x05			;page write
			rcall	mem_spm
mem_wpage2:		rcall	mem_waitrww
			adiw	ZL,2
			dec	r20
			brne	mem_wpageb

			ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms

			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read one byte (XL) from EEPROM memory (Y)
;------------------------------------------------------------------------------
eeprom_read:		sbic	EECR,EEPE
			rjmp	eeprom_read
			out	EEARH,YH
			out	EEARL,YL
			sbi	EECR,EERE
			in	XL,EEDR
			ret				;thats all

;------------------------------------------------------------------------------
; write one byte (XL) to EEPROM memory (Y)
;------------------------------------------------------------------------------
eeprom_write:		sbic	EECR,EEPE		;wait for EEPROM ready
			rjmp	eeprom_write
			out	EEARH,YH
			out	EEARL,YL
			sbi	EECR,EERE
			in	r0,EEDR
			cp	r0,XL
			brne	eeprom_write3
			ret				;no modify necessary

eeprom_write3:		out	EEDR,XL			;write byte
			cli
			sbi	EECR,EEMPE
			sbi	EECR,EEPE
			sei
			ret

