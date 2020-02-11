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

.equ		PDI_CLK		= SIG1
.equ		PDI_DATA	= SIG2

.macro SEND_PDI
			ldi	XL,@0
			rcall	pdi_send
.endm

;------------------------------------------------------------------------------
; init
;------------------------------------------------------------------------------
pdi_init:		call	api_resetptr		;set ptr
			rcall	pdi_disable_int_2
			cbi	CTRLPORT,PDI_DATA
			cbi	CTRLPORT,PDI_CLK
			sbi	CTRLDDR,PDI_DATA
			sbi	CTRLDDR,PDI_CLK
			call	api_vcc_on
			ldi	XL,0x00			;both low
			mov	r4,XL
			ldi	XL,0x01			;CLK HI, DATA LO
			mov	r5,XL
			ldi	XL,0x02			;CLK LO, DATA HI
			mov	r6,XL
			ldi	XL,0x03			;both HI
			mov	r7,XL

			ldi	ZL,50
			ldi	ZH,0
			call	api_wait_ms
					
			sbi	CTRLPORT,PDI_CLK	;reset high
						
			ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			cbi	CTRLPORT,PDI_CLK	;reset low
			
			rcall	pdi_enable		;init pdi

			SEND_PDI 0x82
			
			
			rcall	pdi_receive		
			rcall	pdi_wait_10us

			;put device into reset
			SEND_PDI 0xC1
			SEND_PDI 0x59

			;set guard time to 8 bits
			SEND_PDI 0xC2
			SEND_PDI 0x04

			;send NVM key
			SEND_PDI 0xE0			;KEY		
			SEND_PDI 0xFF			
			SEND_PDI 0x88			
			SEND_PDI 0xD8			
			SEND_PDI 0xCD			
			SEND_PDI 0x45			
			SEND_PDI 0xAB			
			SEND_PDI 0x89			
			SEND_PDI 0x12			
		
			;check for NVM ready
			ldi	r19,10			;max tries
pdi_init_wn:
			SEND_PDI 0x80
			rcall	pdi_receive				
			rcall	pdi_wait_10us
			cpi	XL,0x02
			breq	pdi_init_2
			dec	r19
			brne	pdi_init_wn
		
			ldi	r16,0x42
			jmp	main_loop
			
pdi_init_2:		rcall	pdi_nvm_cmd

			ldi	r20,0x01		;MSB
			ldi	r21,0x00
			ldi	r22,0x00
			ldi	r23,0x90		;LSB
			rcall	pdi_set_ptr		

			ldi	r24,3			;set counter
			ldi	r25,0
			rcall	pdi_set_repeat

			SEND_PDI	0x24		;LD *(ptr++)

			rjmp	pdi_read_mem_1		;receive bytes


;------------------------------------------------------------------------------
; run device
;------------------------------------------------------------------------------
pdi_exit:		rcall	pdi_disable_int_2
			out	CTRLPORT,const_0	;-> all zero
			call	api_vcc_off
			out	CTRLDDR,const_0		;-> tristate
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; NVM lesen (2K)
; PAR1-4 = address
;------------------------------------------------------------------------------
pdi_read_mem:		rcall	pdi_disable_int
			call	api_resetptr
			ldi	r24,0x43		;READ NVM command
			rcall	pdi_nvm_cmd
			movw	r20,r16			;copy address
			movw	r22,r18
			ldi	r24,0			;set counter
			ldi	r25,8
			rcall	pdi_set_ptr
			rcall	pdi_set_repeat
			SEND_PDI	0x24		;LD *(ptr++)
			
pdi_read_mem_1:		rcall	pdi_receive		
			call	api_buf_bwrite
			sbiw	r24,1
			brne	pdi_read_mem_1
pdi_ok:			rcall	pdi_enable_int		;enable int
			cbi	CTRLPORT,5
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; fuses lesen
;------------------------------------------------------------------------------
pdi_read_fuses:		rcall	pdi_disable_int
			call	api_resetptr
			ldi	r24,0x43		;READ NVM command
			rcall	pdi_nvm_cmd
			
			ldi	r20,0x00		;LSB
			ldi	r21,0x8F
			ldi	r22,0x00
			ldi	r23,0x20		;MSB
			rcall	pdi_set_ptr		

			ldi	r24,8			;set counter
			ldi	r25,0
			rcall	pdi_set_repeat

			SEND_PDI	0x24		;LD *(ptr++)

			rjmp	pdi_read_mem_1		;receive bytes

;------------------------------------------------------------------------------
; main flash erase
;------------------------------------------------------------------------------
pdi_erase_main:		rcall	pdi_disable_int
			ldi	r24,0x20		;erase appl. section
			rcall	pdi_nvm_cmd

			SEND_PDI	0x4c		;write
			mov	XL,r19			;LSB
			rcall	pdi_send
			mov	XL,r18
			rcall	pdi_send
			mov	XL,r17
			rcall	pdi_send
			mov	XL,r16
			rcall	pdi_send
			rcall	pdi_nvm_wready
			rjmp	pdi_ok


;------------------------------------------------------------------------------
; boot erase
;------------------------------------------------------------------------------
pdi_erase_boot:		rcall	pdi_disable_int
			ldi	r24,0x68		;erase boot section
			rcall	pdi_nvm_cmd

			SEND_PDI	0x4c		;write
			mov	XL,r19			;LSB
			rcall	pdi_send
			mov	XL,r18
			rcall	pdi_send
			mov	XL,r17
			rcall	pdi_send
			mov	XL,r16
			rcall	pdi_send
			rcall	pdi_nvm_wready
			rjmp	pdi_ok


;------------------------------------------------------------------------------
; eeprom erase
;------------------------------------------------------------------------------
pdi_erase_eeprom:	rcall	pdi_disable_int

			ldi	r24,0x30		;erase eeprom
			rcall	pdi_nvm_cmd

			rcall	pdi_nvm_cmdex
			rcall	pdi_nvm_wready

			sbi	CTRLDDR,5
			sbi	CTRLPORT,5

			rcall	pdi_nvm_wready

			
			rjmp	pdi_ok


;------------------------------------------------------------------------------
; flash program
; Param 1-3 = Address
; Param4 = pages (256W -> 4, 128W -> 8)
;------------------------------------------------------------------------------
pdi_prog_main:		rcall	pdi_disable_int
			call	api_resetptr
			mov	r15,r19
			
pdi_prog_main_1:	ldi	r24,0x26		;erase flash page buffer
			rcall	pdi_nvm_cmd
			rcall	pdi_nvm_cmdex
			rcall	pdi_nvm_wready

			ldi	r24,0x23		;load flash page buffer
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			clr	r23			;this is always zero
			rcall	pdi_set_ptr
			
			ldi	r24,0
			ldi	r25,2
			cpi	r19,0x04		;256W page
			breq	pdi_prog_main_2
			ldi	r25,1

pdi_prog_main_2:	rcall	pdi_set_repeat

			SEND_PDI	0x64		;st *(ptr++)

pdi_prog_main_3:	call	api_buf_bread
			rcall	pdi_send
			sbiw	r24,1
			brne	pdi_prog_main_3	

			rcall	pdi_wait_10us
			rcall	pdi_wait_10us

			ldi	r24,0x24		;write page
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			clr	r23			;this is always zero
			rcall	pdi_set_ptr				

			SEND_PDI	0x64		;st *(ptr++)
			SEND_PDI	0x00		;dummy data
			
			rcall	pdi_nvm_wready
			
			mov	XL,r19
			lsr	XL
			
			add	r18,XL
			adc	r17,const_0
			adc	r16,const_0
			
			dec	r15
			brne	pdi_prog_main_1
			
			rjmp	pdi_ok


;------------------------------------------------------------------------------
; boot program
; Param 1-3 = Address
; Param4 = pages (256W -> 4, 128W -> 8)
;------------------------------------------------------------------------------
pdi_prog_boot:		rcall	pdi_disable_int
			call	api_resetptr
			mov	r15,r19
			
pdi_prog_boot_1:	ldi	r24,0x26		;erase flash page buffer
			rcall	pdi_nvm_cmd
			rcall	pdi_nvm_cmdex
			rcall	pdi_nvm_wready

			ldi	r24,0x23		;load flash page buffer
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			clr	r23			;this is always zero
			rcall	pdi_set_ptr
			
			ldi	r24,0
			ldi	r25,2
			cpi	r19,0x04		;256W page
			breq	pdi_prog_boot_2
			ldi	r25,1

pdi_prog_boot_2:	rcall	pdi_set_repeat

			SEND_PDI	0x64		;st *(ptr++)

pdi_prog_boot_3:	call	api_buf_bread
			rcall	pdi_send
			sbiw	r24,1
			brne	pdi_prog_boot_3	

			rcall	pdi_wait_10us
			rcall	pdi_wait_10us

			ldi	r24,0x2C		;write page
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			clr	r23			;this is always zero
			rcall	pdi_set_ptr				

			SEND_PDI	0x64		;st *(ptr++)
			SEND_PDI	0x00		;dummy data
			
			rcall	pdi_nvm_wready
			
			mov	XL,r19
			lsr	XL
			
			add	r18,XL
			adc	r17,const_0
			adc	r16,const_0
			
			dec	r15
			brne	pdi_prog_boot_1
			
			rjmp	pdi_ok

;------------------------------------------------------------------------------
; eeprom program
; Param 1-3 = Address
; Param4 = pages (a 32 bytes)
;------------------------------------------------------------------------------
pdi_prog_eeprom:	rcall	pdi_disable_int
			call	api_resetptr
			mov	r15,r19
			clr	r19
			
pdi_prog_eeprom_1:	ldi	r24,0x36		;erase eeprom page buffer
			rcall	pdi_nvm_cmd
			rcall	pdi_nvm_cmdex
			rcall	pdi_nvm_wready

			ldi	r24,0x33		;load eeprom page buffer
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			rcall	pdi_set_ptr
			
			ldi	r24,32
			ldi	r25,0

pdi_prog_eeprom_2:	rcall	pdi_set_repeat

			SEND_PDI	0x64		;st *(ptr++)

pdi_prog_eeprom_3:	call	api_buf_bread
			rcall	pdi_send
			sbiw	r24,1
			brne	pdi_prog_eeprom_3	

			rcall	pdi_wait_10us
			rcall	pdi_wait_10us

			ldi	r24,0x35		;erase+write page
			rcall	pdi_nvm_cmd

			movw	r20,r16
			movw	r22,r18
			rcall	pdi_set_ptr				

			SEND_PDI	0x64		;st *(ptr++)
			SEND_PDI	0x00		;dummy data
			
			rcall	pdi_nvm_wready
			
			ldi	XL,0x20
			
			add	r19,XL
			adc	r18,const_0
			adc	r17,const_0
			adc	r16,const_0
			
			dec	r15
			brne	pdi_prog_eeprom_1
			
			rjmp	pdi_ok

;------------------------------------------------------------------------------
; write fuse
; Param 1 = fuse no
; Param 4 = fuse data 
;------------------------------------------------------------------------------
pdi_prog_fuse:		rcall	pdi_disable_int
			call	api_resetptr
			
			ldi	r24,0x4C		;write fuse
			rcall	pdi_nvm_cmd
			
			SEND_PDI	0x4c
			ldi	XL,0x20
			add	XL,r16
			rcall	pdi_send

			SEND_PDI	0x00
			SEND_PDI	0x8f
			SEND_PDI	0x00
	
			mov	XL,r19	
			rcall	pdi_send

			rcall	pdi_nvm_wready
			
			rjmp	pdi_ok

;------------------------------------------------------------------------------
; set pointer
;------------------------------------------------------------------------------
pdi_set_ptr:		SEND_PDI	0x6B
			mov	XL,r23			;LSB
			rcall	pdi_send
			mov	XL,r22
			rcall	pdi_send
			mov	XL,r21
			rcall	pdi_send
			mov	XL,r20
			rcall	pdi_send
			ret			

;------------------------------------------------------------------------------
; set repeat (16 bit counter)
;------------------------------------------------------------------------------
pdi_set_repeat:		SEND_PDI	0xA1
			sbiw	r24,1	
			mov	XL,r24
			rcall	pdi_send
			mov	XL,r25
			rcall	pdi_send
			adiw	r24,1
			ret			

;------------------------------------------------------------------------------
; enable PDI interface
;------------------------------------------------------------------------------
pdi_enable:		push	XL
			ldi	XL,60
pdi_enable_1:		dec	XL
			brne	pdi_enable_1
			out	CTRLPORT,r6		;data hi, clk lo
			ldi	XL,60
pdi_enable_1a:		dec	XL
			brne	pdi_enable_1a
			
			ldi	XL,20			;20 pulses
pdi_enable_2:		out	CTRLPORT,r6		;data hi, clk low
			rcall	pdi_w9
			out	CTRLPORT,r7		;data hi, clk hi
			rcall	pdi_w7
			dec	XL
			brne	pdi_enable_2
			pop	XL
			ret
		
		
;------------------------------------------------------------------------------
; write nvm cmd
; r24=cmd
;------------------------------------------------------------------------------
pdi_nvm_cmd:		SEND_PDI	0x4c
			SEND_PDI	0xca
			SEND_PDI	0x01
			SEND_PDI	0x00
			SEND_PDI	0x01
			mov	XL,r24
			rcall	pdi_send
			ret			

;------------------------------------------------------------------------------
; set nvm cmdex
; r24=cmd
;------------------------------------------------------------------------------
pdi_nvm_cmdex:		SEND_PDI	0x4c
			SEND_PDI	0xcb
			SEND_PDI	0x01
			SEND_PDI	0x00
			SEND_PDI	0x01
			SEND_PDI	0x01	;set CMDEX
			ret			
		
;------------------------------------------------------------------------------
; wit for nvm is ready
; r24=cmd
;------------------------------------------------------------------------------
pdi_nvm_wready:		pop	r10			;get return address
			pop	r11
			
pdi_nvm_wready_1:	SEND_PDI	0x0c		;LDS
			SEND_PDI	0xcf
			SEND_PDI	0x01
			SEND_PDI	0x00
			SEND_PDI	0x01
		
			rcall	pdi_receive				
			rcall	pdi_wait_10us
			
			sbrc	XL,7			;skip if no busy
			rjmp	pdi_nvm_wready_1	;loop again

			push	r11			;put return address back
			push	r10

			ret			
		
			
;------------------------------------------------------------------------------
; send byte via the PDI interface (11 clocks per bit)
; XL=data
;------------------------------------------------------------------------------
pdi_send:		push	XH
			push	r16
			
			sbi	CTRLDDR,PDI_DATA	;set to output

			out	CTRLPORT,r4		;1 start-bit			
			ldi	XH,8			;1 bits to do
			clr	r16			;1 parity
			rcall	pdi_w7			;7
			out	CTRLPORT,r5		;1

			nop				;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			
pdi_send_1:		mov	r12,r4			;1 0 bit
			sbrc	XL,0			;1
			mov	r12,r6			;1 1 bit
			out	CTRLPORT,r12		;1
			rcall	pdi_w7			;7
			lsr	XL			;1 
			adc	r16,const_0		;1 parity
			sbi	CTRLPORT,PDI_CLK	;2
			
			nop				;1
			nop				;1
			dec	XH			;1
			brne	pdi_send_1		;2
			
			;parity bit		
			mov	r12,r4			;1 0 bit
			sbrc	r16,0			;1
			mov	r12,r6			;1 1 bit
			nop				;1
			nop				;1
			out	CTRLPORT,r12		;1
			rcall	pdi_w9			;7
			sbi	CTRLPORT,PDI_CLK	;2
			rcall	pdi_w9			;11
			
			;stop-bit 1
			out	CTRLPORT,r6		;1 bit
			rcall	pdi_w9			;7
			out	CTRLPORT,r7		;clk hi
			rcall	pdi_w9			;7

			;stop-bit 2
			out	CTRLPORT,r6		;1 bit
			rcall	pdi_w9			;7
			out	CTRLPORT,r7		;clk hi
			rcall	pdi_w9			;7

			cbi	CTRLDDR,PDI_DATA	;set to input
			cbi	CTRLPORT,PDI_DATA	;set to low (no pu)

			pop	r16
			pop	XH
			rjmp	pdi_wait_10us


			;wait 7/9 clocks
pdi_w11:		rjmp	pdi_w9
pdi_w9:			rjmp	pdi_w7
pdi_w7:			ret


pdi_pw1:		ldi	XL,30
pdi_pw1a:		dec	XL
			brne	pdi_pw1a
			ret
			
;------------------------------------------------------------------------------
; receive byte via the PDI interface
; XL=data
;------------------------------------------------------------------------------
pdi_receive:		push	ZL
			push	ZH
			clt				;no error

			ldi	ZL,0x00
			ldi	ZH,0x00

pdi_receive_1:		out	CTRLPORT,r4		;1
			rcall	pdi_w9			;9
			out	CTRLPORT,r5		;1
			sbis	CTRLPIN,PDI_DATA	;2
			rjmp	pdi_receive_2
			sbiw	ZL,1			;2
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			brne	pdi_receive_1		;2
			;timeout
			pop	ZH
			pop	ZL
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop	
			
			;n+3
pdi_receive_2:		ldi	XL,0x00			;1
			ldi	ZL,8			;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			
pdi_receive_3:		out	CTRLPORT,r4		;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			out	CTRLPORT,r5		;1
			lsr	XL			;1
			sbic	CTRLPIN,PDI_DATA	;2
			ori	XL,0x80
			dec	ZL			;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1			
			brne	pdi_receive_3		;2
			
			nop
			out	CTRLPORT,r4		;1	ignore parity
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			out	CTRLPORT,r5		;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1

			out	CTRLPORT,r4		;1	ignore stopp1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			out	CTRLPORT,r5		;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			
			out	CTRLPORT,r4		;1	ignore stopp2
			nop				;1
			nop				;1
			nop				;1
			nop				;1
			out	CTRLPORT,r5		;1
			nop				;1
			nop				;1
			nop				;1
			nop				;1

			pop	ZH
			pop	ZL
			ret					
			
;------------------------------------------------------------------------------
; wait n clocks
;------------------------------------------------------------------------------
pdi_wait_10us:		push	ZL
			ldi	ZL,4			; num of clocks
pdi_wait_10us_1:	out	CTRLPORT,r4		;1
			rcall	pdi_w9			;9
			out	CTRLPORT,r5		;1
			rcall	pdi_w9			;9
			dec	ZL
			brne	pdi_wait_10us_1
			pop	ZL
			ret
		
;------------------------------------------------------------------------------
; enable toggle int
;------------------------------------------------------------------------------
pdi_enable_int:		ldi	XL,0x02
			out	TCCR0A,XL
			ldi	XL,0x01
			out	TCCR0B,XL
			ldi	XL,200
			out	OCR0A,XL
			ldi	XL,0x04
			sts	TIMSK0,XL
			sei
			ret
					
;------------------------------------------------------------------------------
; disable toggle int
;------------------------------------------------------------------------------
pdi_disable_int:	sbis	PINC,0			;wait for clock low
			rjmp	pdi_disable_int
pdi_disable_int_1:	sbic	PINC,0			;wait for clock high
			rjmp	pdi_disable_int_1
pdi_disable_int_2:	cli
			ldi	XL,0x00
			out	TCCR0A,XL
			out	TCCR0B,XL
			out	OCR0A,XL
			sts	TIMSK0,XL
			ret
		