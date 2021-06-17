;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2019-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.equ		OWR_SIG		= SIG1


;------------------------------------------------------------------------------
; init / exit
;------------------------------------------------------------------------------
onewire_init:		sbi	DDRD,6			;enable pull-up
			sbi	PORTD,6
onewire_init_1:		out	CTRLDDR,const_0
			out	CTRLPORT,const_0
			
			ldi	ZL,10			;startup time
			clr	ZH
			call	wait_ms

			rcall	onewire_reset_std
			jmp	main_loop
			
			

onewire_exit:		cbi	PORTD,6
			cbi	DDRD,6			;disable pull-up
			rjmp	onewire_init_1
			
			

;------------------------------------------------------------------------------
; read ROM ID
;------------------------------------------------------------------------------
onewire_read_id:	call	api_resetptr
			ldi	XL,0x33
			rcall	onewire_transfer_std
			ldi	r19,8	
onewire_read_id_1:	ldi	XL,0xFF
			rcall	onewire_transfer_std	
			call	api_buf_bwrite
			dec	r19
			brne	onewire_read_id_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read memory
;------------------------------------------------------------------------------
onewire_read_mem:	call	api_resetptr
			rcall	onewire_rskip		;RESET/INIT

			ldi	XL,0xF0			;READ MEMORY
			rcall	onewire_transfer_std

			ldi	XL,0x00			;AL
			rcall	onewire_transfer_std

			ldi	XL,0x00			;AH
			rcall	onewire_transfer_std

			ldi	r24,0
			ldi	r25,2
			
onewire_read_mem_1:	ldi	XL,0xFF
			rcall	onewire_transfer_std	
			call	api_buf_bwrite
			sbiw	r24,1
			brne	onewire_read_mem_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write memory
; PAR4=ADDR
;------------------------------------------------------------------------------
onewire_write_mem:	call	api_resetptr
			rcall	onewire_rskip		;RESET/INIT

			ldi	XL,0x0F			;write scratchpad
			rcall	onewire_transfer_std
			mov	XL,r19			;addrl
			rcall	onewire_transfer_std
			ldi	XL,0x00			;addrh
			rcall	onewire_transfer_std

			mov	r25,r19
			andi	r25,0x07
			ldi	r24,8
			sub	r24,r25
onewire_write_mem_1:	call	api_buf_bread
			rcall	onewire_transfer_std
			dec	r24
			brne	onewire_write_mem_1
			
			ldi	r24,8
onewire_write_mem_2:	rcall	onewire_read_std
			dec	r24
			brne	onewire_write_mem_2
							

onewire_write_cycle:	rcall	onewire_rskip		;RESET/INIT
			ldi	XL,0xAA			;read scratchpad
			rcall	onewire_transfer_std

			rcall	onewire_read_std	;T1
			mov	r20,XL
			rcall	onewire_read_std	;T2
			mov	r21,XL
			rcall	onewire_read_std	;ES
			mov	r22,XL
			
			ldi	r24,12
onewire_write_mem_3:	rcall	onewire_read_std
			dec	r24
			brne	onewire_write_mem_3


			rcall	onewire_rskip		;RESET/INIT
			ldi	XL,0x55			;copy scratchpad
			rcall	onewire_transfer_std

			mov	XL,r20
			rcall	onewire_transfer_std	;T1
			mov	XL,r21
			rcall	onewire_transfer_std	;T2
			mov	XL,r22
			rcall	onewire_transfer_std	;ES

			ldi	ZL,15
			ldi	ZH,0
			call	api_wait_ms
			sts	0x100,r20
			sts	0x101,r21
			sts	0x102,r22
			
			rcall	onewire_read_std
			rcall	onewire_read_std
			
			cpi	XL,0xaa
			brne	onewire_write_mem_4
			jmp	main_loop_ok
			
onewire_write_mem_4:	ldi	r16,0x44
			jmp	main_loop


;------------------------------------------------------------------------------
; reset + skip
;------------------------------------------------------------------------------
onewire_rskip:		rcall	onewire_reset_std	;RESET/INIT	
			ldi	XL,0xCC			;SKIP ROM
			rjmp	onewire_transfer_std


;------------------------------------------------------------------------------
; reset, r16=0 if OK, 0x41 if err
;------------------------------------------------------------------------------
onewire_reset_std:	ldi	XL,LOW(560*5)		;reset pulse (560 µs)
			ldi	XH,HIGH(560*5)
			sbi	CTRLDDR,OWR_SIG
onewire_reset_std_1:	sbiw	XL,1
			brne	onewire_reset_std_1	
			cbi	CTRLDDR,OWR_SIG

			ldi	XL,LOW(60*5)		;t_pdh (60 µs)
			ldi	XH,HIGH(60*5)
onewire_reset_std_2:	sbiw	XL,1
			brne	onewire_reset_std_2	

			
			ldi	r16,0x41		;no presence
			ldi	XL,LOW(240*3)		;presence detect (240 µs)
			ldi	XH,HIGH(240*3)
onewire_reset_std_3:	sbis	CTRLPIN,OWR_SIG
			clr	r16
			sbiw	XL,1
			brne	onewire_reset_std_3
			ret		


onewire_reset_fast:	ldi	XL,LOW(64*5)		;reset pulse (64 µs)
			ldi	XH,HIGH(64*5)
			sbi	CTRLDDR,OWR_SIG
onewire_reset_fast_1:	sbiw	XL,1
			brne	onewire_reset_fast_1	
			cbi	CTRLDDR,OWR_SIG


			ldi	XL,LOW(40)		;t_pdh (6 µs)
onewire_reset_fast_2:	dec	XL
			brne	onewire_reset_fast_2	

			
			ldi	r16,0x41		;no presence
			ldi	XL,LOW(80)		;reset pulse (560 µs)
onewire_reset_fast_3:	sbis	CTRLPIN,OWR_SIG
			clr	r16
			dec	XL
			brne	onewire_reset_fast_3
			ret
			

;------------------------------------------------------------------------------
; transfer byte, std modus
; XL = byte in / byte out
;------------------------------------------------------------------------------
onewire_read_std:	ldi	XL,0xff
onewire_transfer_std:	push	XH
			push	r20
			
			ldi	XH,8
			
onewire_tran_std_1:	sbi	CTRLDDR,OWR_SIG		;active
			ldi	r20,40			;6µs
onewire_tran_std_2:	dec	r20
			brne	onewire_tran_std_2
			sbrc	XL,0
			cbi	CTRLDDR,OWR_SIG		;inactive if 1
			lsr	XL
					
			ldi	r20,60			;9µs
onewire_tran_std_3:	dec	r20
			brne	onewire_tran_std_3
			
			sbic	CTRLPIN,OWR_SIG
			ori	XL,0x80
					
			ldi	r20,225			;45µs
onewire_tran_std_4:	dec	r20
			nop
			brne	onewire_tran_std_4
			cbi	CTRLDDR,OWR_SIG		;inactive if 0/1
		
			ldi	r20,133			;20µs inactive
onewire_tran_std_5:	dec	r20
			brne	onewire_tran_std_5
		
			dec	XH
			brne	onewire_tran_std_1	
			
			pop	r20
			pop	XH
			ret
			
			
			