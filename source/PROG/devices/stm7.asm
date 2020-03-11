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
.equ	ICC_RESET	= SIG3
.equ	ICC_ICCCLK	= SIG4
.equ	ICC_ICCDATA	= SIG1

;------------------------------------------------------------------------------
; icc initialisierung
;------------------------------------------------------------------------------
init_icc:	cbi	CTRLPORT,ICC_ICCDATA	;all to LOW
		cbi	CTRLPORT,ICC_ICCCLK
		cbi	CTRLPORT,ICC_RESET
		sbi	CTRLDDR,ICC_ICCDATA	;set to output
		sbi	CTRLDDR,ICC_ICCCLK
		sbi	CTRLDDR,ICC_RESET

		call	api_vcc_on

		ldi	ZL,20			;20ms
		clr	ZH
		call	wait_ms

		sbi	CTRLPORT,ICC_RESET	;RESET HIGH
		rcall	icc_wshort3
		cbi	CTRLPORT,ICC_RESET	;RESET LOW

		rcall	icc_wshort3

		sbi	CTRLPORT,ICC_ICCCLK
		rcall	icc_wshort
		cbi	CTRLPORT,ICC_ICCCLK
		rcall	icc_wshort

		mov	r23,r19
init_icc_1:	rcall	icc_wshort2
		sbi	CTRLPORT,ICC_ICCDATA	;start pulse

		rcall	icc_wshort2
		cbi	CTRLPORT,ICC_ICCDATA	;end pulse
		dec	r23
		brne	init_icc_1

		rcall	icc_wshort3
		sbi	CTRLPORT,ICC_RESET	;RESET HIGH
		rcall	icc_wshort3
		cbi	CTRLDDR,ICC_RESET	;RESET input

		cbi	CTRLDDR,ICC_ICCCLK	;CLOCK input
		sbi	CTRLPORT,ICC_ICCCLK	;CLOCK PullUp

		clr	ZL
		clr	ZH

init_icc_2:	sbic	CTRLPIN,ICC_ICCCLK	;wait for clk HIGH
		rjmp	init_icc_2a
		sbiw	ZL,1
		brne	init_icc_2
		rjmp	init_icc_err

init_icc_2a:	clr	ZL
		clr	ZH

init_icc_3:	sbis	CTRLPIN,ICC_ICCCLK	;wait for clk LOW
		rjmp	init_icc_3a
		sbiw	ZL,1
		brne	init_icc_3
		rjmp	init_icc_err

init_icc_3a:	clr	ZL
		clr	ZH

init_icc_4:;	cbi	CTRLDDR,ICC_ICCDATA	;set to input
		cbi	CTRLDDR,ICC_ICCCLK

init_icc_5:	sbic	CTRLPIN,ICC_ICCCLK	;wait for clk HIGH
		rjmp	init_icc_6
		sbiw	ZL,1
		brne	init_icc_5
		rjmp	init_icc_err

init_icc_6:	ldi	XL,0xFF			;dummy command byte
		rcall	icc_send_byte

		jmp	main_loop_ok

init_icc_err:	ldi	r16,0x21
		jmp	main_loop

;------------------------------------------------------------------------------
; icc exit
;------------------------------------------------------------------------------
exit_icc:	cbi	CTRLPORT,ICC_ICCDATA	;all to LOW
		cbi	CTRLPORT,ICC_ICCCLK
		cbi	CTRLPORT,ICC_RESET
		call	api_vcc_off
		ldi	ZL,50			;20ms
		clr	ZH
		call	wait_ms
		cbi	CTRLDDR,ICC_ICCDATA	;set to input
		cbi	CTRLDDR,ICC_ICCCLK
		cbi	CTRLDDR,ICC_RESET
		jmp	main_loop_ok

;------------------------------------------------------------------------------
; write memory and execute
; par1=AL
; par2=AH
; par3=bytes
;------------------------------------------------------------------------------
icc_write_mem:	andi	r18,0x7f
		ldi	YH,1
		mov	YL,r18
		dec	r18			;num -1
		ldi	XL,0x00
		rcall	icc_send_byte
		mov	XL,r17			;addr Hi
		rcall	icc_send_byte
		mov	XL,r16			;addr LO
		rcall	icc_send_byte
		mov	XL,r18			;NUM
		rcall	icc_send_byte

icc_writem_1:	ld	XL,-Y
		rcall	icc_send_byte
		cpi	YL,0x00
		brne	icc_writem_1
		rcall	icc_dbyte
		ldi	XL,0x80
		rcall	icc_send_byte
		cbi	CTRLPORT,ICC_ICCCLK	;clock low
		cbi	CTRLDDR,ICC_ICCCLK	;clock inactive
		jmp	main_loop_ok

;------------------------------------------------------------------------------
; ST7 load and execute bootloader
;------------------------------------------------------------------------------
icc_boot:	ldi	ZL,LOW(st7code_init*2)
		ldi	ZH,HIGH(st7code_init*2)
		ldi	XL,0x00
		rcall	icc_send_byte
		ldi	XL,0x00			;addr Hi
		rcall	icc_send_byte
		ldi	XL,0x84			;addr LO
		rcall	icc_send_byte
		ldi	XL,0x7b			;NUM
		rcall	icc_send_byte
		ldi	r23,0x7c
		add	ZL,r23
		adc	ZH,const_0
		sbiw	ZL,1
icc_boot_1:	lpm	XL,Z
		rcall	icc_send_byte
		sbiw	ZL,1
		dec	r23
		brne	icc_boot_1

		rcall	icc_dbyte
		ldi	XL,0x80
		rcall	icc_send_byte
		cbi	CTRLPORT,ICC_ICCCLK	;clock low
		cbi	CTRLDDR,ICC_ICCCLK	;clock inactive
		jmp	main_loop_ok

;------------------------------------------------------------------------------
; ST7 program main flash / eeprom
; par1=AL
; par2=AH
; par3=32 byte blocks
;------------------------------------------------------------------------------
st7_eprog:	movw	r24,r16
		call	api_resetptr
		ldi	ZL,LOW(st7code_eprog*2)
		ldi	ZH,HIGH(st7code_eprog*2)
		rjmp	st7_fprog_1

st7_fprog:	movw	r24,r16
		call	api_resetptr
		ldi	ZL,LOW(st7code_fprog*2)
		ldi	ZH,HIGH(st7code_fprog*2)
st7_fprog_1:	rcall	st7_bcode		;transfer module

st7_fprog_loop:	mov	XL,r24			;AL
		rcall	ics_send_byte
		mov	XL,r25			;AH
		rcall	ics_send_byte
		ldi	r23,32
st7_fprog_l1:	call	api_buf_bread
		rcall	ics_send_byte
		dec	r23
		brne	st7_fprog_l1
		ldi	ZL,10
		ldi	ZH,0
		call	api_wait_ms
		adiw	r24,32
		dec	r18
		brne	st7_fprog_loop
st7_fprog_end:	ldi	XL,0x00			;addr LO
		rcall	ics_send_byte
		ldi	XL,0x20			;exit-addr
		rcall	ics_send_byte
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; ST7 program main optio bytes
; par1=AL
; par2=AH
; par3=Option byte 0
; par4=Option byte 1
;------------------------------------------------------------------------------
st7_oprog:	movw	r24,r16
		call	api_resetptr
		ldi	ZL,LOW(st7code_oprog*2)
		ldi	ZH,HIGH(st7code_oprog*2)
		rcall	st7_bcode		;transfer module

		mov	XL,r24			;AL
		rcall	ics_send_byte
		mov	XL,r25			;AH
		rcall	ics_send_byte

		mov	XL,r19			;option 1
		rcall	ics_send_byte

		ldi	ZL,10
		rcall	st7_waitms

		mov	XL,r18			;option 0
		rcall	ics_send_byte

		ldi	ZL,10
		ldi	ZH,0
		call	api_wait_ms

		jmp	main_loop_ok

;------------------------------------------------------------------------------
; ST7 read main flash / eeprom
; par1=AL
; par2=AH
; par3=32 byte blocks
;------------------------------------------------------------------------------
st7_fread:	movw	r24,r16
		call	api_resetptr
		ldi	ZL,LOW(st7code_fread*2)
		ldi	ZH,HIGH(st7code_fread*2)
st7_fread_1:	rcall	st7_bcode		;transfer module

st7_fread_loop:	mov	XL,r24			;AL
		rcall	ics_send_byte
		mov	XL,r25			;AH
		rcall	ics_send_byte
		ldi	r23,32
st7_fread_l1:	rcall	ics_recv_byte
		call	api_buf_bwrite
		dec	r23
		brne	st7_fread_l1
		ldi	ZL,4
		rcall	st7_waitms
		adiw	r24,32
		dec	r18
		brne	st7_fread_loop
		rjmp	st7_fprog_end

;------------------------------------------------------------------------------
; ST7 read option bytes
; par1=AL
; par2=AH
;------------------------------------------------------------------------------
st7_oread:	movw	r24,r16
		call	api_resetptr
		ldi	ZL,LOW(st7code_oread*2)
		ldi	ZH,HIGH(st7code_oread*2)

		rcall	st7_bcode		;transfer module

		mov	XL,r24			;AL
		rcall	ics_send_byte
		mov	XL,r25			;AH
		rcall	ics_send_byte

		ldi	ZL,1
		rcall	st7_waitms

		rcall	ics_recv_byte
		sts	0x101,XL

		ldi	ZL,1
		rcall	st7_waitms

		rcall	ics_recv_byte
		sts	0x100,XL

		jmp	main_loop_ok

st7_waitms:	clr	ZH
		jmp	api_wait_ms

;------------------------------------------------------------------------------
; write 60 bytes bootcode
;------------------------------------------------------------------------------
st7_bcode:	ldi	r23,60
st7_bcode_1:	lpm	XL,Z+
		rcall	ics_send_byte
		dec	r23
		brne	st7_bcode_1
		ret

;------------------------------------------------------------------------------
; icc send data byte
; XL=data
;------------------------------------------------------------------------------
icc_dbyte:	ldi	XL,0xff
icc_send_byte:	cbi	CTRLDDR,ICC_ICCCLK	;clock inactive
		cbi	CTRLDDR,ICC_ICCDATA	;data inactive
		ldi	XH,8			;8 bits
		push	ZL
		push	ZH
		ldi	ZL,0
		ldi	ZH,0

icc_sendb_1:	sbic	CTRLPIN,ICC_ICCCLK	;wait for clk HIGH
		rjmp	icc_sendb_1a
		sbiw	ZL,1
		brne	icc_sendb_1
		pop	ZH
		pop	ZL
		pop	ZH
		pop	ZL
		ldi	r16,0x21		;timeout
		jmp	main_loop

icc_sendb_1a:	cbi	CTRLDDR,ICC_ICCDATA	;data inactive
		rcall	icc_wshort2

		ldi	ZL,0
		ldi	ZH,0

icc_sendb_2:	sbis	CTRLPIN,ICC_ICCCLK	;wait for clk LOW
		rjmp	icc_sendb_2a
		sbiw	ZL,1
		brne	icc_sendb_2
		pop	ZH
		pop	ZL
		pop	ZH
		pop	ZL
		ldi	r16,0x21		;timeout
		jmp	main_loop

icc_sendb_2a:	sbrs	XL,7
		sbi	CTRLDDR,ICC_ICCDATA	;data LOW
		lsl	XL			;next bit
		rcall	icc_wshort2
		dec	XH			;bit counter
		brne	icc_sendb_1
		cbi	CTRLPORT,ICC_ICCCLK	;clock low
		sbi	CTRLDDR,ICC_ICCCLK	;clock active LOW
		rcall	icc_wshort3
		pop	ZH
		pop	ZL
		ret

;------------------------------------------------------------------------------
; icc send data byte (SPI mode)
; XL=data
;------------------------------------------------------------------------------
ics_send_byte:	sbi	CTRLPORT,ICC_ICCCLK	;clock high
		sbi	CTRLDDR,ICC_ICCCLK	;clock active
		sbi	CTRLDDR,ICC_ICCDATA	;data active
		ldi	XH,8
ics_sendb_1:	sbrc	XL,7
		sbi	CTRLPORT,ICC_ICCDATA
		sbrs	XL,7
		cbi	CTRLPORT,ICC_ICCDATA
		lsl	XL
		cbi	CTRLPORT,ICC_ICCCLK	;clock low
		rcall	icc_wshort1
		sbi	CTRLPORT,ICC_ICCCLK	;clock high
		rcall	icc_wshort1
		dec	XH
		brne	ics_sendb_1
		rjmp	icc_wshort1

;------------------------------------------------------------------------------
; icc receive data byte (SPI mode)
; XL=data
;------------------------------------------------------------------------------
ics_recv_byte:	cbi	CTRLDDR,ICC_ICCDATA	;data inactive
		sbi	CTRLPORT,ICC_ICCCLK	;clock high
		sbi	CTRLDDR,ICC_ICCCLK	;clock active
		ldi	XH,8
		clr	XL
ics_recvb_1:	cbi	CTRLPORT,ICC_ICCCLK	;clock low
		rcall	icc_wshort1
		lsl	XL
		sbic	CTRLPIN,ICC_ICCDATA
		inc	XL
		sbi	CTRLPORT,ICC_ICCCLK	;clock high
		rcall	icc_wshort1
		dec	XH
		brne	ics_recvb_1
		rcall	icc_wshort
		rjmp	icc_wshort1


icc_wshort:	push	XL
		ldi	XL,50
icc_wshort_1:	dec	XL
		brne	icc_wshort_1
		pop	XL
		ret

icc_wshort1:	push	XL
		ldi	XL,0
icc_wshort1_1:	dec	XL
		brne	icc_wshort1_1
		pop	XL
		ret

icc_wshort2:	push	XL
		ldi	XL,20
icc_wshort2_1:	dec	XL
		brne	icc_wshort2_1
		pop	XL
		ret

icc_wshort3:	push	XL
		ldi	XL,0
icc_wshort3_1:	dec	XL
		nop
		nop
		rcall	icc_wshort3_2
		brne	icc_wshort3_1
		pop	XL
icc_wshort3_2:	ret

