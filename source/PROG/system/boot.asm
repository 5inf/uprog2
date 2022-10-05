;################################################################################
;#										#
;# UPROG2 universal programmer							#
;#										#
;# version 1.0									#
;#										#
;# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.equ		max_transfer	= 0x08		;2K max. transfer size (HIGH byte)
.equ		bl_version 	= 17		;bootloader version 1.5

.macro	hget
lpp:		lds	r0,UCSR0A
		sbrs	r0, RXC0
		rjmp	lpp
		lds	XL,UDR0
.endmacro


bl_start:		rjmp	bl_reset	;B+0	bootloader starts here
;-------------------------------------------------------------------------------
; API functions
;-------------------------------------------------------------------------------
api_wait_ms:		rjmp	wait_ms		;B+1	wait Z ms
api_vcc_on:		rjmp	vcc_on		;B+4	set vcc on
api_vcc_off:		rjmp	vcc_off		;B+5	set vcc off (all)
api_vcc_dis:		rjmp	vcc_dis		;B+6	disconnect vcc
api_resetptr:		rjmp	buf_resetptr	;B+7	reset buffer pointer
api_buf_bread:		rjmp	buf_read	;B+8	read a byte from buffer (XL)
api_buf_mread:		rjmp	buf_mread	;B+9	read a word from buffer (XH,XL)
api_buf_lread:		rjmp	buf_lread	;B+10	read a word from buffer (XL,XH)
api_buf_bwrite:		rjmp	buf_write	;B+11	write a byte to buffer (XL)
api_buf_mwrite:		rjmp	buf_mwrite	;B+12	write a word to buffer (XH,XL)
api_buf_lwrite:		rjmp	buf_lwrite	;B+13	write a word to buffer (XL,XH)
api_setvpp:		rjmp	setvoltage	;B+14	set vpp voltage
api_updatevpp:		rjmp	updatevoltage	;B+15	update vpp voltage
api_vpp_on:		rjmp	vpp_on		;B+16	switch vpp on
api_vpp_off:		rjmp	vpp_off		;B+17	swich vpp of
api_vpp_en:		rjmp	set_vpp		;B+18	enalble VPP
api_vpp_dis:		rjmp	dis_vpp		;B+19	disable VPP
api_set_3v3:		rjmp	set_3V3		;B+20	set VCC to 3,3V
api_set_5v:		rjmp	set_5V		;B+21	set VCC to 5V
api_set_rx:		rjmp	set_rx		;B+22	set ptr/ctr
api_set_tx:		rjmp	set_tx		;B+23	set ptr/ctr
api_host_put:		rjmp	host_put	;B+24	put byte to host
api_host_get:		rjmp	host_get	;B+25	get byte from host

;-------------------------------------------------------------------------------
; boot loader entry
;-------------------------------------------------------------------------------
bl_reset:		cli				;disable interrupts
			ldi	XL,0x00			;set constants
			mov	const_0,XL
			ldi	XL,0x01
			mov	const_1,XL
			ldi	XL,HIGH(stack)
			out	SPH,XL
			ldi	XL,LOW(stack)
			out	SPL,XL

			;init PORTs
			ldi	XL,0x00
			out	CTRLPORT,XL
			ldi	XL,0x00
			out	CTRLDDR,XL

			ldi	XL,0x1c
			out	DDRB,XL
			ldi	XL,0x10
			out	PORTB,XL

			ldi	XL,0x00
			out	DDRA,XL
			ldi	XL,0x00
			out	PORTA,XL

			ldi	XL,0x5A
			out	PORTD,XL
			ldi	XL,0x0A
			out	DDRD,XL

			;disable I2C
			sts	TWCR,const_0

			;wait a little bit
			ldi	ZL,0
			ldi	ZH,1
			rcall	wait_ms

			sbi	LEDPORT,BUSY_LED		;set red LED on

			sbic	PIND,4			
			rcall	set_br1250K			;set baudrate to 1250k
			
			sbis	PIND,4			
			rcall	set_br230K			;set baudrate to 230k
						
			rcall	host_flush
			
			ldi	ZL,0				;1s
			ldi	ZH,4
			rcall	wait_ms
			cbi	LEDPORT,BUSY_LED		;set red LED off

			rcall	host_flush
firstcmd:		hget
			cpi	XL,0xaa
			brcs	firstcmd
			rjmp	main_loop_04

;------------------------------------------------------------------------------
; now start
;------------------------------------------------------------------------------
main_cmderr1:		rjmp	boot_err1

main_loop_ok_noret:	clr	r16	
main_loop_noret:	cbi	LEDPORT,BUSY_LED		;set red LED off
			rjmp	main_loop_r2	

main_loop_ok:		clr	r16				;OK value
main_loop:		cbi	LEDPORT,BUSY_LED		;set red LED off
			rcall	set_rx
			
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
main_loop_wait:		hget					;get char
main_loop_04:		cpi	XL,0xaa
			brcs	main_cmderr1			;ignore all < 0xaa
			cpi	XL,0xae
			brcc	main_cmderr1			;ignore all > 0xad
			subi	XL,0xaa
			sts	tabselect,XL

			hget					;get byte
			mov	ZL,XL				;command
			hget					;get byte
			mov	r24,XL				;TXLEN LOW
			sts	txlen_l,XL			;store	
			hget					;get byte
			mov	r25,XL				;TXLEN HIGH
			sts	txlen_h,XL			;store	
			hget					;get byte
			sts	rxlen_l,XL			;RXLEN LOW
			hget					;get byte
			sts	rxlen_h,XL			;RXLEN HIGH

			hget			;get byte
			mov	r16,XL				;PAR 1
			sts	par_1,XL			;xPAR 1
			hget			;get byte
			mov	r17,XL				;PAR 2
			sts	par_2,XL			;xPAR 2
			hget			;get byte
			mov	r18,XL				;PAR 3
			sts	par_3,XL			;xPAR 3
			hget			;get byte
			mov	r19,XL				;PAR 4
			sts	par_4,XL			;xPAR 4

			;fill buffer if set
			rcall	set_tx
main_loop_10:		sbiw	r24,1
			brcs	main_loop_12
			hget
			rcall	buf_write
			rjmp	main_loop_10

main_cmderr2:		rjmp	boot_err1


main_loop_12:;		hget					;dummy value to prevent +++
			sbi	LEDPORT,BUSY_LED		;set red LED on
			hget
;			cpi	XL,0xcc
;			brne	main_cmderr2			

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
			ldi	YL,LOW(parbuffer)
			ldi	YH,HIGH(parbuffer)
			ldi	r21,0x80
main_loop_91:		hget
			st	Y+,XL
			dec	r21
			brne	main_loop_91
			rjmp	main_loop_ok

			;FD=read 128 Bytes param block
main_loop_100:		cpi	ZL,0xfd				;read param
			brne	main_loop_110
			ldi	YL,LOW(parbuffer)
			ldi	YH,HIGH(parbuffer)
			ldi	r21,0x80
main_loop_101:		ld	XL,Y+
			rcall	host_put
			dec	r21
			brne	main_loop_101
			rjmp	main_loop_ok

			;FE=set pull
main_loop_110:		cpi	ZL,0xfe				;set pull
			brne	main_loop_unk
			ldi	r20,6
main_loop_111:		lsl	r16
			lsl	r17
			dec	r20
			brne	main_loop_111
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
; put a single char to host
;------------------------------------------------------------------------------
host_put:		sbic	PIND,2			;wait for RTS is LOW
			rjmp	host_put
			lds	r0,UCSR0A
			sbrs	r0,UDRE0
			rjmp	host_put
			sts	UDR0,XL
			ret

;------------------------------------------------------------------------------
; get a single char from host
;------------------------------------------------------------------------------
host_flush:		lds	r0,UCSR0A
			sbrs	r0, RXC0
			ret
			lds	XL,UDR0
			rjmp	host_flush

;------------------------------------------------------------------------------
; get ADC values
;------------------------------------------------------------------------------
vout:			ldi	XL,0xe0				;internal reference, ADC0, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
vout_1:			lds	XL,ADCSRA
			andi	XL,0x40
			brne	vout_1
			ldi	ZL,1
			clr	ZH
			call	wait_ms

			ldi	ZL,50				;5V VBATT (is USB device)
			sbis	PIND,4
			rcall	read_vbatt
			sts	0x100,ZL

			rcall	read_vext
			sts	0x101,ZL
		
			rcall	read_vpp
			sts	0x102,ZL
			rjmp	main_loop_ok


volt:			lds	ZL,ADCH				;get value
			mul	ZL,XL				;* factor
			mov	ZL,r1
			sbrc	r0,7				;round
			inc	ZL
			ret

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

set_br500K:		ldi	XH,4			;500K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ldi	XL,0x02			;enable U2X
			sts	UCSR0A,XL
			ldi	XL,0x18			;enable RX/TX
			sts	UCSR0B,XL
			ldi	XL,0x0E			;2 stopp bits
			sts	UCSR0C,XL
			ldi	XH,4			;500K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ret

set_br1250K:		ldi	XH,1			;1250K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ldi	XL,0x02			;enable U2X
			sts	UCSR0A,XL
			ldi	XL,0x18			;enable RX/TX
			sts	UCSR0B,XL
			ldi	XL,0x0E			;2 stopp bits
			sts	UCSR0C,XL
			ldi	XH,1			;1250K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ret

set_br250K:		ldi	XH,9			;250K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ldi	XL,0x02			;enable U2X
			sts	UCSR0A,XL
			ldi	XL,0x18			;enable RX/TX
			sts	UCSR0B,XL
			ldi	XL,0x0E			;1 stopp bits
			sts	UCSR0C,XL
			ldi	XH,9			;250K
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
			ldi	XL,0x06			;2 stopp bits
			sts	UCSR0C,XL
			ldi	XH,10			;250K
			sts	UBRR0H,const_0
			sts	UBRR0L,XH
			ret

vcc_on:			rcall	read_vext
			cpi	ZL,15
			brcs	vcc_on_1
			rjmp	vcc_on_2		;extern driven or already on

vcc_on_1:		in	XL,PORTA
			andi	XL,0x01
			ori	XL,0xF0
			out	PORTA,XL
			in	XL,DDRA
			andi	XL,0x01
			ori	XL,0xF0
			out	DDRA,XL
			cbi	PORTD,3			;switch control
vcc_on_2:		lds	r17,pull_pol
			lds	r16,pull_sel
			in	XL,PORTD
			in	XH,DDRD
			andi	XH,0x3F
			out	DDRD,XH				;all off
			or	XH,r16				;sel
	
			andi	XL,0x3F
			or	XL,r17
			out	PORTD,XL
			out	DDRD,XH
			ret

vcc_off:		in	XL,PORTA
			andi	XL,0x01
			out	PORTA,XL
			ldi	XL,0xF1
			out	DDRA,XL
			in	r20,DDRD
			andi	r20,0x3f
			out	DDRD,r20
			in	r20,PORTD
			andi	r20,0x3f
			out	PORTD,r20
			ldi	XL,0x00
			ldi	ZL,10
			clr	ZH
			call	wait_ms
			out	DDRA,const_0			
			sbi	PORTD,3			;switch cotrol
			ret

vcc_dis:		out	DDRA,const_0
			sbi	PORTD,3			;switch cotrol
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
			ldi	r16,240			;pwm range
			sts	ICR1H,const_0
			sts	ICR1L,r16
			sts	OCR1AH,const_0
			sts	OCR1AL,r18
			ldi	r16,0x82
			sts	TCCR1A,r16
			ldi	r16,0x19
			sts	TCCR1B,r16
			sbi	DDRD,5
			pop	r16
			ret

dis_vpp:		ldi	r16,0x00
			sts	TCCR1A,r16
			ldi	r16,0x00
			sts	TCCR1B,r16
			sbi	DDRD,5
			cbi	PORTD,5
			ret

vpp_on:			sbi	DDRA,0
			sbi	PORTA,0
			ret	

vpp_off:		sbi	DDRA,0
			cbi	PORTA,0
			ret

set_5V:			cbi	PORTB,4
			sbi	PORTB,3
			ret

set_3V3:		sbi	PORTB,4
			cbi	PORTB,3
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
			ldi	XL,142
			rjmp	volt2

;------------------------------------------------------------------------------
; read vext and scale
;------------------------------------------------------------------------------
read_vext:		ldi	XL,0xe3				;internal reference, ADC3, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
read_vext_1:		lds	XL,ADCSRA
			andi	XL,0x40
			brne	read_vext_1
			ldi	XL,142
			rjmp	volt2

;------------------------------------------------------------------------------
; read vext and scale
;------------------------------------------------------------------------------
read_vbatt:		ldi	XL,0xe1				;internal reference, ADC3, left aligned
			sts	ADMUX,XL
			ldi	XL,0xc7				;min freq, start
			sts	ADCSRA,XL
read_vbatt_1:		lds	XL,ADCSRA
			andi	XL,0x40
			brne	read_vbatt_1
			ldi	XL,142
			rjmp	volt2

;------------------------------------------------------------------------------
; set pointer / counter
;------------------------------------------------------------------------------
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

boot_err1:		sbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,100
			ldi	ZH,0
			rcall	wait_ms
			cbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,100
			ldi	ZH,0
			rcall	wait_ms
			rjmp	boot_err1
			
boot_err2:		sbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,000
			ldi	ZH,1
			rcall	wait_ms
			cbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,000
			ldi	ZH,1
			rcall	wait_ms
			rjmp	boot_err2
			

boot_err3:		sbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,00
			ldi	ZH,2
			rcall	wait_ms
			cbi	LEDPORT,BUSY_LED		;set red LED on
			ldi	ZL,000
			ldi	ZH,2
			rcall	wait_ms
			rjmp	boot_err3
			
					