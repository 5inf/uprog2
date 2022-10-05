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
.equ		STM8_RESET	= SIG1
.equ		STM8_SWIM	= SIG2

;------------------------------------------------------------------------------
; swim initialisierung
;------------------------------------------------------------------------------
init_swim:		cbi	CTRLDDR,STM8_SWIM		;set to input
			sbi	CTRLDDR,STM8_RESET		;set reset to output
			sbi	CTRLPORT,STM8_SWIM		;SWIM HIGH (INPUT with pull-up)
			cbi	CTRLPORT,STM8_RESET		;RESET LOW
;			ldi	XL,0x02				;SWIM signal
;			mov	r4=XL
;			call	api_vcc_off
			ldi	ZL,50				;50ms
			clr	ZH
			call	wait_ms
			call	api_vcc_on
			sbi	CTRLDDR,STM8_SWIM		;SWIM HIGH
			ldi	ZL,20				;20ms
			clr	ZH
			call	wait_ms
			sbi	CTRLPORT,STM8_RESET		;RESET HIGH
			ldi	ZL,20				;20ms
			clr	ZH
			call	wait_ms
			call	api_vcc_on

init_swim_re:		cbi	CTRLPORT,STM8_RESET		;RESET LOW
			ldi	ZL,5				;5ms
			clr	ZH
			call	wait_ms

			;first pulse
			cbi	CTRLPORT,STM8_SWIM		;SWIM LOW
			ldi	ZL,2				;5ms
			clr	ZH
			call	wait_ms
			clr	r16
			sbi	CTRLPORT,STM8_SWIM		;SWIM HIGH

			;4 pulses at 0.5/0.5ms
			ldi	r21,4
init_swim_02:		ldi	ZL,LOW(2512)
			ldi	ZH,HIGH(2512)
init_swim_03:		sbiw	ZL,1
			brne	init_swim_03

			cbi	CTRLPORT,STM8_SWIM		;SWIM LOW

			ldi	ZL,LOW(2512)
			ldi	ZH,HIGH(2512)
init_swim_04:		sbiw	ZL,1
			brne	init_swim_04

			sbi	CTRLPORT,STM8_SWIM		;SWIM HIGH
			dec	r21
			brne	init_swim_02

			;4 pulses at 0.25/0.25ms
			ldi	r21,4
init_swim_06:		ldi	ZL,LOW(1256)
			ldi	ZH,HIGH(1256)
init_swim_07:		sbiw	ZL,1
			brne	init_swim_07

			cbi	CTRLPORT,STM8_SWIM		;SWIM LOW	

			ldi	ZL,LOW(1256)
			ldi	ZH,HIGH(1256)
init_swim_08:		sbiw	ZL,1
			brne	init_swim_08

			sbi	CTRLPORT,STM8_SWIM		;SWIM HIGH
			dec	r21
			brne	init_swim_06

			cbi	CTRLDDR,STM8_SWIM		;set to input

			clr	XL
			clr	XH
init_swim_09:		sbis	CTRLPIN,STM8_SWIM
			rjmp	init_swim_10
			adiw	XL,1
			brne	init_swim_09
			rjmp	init_swim_e1		;no sync

init_swim_10:		clr	r16

init_swim_11:		add	r16,const_1
			breq	init_swim_e2
			sbis	CTRLPIN,STM8_SWIM
			rjmp	init_swim_11
			sts	0x100,r16
			jmp	main_loop_ok

init_swim_e1:		ldi	r16,0x21
			jmp	main_loop

init_swim_e2:		ldi	r16,0x22
			jmp	main_loop

init_swim_ws:		ret

;------------------------------------------------------------------------------
; swim exit
;------------------------------------------------------------------------------
exit_swim:		cbi	CTRLPORT,STM8_SWIM		;SWIM LOW
			cbi	CTRLPORT,STM8_RESET		;RESET LOW
			sbi	CTRLDDR,STM8_SWIM		;set to output
			sbi	CTRLDDR,STM8_RESET
			call	api_vcc_off
			ldi	ZL,50			;20ms
			clr	ZH
			call	wait_ms
			cbi	CTRLDDR,STM8_SWIM		;set to input
			cbi	CTRLDDR,STM8_RESET
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write block
; r23=bytes
; r24/r25=addr
;------------------------------------------------------------------------------
swim_wblock:		push	r23
			set
			ldi	XL,0x40			;WOTF
			rcall	swim_send_cmd
			mov	XL,r23			;1 byte
			rcall	swim_send_byte
			ldi	XL,0x00			;AE byte
			rcall	swim_send_byte
			mov	XL,r25			;AH byte
			rcall	swim_send_byte
			mov	XL,r24			;AL byte
			rcall	swim_send_byte
swim_wblock_1:		call	api_buf_bread		;read buffer byte
			rcall	swim_send_byte
			dec	r23
			brne	swim_wblock_1
			pop	r23
			add	r24,r23
			adc	r25,const_0
			ret

;------------------------------------------------------------------------------
; write sequence
;------------------------------------------------------------------------------
swim_sequence:		call	api_resetptr
swim_sequence_1:	call	api_buf_bread		;number of bytes or code
			cpi	XL,0xa0
			brcc	swim_sequence_nodata
			mov	r23,XL
			ldi	XL,0x40			;WOTF
			rcall	swim_send_cmd
			mov	XL,r23			;bytes
			rcall	swim_send_byte
			subi	r23,0xfd		;+3 (address bytes)
swim_sequence_2:	call	api_buf_bread		;read buffer byte
			rcall	swim_send_byte
			dec	r23
			brne	swim_sequence_2
			rjmp	swim_sequence_1		;go on

swim_sequence_nodata:	breq	swim_sequence_wait
			jmp	main_loop_ok		;thats all

swim_sequence_wait:	call	api_buf_lread
			movw	ZL,XL
			call	api_wait_ms
			rjmp	swim_sequence_1		;go on

;------------------------------------------------------------------------------
; configure and release reset
;------------------------------------------------------------------------------
swim_config:		mov	r5,r16			;long
			mov	r4,r17			;short	
			mov	r6,r18			;sample
			ldi	XL,0x02			;SWIM bit
			mov	r8,XL
			set

			ldi	XL,0x00			;reset
			rcall	swim_send_cmd
			ldi	ZL,3
			ldi	ZH,0
			call	api_wait_ms


			;write CSR
			ldi	XL,0x40			;WOTF
			rcall	swim_send_cmd

			ldi	XL,0x01			;1 byte
			rcall	swim_send_byte
			ldi	XL,0x00			;AE byte
			rcall	swim_send_byte
			ldi	XL,0x7f			;AH byte
			rcall	swim_send_byte
			ldi	XL,0x80			;AL byte
			rcall	swim_send_byte
			ldi	XL,0xA1			;data byte
			rcall	swim_send_byte
			ldi	ZL,3
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,STM8_RESET		;realease reset
			ldi	ZL,25
			ldi	ZH,0
			call	api_wait_ms
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read Data
; par1/2/3	addr
;------------------------------------------------------------------------------
swim_read:		clr	YL
			ldi	YH,0x01
			ldi	r21,0x02		;enable STM8_SWIM PC interrupt
			sts	PCMSK2,r21

			ldi	r23,16			;blocks to do
			;block loop
swim_read_1:		set
			ldi	XL,0x20			;ROTF
			rcall	swim_send_cmd
			ldi	XL,0x80			;128 bytes default
			rcall	swim_send_byte
			mov	XL,r18			;AE byte
			rcall	swim_send_byte
			mov	XL,r17			;AH byte
			rcall	swim_send_byte
			mov	XL,r16			;AL byte
			clt
			rcall	swim_send_byte

			ldi	r25,0x80
swim_read_2:		rcall	swim_recv_byte
			st	Y+,XL
			dec	r25
			brne	swim_read_2

			ldi	XL,0x80
			add	r16,XL
			adc	r17,const_0
			adc	r18,const_0

			dec	r23
			brne	swim_read_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write data to RAM
;------------------------------------------------------------------------------
swim_wram:		mov	r25,r16
			clr	r24
			call	api_resetptr
swim_wram_01:		ldi	r23,0x80
			rcall	swim_wblock
			rcall	swim_wblock
			dec	r17
			brne	swim_wram_01
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; execute code
;------------------------------------------------------------------------------
swim_exec:		set
			ldi	XL,0x40			;WOTF
			rcall	swim_send_cmd
			ldi	XL,0x04			;4 bytes
			rcall	swim_send_byte
			ldi	XL,0x00			;AE byte
			rcall	swim_send_byte
			ldi	XL,0x7F			;AH byte
			rcall	swim_send_byte
			ldi	XL,0x00			;AL byte
			rcall	swim_send_byte
			ldi	r20,4			;write A reg and PC to zero
swim_exec_1:		rcall	swim_send_byte
			dec	r20
			brne	swim_exec_1

			;now set CPU to run mode
			ldi	XL,0x40			;WOTF
			rcall	swim_send_cmd
			ldi	XL,0x01			;1 byte
			rcall	swim_send_byte
			ldi	XL,0x00			;AE byte
			rcall	swim_send_byte
			ldi	XL,0x7f			;AH byte
			rcall	swim_send_byte
			ldi	XL,0x99			;AL byte
			rcall	swim_send_byte
			ldi	XL,0x00			;data byte
			rcall	swim_send_byte
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; swim send data in lowspeed mode
; XL = command / data
;------------------------------------------------------------------------------
swim_send_cmd:		ldi	ZH,HIGH(parity_table*2)
			mov	ZL,XL
			lpm	r22,Z
			swap	r22
			lsr	r22
			lsr	XL			;include startbit (zero)
			or	XL,r22
			ldi	XH,5
			rjmp	swim_send

swim_send_byte:		ldi	XH,10			;8 bits
			ldi	ZH,HIGH(parity_table*2)
			mov	ZL,XL
			lpm	r22,Z
			lsr	XL
			rol	r22	

swim_send:		sbi	CTRLPORT,STM8_SWIM	;2 SWIM HIGH
			sbi	CTRLDDR,STM8_SWIM	;2 SWIM OUTPUT

swim_send_1:		cbi	CTRLPORT,STM8_SWIM	;2 SWIM LOW
			;----------------------------
			sbrc	r4,0			;0x00 -> 3 clocks
			rjmp	swim_send_w1a
			sbrc	r4,1			;0x01 -> 5 clocks
			rjmp	swim_send_w1a
			sbrc	r4,2			;0x03 -> 7 clocks
			rjmp	swim_send_w1a
			sbrc	r4,3			;0x07 -> 9 clocks
			rjmp	swim_send_w1a
			;----------------------------
swim_send_w1a:		sbrc	XL,7			;1 
			out	CTRLPIN,r8		;1 set to one		

			lsr	r22
			rol	XL

			mov	r21,r5			;long
swim_send_w2:		dec	r21
			brne	swim_send_w2
			
			dec	XH
			breq	swim_send_w4	
			
swim_send_3:		sbi	CTRLPORT,STM8_SWIM	;2 SWIM HIGH
			;----------------------------
			sbrc	r4,0			;0x00 -> 3 clocks
			rjmp	swim_send_w3a
			sbrc	r4,1			;0x01 -> 5 clocks
			rjmp	swim_send_w3a
			sbrc	r4,2			;0x03 -> 7 clocks
			rjmp	swim_send_w3a
			sbrc	r4,3			;0x07 -> 9 clocks
			rjmp	swim_send_w3a
			;----------------------------
swim_send_w3a:		rjmp	swim_send_1		;2


swim_send_w4:		sbi	CTRLPORT,STM8_SWIM	;2 SWIM HIGH
			cbi	CTRLDDR,STM8_SWIM	;swim input

			;check ack
swim_send_as1:		sbic	CTRLPIN,STM8_SWIM	;wait for low
			rjmp	swim_send_as1
swim_send_as2:		sbis	CTRLPIN,STM8_SWIM	;wait for high
			rjmp	swim_send_as2
			brts	swim_sendw		;wait a little bit if T flag is set
			ret

swim_sendw:		mov	r21,r5			;42 approx 1 bit time
			lsl	r21
			lsl	r21
swim_send_w5:		dec	r21
			brne	swim_send_w5
			ret				;5


;------------------------------------------------------------------------------
; swim receive data in lowspeed mode
; 0 -> 44L + 4H
; 1 -> 4H + 44L
; XL = data
;------------------------------------------------------------------------------
swim_recv_byte:		ldi	r22,0x04		;PCIF flag
swim_recv_byte_1:	sbis	CTRLPIN,STM8_SWIM	;wait for high
			rjmp	swim_recv_byte_1
			out	PCIFR,r22		;clear flag
			ldi	r21,9			;8 data bits (+ start)

			;get start + 8 data bits
swim_recv_bl:		in	r20,PCIFR		;wait for pin change
			sbrs	r20,2			;skip if PC was detected
			rjmp	swim_recv_bl		;wait...
			mov	r20,r6
swim_recv_bla:		dec	r20
			brne	swim_recv_bla
			lsl	XL
			sbic	CTRLPIN,STM8_SWIM
			inc	XL			;set bit to one
			out	PCIFR,r22		;clear flag
			dec	r21
			brne	swim_recv_bl

			;wait for parity bit
swim_recv_pb:		in	r20,PCIFR		;wait for pin change
			sbrs	r20,2			;skip if PC was detected
			rjmp	swim_recv_pb		;wait...

			;wait a little bit until we send ack
			ldi	r21,25
swim_recv_wa:		dec	r21
			brne	swim_recv_wa

			;ACK
			cbi	CTRLPORT,STM8_SWIM		;2 SWIM LOW
			sbi	CTRLDDR,STM8_SWIM		;2 swim output
			nop
			nop
			sbi	CTRLPORT,STM8_SWIM		;2 SWIM HIGH
			nop
			nop
			cbi	CTRLDDR,STM8_SWIM		;swim input
			ret
