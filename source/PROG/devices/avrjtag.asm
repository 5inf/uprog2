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

;------------------------------------------------------------------------------
; init + exit
;------------------------------------------------------------------------------
avrjtag_init:		call	jtag_init
			ldi	XL,1
			rcall	avrjtag_setreset
			jmp	main_loop_ok


avrjtag_exit:		ldi	XL,1
			rcall	avrjtag_setreset
			call	jtag_exit
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; force break + run
;------------------------------------------------------------------------------
avrjtag_break:		ldi	r16,0x08
			rcall	avrjtag_irshift		
			jmp	main_loop_ok

avrjtag_run:		ldi	r16,0x09
			rcall	avrjtag_irshift		
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; AVR reset 
; PAR4: 0=run 1=reset
;------------------------------------------------------------------------------
avrjtag_reset:		mov	XL,r19
			rcall	avrjtag_setreset
			jmp	main_loop_ok


avrjtag_setreset:	ldi	r16,0x0C		;AVR_RESET
			rcall	avrjtag_irshift		
			mov	r16,XL
			ldi	r24,1
			rjmp	avrjtag_drshift		


;------------------------------------------------------------------------------
; AVR 16 bit instruction 
; PAR1/PAR2 = instruction
; PAR3=Backsteps
;------------------------------------------------------------------------------
avrjtag_instr:		movw	r4,r16
			movw	r6,r18
			ldi	r16,0x0A		;insert instruction
			rcall	avrjtag_irshift		
			movw	r16,r4
			ldi	r24,16
			rcall	avrjtag_drshift
			mov	XL,r6
			rcall	avrjtag_jback		
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; readout PC with PC correct
; PAR3=Backsteps
;------------------------------------------------------------------------------
avrjtag_readpc:		mov	XL,r18
			rcall	avrjtag_jback
			ldi	r16,0x0A		;insert instruction
			rcall	avrjtag_irshift		
			ldi	r18,0xff
			ldi	r19,0xff
avrjtag_readpc1:	clr	r16
			clr	r17
			ldi	r24,32
			rcall	avrjtag_drshift		
			call	gen_wres		;store data
			jmp	main_loop_ok			


;------------------------------------------------------------------------------
; a 2 Word NOP with PC correct
;------------------------------------------------------------------------------
avrjtag_dmy32:		ldi	XL,3
			rcall	avrjtag_jback
			ldi	r16,0x0A		;insert instruction
			rcall	avrjtag_irshift		
			clr	r16
			clr	r17
			movw	r18,r16
			ldi	r24,32
			rjmp	avrjtag_drshift		

avrjtag_nop32:		rcall	avrjtag_dmy32
			jmp	main_loop_ok					

;------------------------------------------------------------------------------
; jump back via AVR instruction, XL=steps
;------------------------------------------------------------------------------
avrjtag_jback:		push	XL
			ldi	r16,0x0A		;insert instruction
			rcall	avrjtag_irshift		
			pop	XL
			ldi	r16,0x00
			sub	r16,XL
			ldi	r17,0xCF
			ldi	r24,16
			rjmp	avrjtag_drshift		

;------------------------------------------------------------------------------
; read OCD register
; PAR3 = Backsteps
; PAR4 = Register
;------------------------------------------------------------------------------
avrjtag_read_ocd:	movw	r6,r18			;save param
			ldi	r16,0x0B		;R/W OCD register
			rcall	avrjtag_irshift		
			mov	r16,r7			;register num
			andi	r16,0x0F		;read
			ldi	r24,5
			rcall	avrjtag_drshift		;latch register address
			clr	r16
			clr	r17
			mov	r18,r7
			andi	r18,0x0F

avrjtag_rwocd_e:	ldi	r24,21
			rcall	avrjtag_drshift		;get data
			call	gen_wres		;store data
			rcall	avrjtag_dmy32
			mov	XL,r6
			rcall	avrjtag_jback
			rcall	avrjtag_dmy32
			jmp	main_loop_ok			
			

;------------------------------------------------------------------------------
; write OCD register
; PAR4 = Register
; PAR3 = Backsteps
; PAR1/2 = Value
;------------------------------------------------------------------------------
avrjtag_write_ocd:	movw	r4,r16			;save data
			movw	r6,r18			;save param			
			ldi	r16,0x0B		;R/W OCD register
			rcall	avrjtag_irshift		
			mov	r16,r7			;regnum
			ori	r16,0x10		;write
			movw	r16,r4			;value
			rjmp	avrjtag_rwocd_e

			
;------------------------------------------------------------------------------
; PROG enable
;------------------------------------------------------------------------------
avrjtag_prgen:		ldi	r16,0x04		;insert instruction
			rcall	avrjtag_irshift		
			ldi	r16,0x70
			ldi	r17,0xA3
			ldi	r24,16
			rcall	avrjtag_drshift		
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; programming command
; PAR3/4 = Value
;------------------------------------------------------------------------------
avrjtag_pcmd:		movw	r6,r18
			ldi	r16,0x05		;CMD
			rcall	avrjtag_irshift		
			movw	r16,r6
			ldi	r24,15
			rcall	avrjtag_drshift	
			jmp	main_loop_ok			

avrjtag_pcmdr:		movw	r16,r18
			ldi	r24,15
			rcall	avrjtag_drshift	
			call	gen_wres		;store data
			jmp	main_loop_ok			

;------------------------------------------------------------------------------
; write page date (pageload)
; PAR4 = bytes in page
;------------------------------------------------------------------------------
avrjtag_wpage:		mov	r6,r19
			call	api_resetptr
			ldi	r16,0x06		;pageload
			rcall	avrjtag_irshift		
			mov	r24,r6
			call	jtag_wshift
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read page date (pageload)
; PAR4 = bytes in page
;------------------------------------------------------------------------------
avrjtag_rpage:		mov	r6,r19
			call	api_resetptr
			ldi	r16,0x07		;pageread
			rcall	avrjtag_irshift
			mov	r24,r6
			call	jtag_rshift
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read ID register
;------------------------------------------------------------------------------
avrjtag_read_id:	ldi	r16,0x01		;IDR
			rcall	avrjtag_irshift		
			clr	r16
			clr	r17
			movw	r18,r16			
			ldi	r24,32
			rcall	avrjtag_drshift		
			call	gen_wres		;store data
			jmp	main_loop_ok			

;------------------------------------------------------------------------------
; read EEPROM
; PAR3/4 = Addr
; PAR1 = num
;------------------------------------------------------------------------------
avrjtag_read_ee:	movw	r6,r18
			mov	r4,r16
			call	api_resetptr
			
			ldi	r16,0x05		;IDR
			rcall	avrjtag_irshift		

avrjtag_read_ee_1:	ldi	r17,0x07		;addrh		
			mov	r16,r7
			ldi	r24,15
			rcall	avrjtag_drshift	
			
			ldi	r17,0x03		;addrl		
			mov	r16,r6
			ldi	r24,15
			rcall	avrjtag_drshift	

			ldi	r17,0x33		;addrl		
			mov	r16,r6
			ldi	r24,15
			rcall	avrjtag_drshift	

			ldi	r17,0x32		;read		
			rcall	avrjtag_dr15	

			ldi	r17,0x33		;read		
			rcall	avrjtag_dr15	
			
			mov	XL,r20
			call	api_buf_bwrite
			
			add	r6,const_1
			adc	r7,const_0
			
			dec	r4
			brne	avrjtag_read_ee_1
			
			jmp	main_loop_ok			


;------------------------------------------------------------------------------
; write EEPROM
; PAR3/4 = Addr
; PAR1 = num bytes
;------------------------------------------------------------------------------
avrjtag_write_ee:	movw	r6,r18			;store addr
			mov	r8,r16			;store num
			
			call	api_resetptr
						
			ldi	r16,0x05		;IDR
			rcall	avrjtag_irshift		

avrjtag_write_ee_0:	ldi	r17,0x07		;addrh		
			mov	r16,r7
			ldi	r24,15
			rcall	avrjtag_drshift	
			
avrjtag_write_ee_1:	ldi	r17,0x03		;addrl		
			mov	r16,r6
			ldi	r24,15
			rcall	avrjtag_drshift	
			
			call	api_buf_bread
			mov	r16,XL
			ldi	r17,0x13
			ldi	r24,15
			rcall	avrjtag_drshift	

			ldi	r17,0x37		;latch	
			rcall	avrjtag_dr15	

			ldi	r17,0x77		;latch		
			rcall	avrjtag_dr15	

			ldi	r17,0x37		;latch		
			rcall	avrjtag_dr15	

			add	r6,const_1
			adc	r7,const_0
			dec	r8
			brne	avrjtag_write_ee_1
			
			ldi	r17,0x33		;write		
			rcall	avrjtag_dr15	

			ldi	r17,0x31		;write		
			rcall	avrjtag_dr15	

			ldi	r17,0x33		;write		
			rcall	avrjtag_dr15	

			ldi	r17,0x33		;write		
			rcall	avrjtag_dr15	

			ldi	ZL,9
			ldi	ZH,0
			call	api_wait_ms
			
			jmp	main_loop_ok			


avrjtag_dr15:		clr	r16
			ldi	r24,15
			rjmp	avrjtag_drshift	


;------------------------------------------------------------------------------
; some used shifts
; r16-r19 = IN
; r20-r23 = OUT
;------------------------------------------------------------------------------
avrjtag_irshift:	set			;IR shift
			ldi	r24,4
			jmp	jppc_shift

avrjtag_drshift16:	ldi	r24,16
avrjtag_drshift:	clt			;DR shift
			jmp	jppc_shift
			
			
			