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

.equ		AVR_RST		= SIG1
.equ		AVR_SCK		= SIG2
.equ		AVR_MISO	= SIG3
.equ		AVR_MOSI	= SIG4

;------------------------------------------------------------------------------
; fast init
;------------------------------------------------------------------------------
avr_setfast:		mov	r4,r19
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; fast init
;------------------------------------------------------------------------------
avr_init:		call	api_vcc_on
			cbi	CTRLPORT,AVR_SCK
			sbi	CTRLDDR,AVR_SCK
			cbi	CTRLPORT,AVR_MOSI
			sbi	CTRLDDR,AVR_MOSI

			sbi	CTRLDDR,AVR_RST
			cbi	CTRLPORT,AVR_RST	;-> RESET
			ldi	ZL,200			;50ms
			clr	ZH
			call	wait_ms

			ldi	XL,0xac			;PRG entry
			rcall	avr_spi_slow

			ldi	XL,0x53
			rcall	avr_spi_slow

			ldi	XL,0x00
			rcall	avr_spi_slow

			mov	XH,XL
			ldi	XL,0x00
			rcall	avr_spi_slow
			cpi	XH,0x53			;check for echo
			brne	avr_init_e
			jmp	main_loop_ok

;AVR entry error
avr_init_e:		ldi	r16,0x41
			jmp	main_loop

;------------------------------------------------------------------------------
; ID bytes etc. lesen
;------------------------------------------------------------------------------
avr_readid:		call	api_resetptr
			ldi	r16,0
avr_readid_1:		ldi	XL,0x30
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			mov	XL,r16
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			inc	r16
			cpi	r16,3
			brne	avr_readid_1
			;low fuse
			ldi	XL,0x50
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			;high fuse
			ldi	XL,0x58
			rcall	avr_spi_slow
			ldi	XL,0x08
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			;ext fuse
			ldi	XL,0x50
			rcall	avr_spi_slow
			ldi	XL,0x08
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			;lock bits
			ldi	XL,0x58
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			;cal byte
			ldi	XL,0x38
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			call	buf_write		;write to buffer
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; mass erase
;------------------------------------------------------------------------------
avr_merase:		ldi	XL,0xac
			rcall	avr_spi_slow
			ldi	XL,0x80
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_wreadyz
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; mass erase old 
;------------------------------------------------------------------------------
avr_merase2:		ldi	XL,0xac
			rcall	avr_spi_slow
			ldi	XL,0x80
			rcall	avr_spi_slow
			rcall	avr_spi_slowz
			rcall	avr_spi_slowz
			ldi	ZL,20			;PROG TIME
			ldi	ZH,0
			call	api_wait_ms
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; prog flash pages
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = number of pages
; P4 = page size in words
;------------------------------------------------------------------------------
avr_fprog:		call	api_resetptr
			movw	r24,r16
avr_fprog_0:		clr	r22
avr_fprog_1:		ldi	XL,0x40			;load low byte
			rcall	avr_spi
			rcall	avr_spiz
			mov	XL,r22
			rcall	avr_spi
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			ldi	XL,0x48			;load high byte
			rcall	avr_spi
			rcall	avr_spiz
			mov	XL,r22
			rcall	avr_spi
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			inc	r22
			cp	r22,r19			;page size?
			brne	avr_fprog_1

			ldi	XL,0x4c			;prog page
			rcall	avr_spi
			mov	XL,r25			;ADDR MSB
			rcall	avr_spi
			mov	XL,r24			;ADDR LSB
			rcall	avr_spi
			rcall	avr_wreadyz
			add	r24,r19
			adc	r25,const_0
			dec	r18
			brne	avr_fprog_0
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; prog flash pages
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = number of pages
; P4 = page size in words
;------------------------------------------------------------------------------
avr_fprog2:		call	api_resetptr
			movw	r24,r16
avr_fprog2_0:		clr	r22
avr_fprog2_1:		ldi	XL,0x40			;load low byte
			rcall	avr_spi
			rcall	avr_spiz
			mov	XL,r22
			rcall	avr_spi
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			ldi	XL,0x48			;load high byte
			rcall	avr_spi
			rcall	avr_spiz
			mov	XL,r22
			rcall	avr_spi
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			inc	r22
			cp	r22,r19			;page size?
			brne	avr_fprog2_1

			ldi	XL,0x4c			;prog page
			rcall	avr_spi
			mov	XL,r25			;ADDR MSB
			rcall	avr_spi
			mov	XL,r24			;ADDR LSB
			rcall	avr_spi
			rcall	avr_spiz
			ldi	ZL,5			;PROG TIME
			ldi	ZH,0
			call	api_wait_ms
			add	r24,r19
			adc	r25,const_0
			dec	r18
			brne	avr_fprog2_0
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read nn bytes to buffer
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = NUM LOW
; P4 = NUM HIGH
;------------------------------------------------------------------------------
avr_fread:		movw	r24,r16
			call	api_resetptr

avr_fread_1:		ldi	XL,0x20			;read low byte
			rcall	avr_spi
			mov	XL,r25			;ADDR MSB
			rcall	avr_spi
			mov	XL,r24			;ADDR LSB
			rcall	avr_spi
			rcall	avr_spiz
			call	api_buf_bwrite		;write to buffer
			ldi	XL,0x28			;read high byte
			rcall	avr_spi
			mov	XL,r25			;ADDR MSB
			rcall	avr_spi
			mov	XL,r24			;ADDR LSB
			rcall	avr_spi
			rcall	avr_spiz
			call	api_buf_bwrite		;write to buffer
			adiw	r24,1
			subi	r18,1
			sbci	r19,0
			brne	avr_fread_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; prog EEPROM
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = number of pages to program
; P4 = page size in bytes
;------------------------------------------------------------------------------
avr_eprog:		call	api_resetptr
			movw	ZL,r16			;address
avr_eprog_1:		ldi	r22,0
avr_eprog_2:		ldi	XL,0xc1			;load eeprom
			rcall	avr_spi
			rcall	avr_spiz		;=0
			mov	XL,r22
			rcall	avr_spi			;byte number
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			inc	r22
			cp	r22,r19			;end of page
			brne	avr_eprog_2

			ldi	XL,0xc2			;write EEPROM page
			rcall	avr_spi
			mov	XL,r17
			rcall	avr_spi
			mov	XL,r16
			rcall	avr_spi
			rcall	avr_wreadyz		;wait for ready
			add	r16,r19
			adc	r17,const_0
			dec	r18
			brne	avr_eprog_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; prog EEPROM
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = number of pages to program
; P4 = page size in bytes
;------------------------------------------------------------------------------
avr_eprog2:		call	api_resetptr
			movw	ZL,r16			;address
avr_eprog2_1:		ldi	r22,0
avr_eprog2_2:		ldi	XL,0xc1			;load eeprom
			rcall	avr_spi
			rcall	avr_spiz		;=0
			mov	XL,r22
			rcall	avr_spi			;byte number
			call	api_buf_bread		;get next byte from buffer
			rcall	avr_spi
			inc	r22
			cp	r22,r19			;end of page
			brne	avr_eprog2_2

			ldi	XL,0xc2			;write EEPROM page
			rcall	avr_spi
			mov	XL,r17
			rcall	avr_spi
			mov	XL,r16
			rcall	avr_spi
			rcall	avr_spiz
			ldi	ZL,10			;PROG TIME
			ldi	ZH,0
			call	api_wait_ms
			add	r16,r19
			adc	r17,const_0
			dec	r18
			brne	avr_eprog2_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read n bytes EEPROM
; P1 = ADDR LOW
; P2 = ADDR HIGH
; P3 = num LOW
; P4 = num HIGH
;------------------------------------------------------------------------------
avr_eread:		movw	r24,r16
			movw	ZL,r18
			call	api_resetptr
			;cmd
avr_eread_1:		ldi	XL,0xa0			;read byte
			rcall	avr_spi
			mov	XL,r25			;ADDR MSB
			rcall	avr_spi
			mov	XL,r24			;ADDR LSB
			rcall	avr_spi
			rcall	avr_spiz
			call	api_buf_bwrite		;write to buffer
			adiw	r24,1			;increment address
			sbiw	ZL,1			;bytes to read
			brne	avr_eread_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write fuse bytes and lock bits
;------------------------------------------------------------------------------
avr_wfuse_l:		ldi	XL,0xac			;lo
			rcall	avr_spi_slow
			ldi	XL,0xa0			;lo
			rjmp	avr_wfl

avr_wfuse_h:		ldi	XL,0xac			;hi
			rcall	avr_spi_slow
			ldi	XL,0xa8			;hi
			rjmp	avr_wfl

avr_wfuse_e:		ldi	XL,0xac			;ext
			rcall	avr_spi_slow
			ldi	XL,0xa4			;ext
			rjmp	avr_wfl

			; write lock bits
avr_wlock:		ldi	XL,0xac			;lb
			rcall	avr_spi_slow
			ldi	XL,0xe0			;lb

			;write fuses_lock
avr_wfl:		rcall	avr_spi_slow
			rcall	avr_spi_slowz
			mov	XL,r16
			sbrc	r19,0
			rjmp	avr_wfl2
			rcall	avr_wready_slow
			jmp	main_loop_ok

avr_wfl2:		rcall	avr_spi_slow
			ldi	ZL,10			;PROG TIME
			ldi	ZH,0
			call	api_wait_ms
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; run device
;------------------------------------------------------------------------------
avr_exit:		out	CTRLPORT,const_0	;-> all zero
			call	api_vcc_off
			out	CTRLDDR,const_0		;-> tristate
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; SPI byte senden / empfangen
;------------------------------------------------------------------------------
avr_spiz:		clr	XL
avr_spi:		ldi	r21,8
			sbrs	r4,0
			rjmp	avr_spi_slow_1		
avr_spi_1:		sbrc	XL,7
			sbi	CTRLPORT,AVR_MOSI
			sbrs	XL,7
			cbi	CTRLPORT,AVR_MOSI
			sbi	CTRLPORT,AVR_SCK
			ldi	r20,4
avr_spi_2:		dec	r20
			brne	avr_spi_2
			clc
			sbic	CTRLPIN,AVR_MISO
			sec
			rol	XL
			cbi	CTRLPORT,AVR_SCK
			ldi	r20,4
avr_spi_3:		dec	r20
			brne	avr_spi_3
			dec	r21
			brne	avr_spi_1
			ret


avr_spi_slowz:		clr	XL
avr_spi_slow:		ldi	r21,8
avr_spi_slow_1:		sbrc	XL,7
			sbi	CTRLPORT,AVR_MOSI
			sbrs	XL,7
			cbi	CTRLPORT,AVR_MOSI
			sbi	CTRLPORT,AVR_SCK
			ldi	r20,200
avr_spi_slow_2:		dec	r20
			brne	avr_spi_slow_2
			clc
			sbic	CTRLPIN,AVR_MISO
			sec
			rol	XL
			cbi	CTRLPORT,AVR_SCK
			ldi	r20,200
avr_spi_slow_3:		dec	r20
			brne	avr_spi_slow_3
			dec	r21
			brne	avr_spi_slow_1
			ret

;------------------------------------------------------------------------------
; wait for ready
;------------------------------------------------------------------------------
avr_wreadyz:		clr	XL
avr_wready:		rcall	avr_spi			;output last byte of last cmd
avr_wready_0:		ldi	XL,0			;70us wait
avr_wready_1:		dec	XL
			brne	avr_wready_1
			ldi	XL,0xf0			;CMD
			rcall	avr_spi
			rcall	avr_spiz		;ZERO
			rcall	avr_spiz		;ZERO
			rcall	avr_spi			;stat
			sbrc	XL,0			;skip if zero
			rjmp	avr_wready_0		;loop if busy
			ret

;------------------------------------------------------------------------------
; wait for ready
;------------------------------------------------------------------------------
avr_wready_slowz:	clr	XL
avr_wready_slow:	rcall	avr_spi_slow		;output last byte of last cmd
avr_wready_slow_0:	ldi	XL,0			;70us wait
avr_wready_slow_1:	dec	XL
			brne	avr_wready_slow_1
			ldi	XL,0xf0			;CMD
			rcall	avr_spi_slow
			rcall	avr_spi_slowz		;ZERO
			rcall	avr_spi_slowz		;ZERO
			rcall	avr_spi_slow		;stat
			sbrc	XL,0			;skip if zero
			rjmp	avr_wready_slow_0	;loop if busy
			ret
