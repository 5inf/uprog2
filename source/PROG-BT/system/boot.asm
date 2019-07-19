;################################################################################
;#										#
;# UPROG2 universal programmer							#
;#										#
;# version 1.0									#
;#										#
;# copyright (c) 2013-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.equ		max_transfer	= 0x08		;max. transfer size (HIGH byte)
.equ		bl_version 	= 12+64		;bootloader version (1.2)

bl_start:	rjmp	bl_reset	;B+0	bootloader starts here

;-------------------------------------------------------------------------------
; API functions
;-------------------------------------------------------------------------------
api_wait_ms:	rjmp	wait_ms		;B+1	wait Z ms
api_vcc_on:	rjmp	vcc_on		;B+4	set vcc on
api_vcc_off:	rjmp	vcc_off		;B+5	set vcc off (all)
api_vcc_dis:	rjmp	vcc_dis		;B+6	disconnect vcc
api_resetptr:	rjmp	buf_resetptr	;B+7	reset buffer pointer
api_buf_bread:	rjmp	buf_read	;B+8	read a byte from buffer (XL)
api_buf_mread:	rjmp	buf_mread	;B+9	read a word from buffer (XH,XL)
api_buf_lread:	rjmp	buf_lread	;B+10	read a word from buffer (XL,XH)
api_buf_bwrite:	rjmp	buf_write	;B+11	write a byte to buffer (XL)
api_buf_mwrite:	rjmp	buf_mwrite	;B+12	write a word to buffer (XH,XL)
api_buf_lwrite:	rjmp	buf_lwrite	;B+13	write a word to buffer (XL,XH)
api_setvpp:	rjmp	setvoltage	;B+14	set vpp voltage
api_updatevpp:	rjmp	updatevoltage	;B+15	update vpp voltage
api_vpp_on:	rjmp	vpp_on		;B+16	switch vpp on
api_vpp_off:	rjmp	vpp_off		;B+17	swich vpp of
api_vpp_en:	rjmp	set_vpp		;B+18	enalble VPP
api_vpp_dis:	rjmp	dis_vpp		;B+19	disable VPP
api_set_3v3:	rjmp	set_3V3		;B+20	set VCC to 3,3V
api_set_5v:	rjmp	set_5V		;B+21	set VCC to 5V
api_set_rx:	rjmp	set_rx		;B+22	set ptr/counter
api_set_tx:	rjmp	set_tx		;B+23	set ptr/counter
api_host_put:	rjmp	host_put	;B+24	write byte to host
api_host_get:	rjmp	host_get	;B+25	get byte from host

;-------------------------------------------------------------------------------
; boot loader entry
;-------------------------------------------------------------------------------
bl_reset:		cli				;disable interrupts
			ldi	XL,0x00			;set constants
			mov	const_0,XL
			ldi	XL,0x01
			ldi	XL,HIGH(stack)
			out	SPH,XL
			ldi	XL,LOW(stack)
			out	SPL,XL
			
			;init PORTs
			ldi	XL,0x00
			out	CTRLPORT,XL
			ldi	XL,0x00
			out	CTRLDDR,XL
			
			ldi	XL,0x00
			out	DDRA,XL
			ldi	XL,0x00
			out	PORTA,XL
			
			ldi	XL,0x12			;3,3V mode per default
			out	PORTD,XL
			ldi	XL,0xba
			out	DDRD,XL
			
			;disable I2C
			sts	TWCR,const_0
			
			;wait a little bit
			ldi	ZL,0
			ldi	ZH,1
			rcall	wait_ms

			sbi	LEDPORT,BUSY_LED		;set red LED on

			ldi	YL,7
			ldi	YH,0
			call	eeprom_read
			cpi	XL,0xff
			brne	bl_reset_noinit

			rcall	init_btm

bl_reset_noinit:	rcall	set_br230K			;set baudrate to 230400
			ldi	ZL,0				;1s
			ldi	ZH,4		
			rcall	wait_ms
			cbi	LEDPORT,BUSY_LED		;set red LED off		

;			ldi	YL,0
;			ldi	YH,1
;			ldi	XL,0xAA
;bl_prefill:	;	st	Y+,XL
;			cpi	YH,0x09
;			brne	bl_prefill

			rjmp	main_loop_wait

;------------------------------------------------------------------------------
; now start
;------------------------------------------------------------------------------
main_loop_ok_noret:	clr	r16
main_loop_noret:	rjmp	main_loop_r2


main_loop_ok:		clr	r16				;OK value
main_loop:		rcall	set_rx
			;send data if rxlen > 0
main_loop_r1:		sbiw	r24,1
			brcs	main_loop_r2
			rcall	buf_read
			rcall	host_put			;send data
			rjmp	main_loop_r1

			;send result byte (status)
main_loop_r2:		mov	XL,r16				;status
			rcall	host_put			;send status

			;wait for serial data
main_loop_wait:		cbi	LEDPORT,BUSY_LED		;set red LED off
			rcall	host_get			;get char
main_loop_04:		cpi	XL,0xaa
			brcs	main_loop_wait			;ignore all < 0xaa
			cpi	XL,0xae
			brcc	main_loop_wait			;ignore all > 0xad
			subi	XL,0xaa
			sts	tabselect,XL
			sbi	LEDPORT,BUSY_LED		;set red LED on
			
			rcall	host_get			;get byte
			mov	ZL,XL				;command
			rcall	host_get			;get byte
			mov	r24,XL				;TXLEN LOW
			sts	txlen_l,XL			;store
			rcall	host_get			;get byte
			mov	r25,XL				;TXLEN HIGH
			sts	txlen_h,XL			;store
			rcall	host_get			;get byte
			sts	rxlen_l,XL			;RXLEN LOW
			rcall	host_get			;get byte
			sts	rxlen_h,XL			;RXLEN HIGH

			rcall	host_get			;get byte
			mov	r16,XL				;PAR 1
			sts	par_1,XL			;xPAR 1
			rcall	host_get			;get byte
			mov	r17,XL				;PAR 2
			sts	par_2,XL			;xPAR 2
			rcall	host_get			;get byte
			mov	r18,XL				;PAR 3
			sts	par_3,XL			;xPAR 3
			rcall	host_get			;get byte
			mov	r19,XL				;PAR 4
			sts	par_4,XL			;xPAR 4

			;fill buffer if set
			rcall	set_tx
main_loop_10:		sbiw	r24,1
			brcs	main_loop_12
			rcall	host_get
			rcall	buf_write
			rjmp	main_loop_10

main_loop_12:		rcall	host_get			;dummy value to prevent +++

			cpi	ZL,0xf0				;commands above 0xef are sytem commands
			brcc	main_loop_14
			ldi	ZH,0
			lsl	ZL				;2 words per entry (jmp)
			rol	ZH
			lds	r0,tabselect
			lsl	r0
			add	ZH,r0				;add table offset
			sbi	LEDPORT,BUSY_LED		;set red LED on
			ijmp					;do jump (exec)

			;F0=get programmer info
main_loop_14:		brne	main_loop_20			;0xf0 -> send BL info
			ldi	XL,bl_version
			sts	0x100,XL
			ldi	XL,max_transfer			;max transfer size
			sts	0x101,XL
			ldi	ZL,LOW(sysver*2)
			ldi	ZH,HIGH(sysver*2)
			lpm	XL,Z+
			sts	0x102,XL
			lpm	XL,Z+
			sts	0x103,XL
			rjmp	main_loop_ok

			;F1=write flash pages (update)
main_loop_20:		cpi	ZL,0xf1				;write pages
			brne	main_loop_30
			sbi	LEDPORT,BUSY_LED		;set red LED on
			rjmp	mem_wblock			;write page block

			;F2=set VPP
main_loop_30:		cpi	ZL,0xf2				;set programming voltage
			brne	main_loop_35
			rcall	setvoltage
			rjmp	main_loop

			;F3=update VPP
main_loop_35:		cpi	ZL,0xf3				;update programming voltage
			brne	main_loop_40
			rjmp	updatevoltage

			;F4=VPP enable
main_loop_40:		cpi	ZL,0xf4				;set programming voltage
			brne	main_loop_45
			rcall	set_vpp
			rjmp	main_loop_ok

			;F5=VPP disable
main_loop_45:		cpi	ZL,0xf5				;set programming voltage
			brne	main_loop_50
			rcall	dis_vpp
			rjmp	main_loop_ok

			;F6=Abort
main_loop_50:		cpi	ZL,0xf6				;clear
			brne	main_loop_60
			call	prg_reset
			clr	ZL
			clr	ZH
main_loop_52:		sbiw	ZL,1
			brne	main_loop_52
			rjmp	main_loop_ok

			;F7=get calibration data (obsolete)
main_loop_60:
			;F8=read voltages
main_loop_70:		cpi	ZL,0xf8				;voltage
			brne	main_loop_80
			rjmp	vout

			;FA=set 3,3V mode
main_loop_80:		cpi	ZL,0xfa				;3,3V mode
			brne	main_loop_81
			rcall	set_3V3
			rjmp	main_loop_ok

			;FB=set 5V mode
main_loop_81:		cpi	ZL,0xfb				;5V mode
			brne	main_loop_90
			rcall	set_5V
			rjmp	main_loop_ok

			;FC=write 128 Bytes param block
main_loop_90:		cpi	ZL,0xfc				;write param
			brne	main_loop_100
			ldi	YL,0x00
			ldi	YH,0x10
			ldi	r21,0x80
main_loop_91:		rcall	host_get
			st	Y+,XL
			dec	r21
			brne	main_loop_91
			rjmp	main_loop_ok

			;FD=read 128 Bytes param block
main_loop_100:		cpi	ZL,0xfd				;read param
			brne	main_loop_110
			ldi	YL,0x00
			ldi	YH,0x10
			ldi	r21,0x80
main_loop_101:		ld	XL,Y+
			rcall	host_put
			dec	r21
			brne	main_loop_101
			rjmp	main_loop_ok

			;FE=set pull
main_loop_110:		cpi	ZL,0xfe				;read param
			brne	main_loop_unk
			andi	r16,0x03			;PULL-mask
			andi	r17,0x03			;PU/PD
			sts	pull_sel,r16
			sts	pull_pol,r17
			rjmp	main_loop_ok

main_loop_unk:		ldi	r16,0x01			;unknown
			rjmp	main_loop

;------------------------------------------------------------------------------
; get a single char from host
;------------------------------------------------------------------------------
host_get:		lds	r0,UCSR0A
			sbrs	r0, RXC0
			rjmp	host_get
			lds	XL,UDR0
			ret

;------------------------------------------------------------------------------
; get a single char from host
;------------------------------------------------------------------------------
host_get1:		push	ZL
			push	ZH
			ldi	ZL,0
			ldi	ZH,16
host_get1a:		sbiw	ZL,1
			breq	host_get1b			
			lds	r0,UCSR0A
			sbrs	r0, RXC0
			rjmp	host_get1a
			lds	XL,UDR0
host_get1b:		pop	ZH
			pop	ZL
			ret



;------------------------------------------------------------------------------
; put a single char to host
;------------------------------------------------------------------------------
host_put:		sbic	PIND,6			;wait for RTS is high
			rjmp	host_put
			lds	r0,UCSR0A
			sbrs	r0,UDRE0
			rjmp	host_put
			sts	UDR0,XL
			ret

;------------------------------------------------------------------------------
; get ADC values
;------------------------------------------------------------------------------
vout:			rcall	read_vbatt

			rcall	read_vbatt
			sts	0x100,ZL

			rcall	read_vext
			sts	0x101,ZL

			rcall	read_vpp
			sts	0x102,ZL
		
			rjmp	main_loop_ok

;------------------------------------------------------------------------------
; read vpp and scale
;------------------------------------------------------------------------------
read_vpp:		ldi	XL,0xe2				;internal reference, ADC2, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
read_vpp_1:		lds	XL,ADCSRA
			andi	XL,0x40
			brne	read_vpp_1
			ldi	XL,126
			rjmp	volt2

;------------------------------------------------------------------------------
; read vext and scale
;------------------------------------------------------------------------------
read_vext:		ldi	XL,0xe1				;internal reference, ADC1, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
read_vext_1:		lds	XL,ADCSRA
			andi	XL,0x40
			brne	read_vext_1
			ldi	XL,142
			rjmp	volt2

;------------------------------------------------------------------------------
; read vbatt and scale
;------------------------------------------------------------------------------
read_vbatt:		ldi	XL,0xe0				;internal reference, ADC0, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
read_vbatt_1:		lds	XL,ADCSRA
			andi	XL,0x40
			brne	read_vbatt_1
			ldi	XL,72

volt2:			lds	ZL,ADCL
			lds	ZH,ADCH				;get value
			lsl	ZL
			rol	ZH
			mul	ZH,XL				;* factor
			mov	ZL,r1
			sbrc	r0,7				;round
			inc	ZL
			ret

;-------------------------------------------------------------------------------
; write text message in buffer
;-------------------------------------------------------------------------------
buftext:		ldi	YL,0				;buffer start+
			ldi	YH,1
buftext_1:		lpm	XL,Z+
			st	Y+,XL
			cpi	XL,0
			brne	buftext_1
			ret

;-------------------------------------------------------------------------------
; reset buffer pointer
;-------------------------------------------------------------------------------
buf_resetptr:		clr	YL
			clr	YH
			ret

;-------------------------------------------------------------------------------
; write a byte to buffer
;-------------------------------------------------------------------------------
buf_write:		cpi	YH,0x40				;out of range
			brcc	buf_write_e			;do nothing
			inc	YH
			st	Y,XL
			dec	YH
buf_write_e:		adiw	YL,1
			ret

;-------------------------------------------------------------------------------
; write a word to buffer (MSB first)
;-------------------------------------------------------------------------------
buf_mwrite:		push	XL
			mov	XL,XH
			rcall	buf_write
			pop	XL
			rjmp	buf_write

;-------------------------------------------------------------------------------
; write a word to buffer (LSB first)
;-------------------------------------------------------------------------------
buf_lwrite:		rcall	buf_write
			mov	XL,XH
			rjmp	buf_write

;-------------------------------------------------------------------------------
; read a byte from buffer
; Y = pointer
;-------------------------------------------------------------------------------
buf_read:		ldi	XL,0xff
			cpi	YH,0x40				;out of range
			brcc	buf_read_e			;read 0xff
			inc	YH
			ld	XL,Y
			dec	YH
buf_read_e:		adiw	YL,1
			ret

;-------------------------------------------------------------------------------
; read a word from buffer
; Y = pointer
;-------------------------------------------------------------------------------
buf_mread:		rcall	buf_read
			mov	XH,XL
			rjmp	buf_read

;-------------------------------------------------------------------------------
; read a word from buffer
; Y = pointer
;-------------------------------------------------------------------------------
buf_lread:		rcall	buf_read
			push	XL
			rcall	buf_read
			mov	XH,XL
			pop	XL
			ret


set_br192:		ldi	XH,129			;19,2K at start
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ldi	XL,0x02			;enable U2X
			sts	UCSR0A,XL
			ldi	XL,0x18			;enable RX/TX
			sts	UCSR0B,XL
			ldi	XL,0x06
			sts	UCSR0C,XL
			ldi	XH,129			;19,2K at start
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ret

set_br230K:		ldi	XH,10			;230K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ldi	XL,0x02			;enable U2X
			sts	UCSR0A,XL
			ldi	XL,0x18			;enable RX/TX
			sts	UCSR0B,XL
			ldi	XL,0x06
			sts	UCSR0C,XL
			ldi	XH,10			;230K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ret


vcc_on:			rcall	read_vext
			cpi	ZL,5
			brcs	vcc_on_1
			rjmp	vcc_on_2			;extern driven or already on
			
vcc_on_1:		ldi	XL,0xf0
			out	PORTA,XL
			out	DDRA,XL
vcc_on_2:		lds	r16,pull_sel
			lds	r17,pull_pol
			in	XL,PORTB
			in	XH,DDRB
			andi	XH,0xFC
			out	DDRB,XH				;temporarily all off
			or	XH,r16
			andi	XL,0xFC
			or	XL,r17
			out	PORTB,XL
			out	DDRB,XH
			ret

vcc_off:		out	PORTA,const_0
			in	XL,DDRB
			andi	XL,0xFC
			out	DDRB,XH				;all pull off
			ldi	ZL,10
			ldi	ZH,0
			call	wait_ms
			out	DDRA,const_0
			ret

vcc_dis:		out	DDRA,const_0
			out	PORTA,const_0
			in	XL,DDRB
			andi	XL,0xFC
			out	DDRB,XH				;all pull off
			ret

prg_reset:		ldi	XL,0x00
			out	DDRC,XL
			ldi	XL,0x00
			out	PORTC,XL
			;disable I2C
			sts	TWCR,const_0
			;disable SPI
			rcall	vpp_off
			rcall	vcc_off
			rcall	vcc_dis
			rjmp	dis_vpp


wait_ms:		push	XL
			push	XH
wait_ms_1:		ldi	XL,LOW(4972)		;1
			ldi	XH,HIGH(4972)		;1
wait_ms_2:		sbiw	XL,1			;2
			brne	wait_ms_2		;2/1
			sbiw	ZL,1
			brne	wait_ms_1
			pop	XH
			pop	XL
			ret

set_vpp:		push	r16
			ldi	r16,240			;pwn range
			sts	ICR1H,const_0
			sts	ICR1L,r16
			sts	OCR1AH,const_0
			sts	OCR1AL,r18
			ldi	r16,0x82
			sts	TCCR1A,r16
			ldi	r16,0x19
			sts	TCCR1B,r16
			sbi	DDRD,3
			pop	r16
			ret

dis_vpp:		ldi	r16,0x03
			sts	TCCR1A,r16
			ldi	r16,0x09
			sts	TCCR1B,r16
			sbi	DDRD,3
			cbi	PORTD,3
			ret

vpp_on:			sbi	DDRD,3
			sbi	PORTD,3
			ret	

vpp_off:		sbi	DDRD,3
			cbi	PORTD,3
			ret

set_5V:			cbi	PORTD,4
			ret
			
set_3V3:		sbi	PORTD,4
			ret

;------------------------------------------------------------------------------
; set vpp
; PAR1=value
;------------------------------------------------------------------------------
setvoltage:		lds	r16,par_1
			cpi	r16,0				;set vpp to zero
			brne	setvolt_1
			rjmp	dis_vpp
			clr	r16
			ret

			;out of range
setvolt_o:		ldi	r16,2
			ret

setvolt_1:		cpi	r16,45
			brcs	setvolt_o
			cpi	r16,161
			brcc	setvolt_o

			ldi	r18,12				;this is the voltage to set

setvolt_3:		rcall	set_vpp				;set voltage
			ldi	ZL,20				;wait n ms
			ldi	ZH,0
			rcall	wait_ms

setvolt_10:		rcall	set_vpp				;set PWM value
			ldi	ZL,20				;wait n ms
			ldi	ZH,0
			rcall	wait_ms
			rcall	read_vpp			;read from ADC
			cp	ZL,r16				;check
			brcc	setvolt_20			;OK
			subi	r18,0xfa			;+6
			cpi	r18,180
			brcc	setvolt_e3			;out of range, cannot set
			rjmp	setvolt_10			;next try

setvolt_20:		rcall	set_vpp				;set PWM value
			ldi	ZL,20				;wait n ms
			ldi	ZH,0
			rcall	wait_ms
			rcall	read_vpp			;read from ADC
			cp	ZL,r16				;check
			brcs	setvolt_30			;OK
			subi	r18,0x01			;-1
			brcs	setvolt_e3			;out of range, cannot set
			rjmp	setvolt_20			;next try

setvolt_30:		inc	r18
			rcall	set_vpp				;set PWM value
			mov	XL,r18
			subi	r18,0xfe			;+2
setvolt_31:		clr	r16
			ret

			;voltage set error
setvolt_e3:		ldi	r16,3				;voltage error
			ret					;end


;------------------------------------------------------------------------------
; update vpp
;------------------------------------------------------------------------------
updatevoltage:		lds	r16,par_1
			cpi	r16,0
			brne	upvolt_1
			rjmp	dis_vpp
			rjmp	main_loop_ok

			;out of range
upvolt_o:		ldi	r16,2
			rjmp	main_loop

upvolt_1:		cpi	r16,45
			brcs	upvolt_o
			cpi	r16,161
			brcc	upvolt_o

upvolt_2:		rcall	read_vpp			;read from ADC
			cp	ZL,r16				;check
			brcc	upvolt_3

			lds	r18,OCR1AL			;get PWM value
			inc	r18
			cpi	r18,180
			brcc	upvolt_e3
			rcall	set_vpp				;set PWM value
			ldi	ZL,20				;wait n ms
			ldi	ZH,0
			rcall	wait_ms
			rjmp	upvolt_2

upvolt_3:		breq	upvolt_4
			lds	r18,OCR1AL			;get PWM value
			dec	r18
			cpi	r18,4
			brcs	upvolt_e3
			rcall	set_vpp				;set PWM value
			ldi	ZL,20				;wait n ms
			ldi	ZH,0
			rcall	wait_ms
			rjmp	upvolt_2

upvolt_4:		rjmp	main_loop_ok

			;voltage set error
upvolt_e3:		ldi	r16,3				;voltage error
			rjmp	main_loop			;end


setname:		ldi	ZL,LOW(text_setname*2)		;send OK
			ldi	ZH,HIGH(text_setname*2)
			call	host_flashtext			;write to BTM
			ret

setpin:			ldi	ZL,LOW(text_setpin*2)		;send OK
			ldi	ZH,HIGH(text_setpin*2)
			call	host_flashtext			;write to BTM
			ret

setspeed:		ldi	ZL,LOW(text_setspeed*2)		;send OK
			ldi	ZH,HIGH(text_setspeed*2)
			call	host_flashtext			;write to BTM
			ret

init_btm:		ldi	ZL,00
			ldi	ZH,2
			rcall	wait_ms
			rcall	set_br192
			ldi	ZL,200
			ldi	ZH,0
			rcall	wait_ms
			rcall	setname
			ldi	ZL,200
			ldi	ZH,0
			rcall	wait_ms
			rcall	setpin
			ldi	ZL,200
			ldi	ZH,0
			rcall	wait_ms
			rcall	setspeed
			ldi	YL,7
			ldi	YH,0
			ldi	XL,0x55
			call	eeprom_write
			ret

;-------------------------------------------------------------------------------
; set pointer / counter
;-------------------------------------------------------------------------------
set_rx:			clr	YL				;set buffer pointer to start
			clr	YH
			lds	r24,rxlen_l			;get RXLEN
			lds	r25,rxlen_h
			ret

set_tx:			clr	YL				;set buffer pointer to start
			clr	YH
			lds	r24,txlen_l			;get RXLEN
			lds	r25,txlen_h
			ret

;-------------------------------------------------------------------------------
; write a serial message
;-------------------------------------------------------------------------------
host_flashtext:		lpm	XL,Z+
			cpi	XL,0
			brne	host_ft1
			ret
host_ft1:		rcall	host_put
			rcall	host_get1			;wait for echo
			rjmp	host_flashtext

;-------------------------------------------------------------------------------
; text messages
;-------------------------------------------------------------------------------
text_setspeed:		.db	"ATL6",0x0d,0x0a,0,0
text_setname:		.db	"ATN=UPROG2",0x0d,0x0a,0,0
text_setpin:		.db	"ATP=55309",0x0d,0x0a,0

