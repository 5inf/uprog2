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

.equ		AT8252RST	= SIG1
.equ		AT8252SCK	= SIG2
.equ		AT8252MOSI	= SIG3
.equ		AT8252MISO	= SIG4

;------------------------------------------------------------------------------
; fast init
;------------------------------------------------------------------------------
at8252_init:		cbi	CTRLPORT,AT8252SCK
			sbi	CTRLDDR,AT8252SCK

			cbi	CTRLPORT,AT8252MOSI
			sbi	CTRLDDR,AT8252MOSI

			cbi	CTRLPORT,AT8252RST	;-> RESET
			sbi	CTRLDDR,AT8252RST
			
			call	api_vcc_on
			ldi	ZL,20			;50ms
			clr	ZH
			call	wait_ms

			sbi	CTRLPORT,AT8252RST	;-> release RESET

			ldi	ZL,20			;50ms
			clr	ZH
			call	wait_ms

			ldi	XL,0xac			;PRG entry
			rcall	at8252_spi

			ldi	XL,0x53
			rcall	at8252_spi

			ldi	XL,0x00
			rcall	at8252_spi
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; mass erase
;------------------------------------------------------------------------------
at8252_cerase:		ldi	XL,0xac
			rcall	at8252_spi
			ldi	XL,0x04
			rcall	at8252_spi
			rcall	at8252_spiz
			
			ldi	ZL,20			;20ms
			clr	ZH
			call	wait_ms

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; prog flash bytes
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3/P4 = number of bytes
;------------------------------------------------------------------------------
at8252_fprog:		call	api_resetptr
			movw	r24,r18
						
at8252_fprog_1:		mov	XL,r17			;addr HI
			lsl	XL
			lsl	XL
			lsl	XL
			ori	XL,0x02
			rcall	at8252_spi

			mov	XL,r16			;addr LOW
			rcall	at8252_spi
			
			call	api_buf_bread		;get next byte from buffer
			rcall	at8252_spi

			ldi	ZL,3			;>2.5ms
			clr	ZH
			call	wait_ms
			
			add	r16,const_1		;inc addr
			adc	r17,const_0

			sbiw	r24,1			;byte counter
			brne	at8252_fprog_1		;loop
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read nn bytes to buffer
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = NUM LOW
; P4 = NUM HIGH
;------------------------------------------------------------------------------
at8252_fread:		movw	r24,r18
			call	api_resetptr

at8252_fread_1:		mov	XL,r17			;addr HI
			lsl	XL
			lsl	XL
			lsl	XL
			ori	XL,0x01
			rcall	at8252_spi

			mov	XL,r16			;addr LOW
			rcall	at8252_spi

			rcall	at8252_spiz
			call	api_buf_bwrite		;write to buffer

			add	r16,const_1		;inc addr
			adc	r17,const_0

			sbiw	r24,1			;byte counter
			brne	at8252_fread_1		;loop
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; prog EEPROM
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3/P4 = number of pages to program
;------------------------------------------------------------------------------
at8252_eprog:		call	api_resetptr
			movw	r24,r18
						
at8252_eprog_1:		mov	XL,r17			;addr HI
			lsl	XL
			lsl	XL
			lsl	XL
			ori	XL,0x06
			rcall	at8252_spi

			mov	XL,r16			;addr LOW
			rcall	at8252_spi
			
			call	api_buf_bread		;get next byte from buffer
			rcall	at8252_spi

			ldi	ZL,3			;>2.5ms
			clr	ZH
			call	wait_ms
			
			add	r16,const_1		;inc addr
			adc	r17,const_0

			sbiw	r24,1			;byte counter
			brne	at8252_eprog_1		;loop
			
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read n bytes EEPROM
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = num LOW
; P4 = num HIGH
;------------------------------------------------------------------------------
at8252_eread:		movw	r24,r18
			call	api_resetptr

at8252_eread_1:		mov	XL,r17			;addr HI
			lsl	XL
			lsl	XL
			lsl	XL
			ori	XL,0x05
			rcall	at8252_spi

			mov	XL,r16			;addr LOW
			rcall	at8252_spi

			rcall	at8252_spiz
			call	api_buf_bwrite		;write to buffer

			add	r16,const_1		;inc addr
			adc	r17,const_0

			sbiw	r24,1			;byte counter
			brne	at8252_eread_1		;loop
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write lock bits
;------------------------------------------------------------------------------
at8252_wlock:		ldi	XL,0xac			;lb
			rcall	at8252_spi
			mov	XL,r16
			lsl	XL
			lsl	XL
			lsl	XL
			lsl	XL
			lsl	XL
			ori	XL,0x07
			
			rcall	at8252_spi
			rcall	at8252_spiz

			ldi	ZL,10			;PROG TIME
			ldi	ZH,0
			call	api_wait_ms
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; run device
;------------------------------------------------------------------------------
at8252_exit:		out	CTRLPORT,const_0	;-> all zero
			call	api_vcc_off
			out	CTRLDDR,const_0		;-> tristate
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; spi routine for fixed 75KHz
;------------------------------------------------------------------------------
at8252_spiz:		clr	XL
at8252_spi:		ldi	r21,8
at8252_spi_1:		sbrc	XL,7
			sbi	CTRLPORT,AT8252MOSI
			sbrs	XL,7
			cbi	CTRLPORT,AT8252MOSI
			sbi	CTRLPORT,AT8252SCK
			ldi	r20,45
at8252_spi_2:		dec	r20
			brne	at8252_spi_2
			clc
			sbic	CTRLPIN,AT8252MISO
			sec
			rol	XL
			cbi	CTRLPORT,AT8252SCK
			ldi	r20,45
at8252_spi_3:		dec	r20
			brne	at8252_spi_3
			dec	r21
			brne	at8252_spi_1
			ret
