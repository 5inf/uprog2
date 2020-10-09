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

.equ		S12Z_FCDIV	= 0x380
.equ		S12Z_FOPT	= 0x38A
.equ		S12Z_FCNFG	= 0x384
.equ		S12Z_FPROT	= 0x388
.equ		S12Z_FSTAT	= 0x386

;-------------------------------------------------------------------------------
; set clock divider
;
; PAR1 = FCDIV value
; PAR2 = BDM speed select
; PAR3 = 
; PAR4 = 1-> set speed
;-------------------------------------------------------------------------------
s12z_entry:		mov	r6,r19
			mov	r19,r16			;save PAR2
			rcall	s12z_fktentry
			ldi	r18,HIGH(bdm_jtab)
			add	r17,r18
			out	EEARL,r17		;set speed

			ldi	XL,0x02			;enable ACK
			rcall	s12z_sendbyte
			call	bdm_wait_ack
			call	bdm_wait160

			ldi	XL,0x03			;disable ACK
			rcall	s12z_sendbyte
			call	bdm_wait160

			rcall	s12z_read_status
			sts	0x100,XL
			sts	0x101,XH

			call	bdm_wait160

			ldi	r23,0			;disable COP
			ldi	r25,0x06
			ldi	r24,0xCC
			ldi	XL,0x40
			rcall	s12z_write_byte

			call	bdm_wait160

			ldi	r23,0			;set FCLKDIV
			ldi	r25,0x03
			ldi	r24,0x80
			ldi	XL,0x0B
			rcall	s12z_write_byte

			call	bdm_wait160

			ldi	r23,0			;read FCLKDIV
			ldi	r25,0x03
			ldi	r24,0x80
			rcall	s12z_read_byte
			sts	0x100,XL


			ldi	XH,0xc4			;switch to 6,5 MHz
			ldi	XL,0x00
			sbrc	r6,0
			rcall	s12z_write_status
			
			jmp	main_loop_ok

s12z_test:		rcall	s12z_fktentry
			ldi	r23,0			;addrx
			ldi	r25,0x02
			ldi	r24,0xf0
			ldi	XL,0x10
			rcall	s12z_write_byte

			adiw	r24,2
			ldi	XL,0x1F
			rcall	s12z_write_byte

			ldi	r23,0			;read FSEC
			ldi	r25,0x03
			ldi	r24,0x81
			rcall	s12z_read_byte
			sts	0x100,XL
			
			jmp	main_loop_ok
			
;-------------------------------------------------------------------------------
; unsecure
;
; PAR1 =
; PAR2 =
; PAR3 = 
; PAR4 =
;-------------------------------------------------------------------------------
s12z_unsecure:		rcall	s12z_fktentry

			ldi	XL,0x95			;enable ACK
			rcall	s12z_sendbyte

			call	bdm_wait160

			ldi	XL,0x95			;enable ACK
			rcall	s12z_sendbyte

			ldi	ZL,0
			ldi	ZH,2
			call	api_wait_ms

			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; write to RAM
;
; PAR1 = ADDR low
; PAR2 = ADDR mid
; PAR3 = ADDR high
; PAR4 = 256 bytes blocks
;-------------------------------------------------------------------------------
s12z_write:		movw	r24,r16			;addr
			mov	r23,r18			;addr ext
			subi	r19,0xff		;+1
			rcall	s12z_fktentry		

s12z_write_1:		call	api_buf_lread			
			call	s12z_write_word		;write next data
			
s12z_write_2:		call	api_buf_lread			
			call	s12z_write_nword	;write next data
			
			cp	YH,r19
			brne	s12z_write_2
			jmp	main_loop_ok		;done


;-------------------------------------------------------------------------------
; execute code
;
; PAR1 = ADDR low
; PAR2 = ADDR high
; PAR3 = ADDR ext
; PAR4 =
;-------------------------------------------------------------------------------
s12z_exec:		rcall	s12z_fktentry		
			push	r18
			push	r17
			push	r16

			ldi	XL,0x04			;background
			rcall	s12z_sendbyte
			call	bdm_wait160

			ldi	XL,0x4b			;write PC
			rcall	s12z_sendbyte
			ldi	XL,0x00			;only 24 bit
			rcall	s12z_sendbyte
			pop	XL			;addr H
			rcall	s12z_sendbyte
			pop	XL			;addr M
			rcall	s12z_sendbyte
			pop	XL			;addr L
			rcall	s12z_sendbyte
			call	bdm_wait160
							
			ldi	XL,0x08			;GO
			rcall	s12z_sendbyte
			call	bdm_wait160

			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read memory
;
; PAR1 = ADDR low
; PAR2 = ADDR mid
; PAR3 = ADDR high
; PAR4 = 8 bytes blocks
;-------------------------------------------------------------------------------
s12z_read:		ldi	XL,0x00			;1024 words
			ldi	XH,0x04
			movw	r6,XL
			cpi	r19,0
			breq	s12z_read_0
			ldi	XL,4
			mul	XL,r19
			movw	r6,r0	

s12z_read_0:		sub 	r6,const_1
			sbc	r7,const_0
	
			rcall	s12z_fktentry		
			movw	r24,r16			;addr
			mov	r23,r18			;addr ext			
		
s12z_read_1:		call	s12z_read_word		;write next data
			call	api_buf_mwrite
			
s12z_read_2:		call	s12z_read_nword		;write next data
			call	api_buf_mwrite

			sub 	r6,const_1
			sbc	r7,const_0
			brne	s12z_read_2
			jmp	main_loop_ok		;done


;-------------------------------------------------------------------------------
; program flash/EEPROM
;
; PAR1 = ADDR low
; PAR2 = ADDR mid
; PAR3 = ADDR high
; PAR4 = 8 bytes blocks
;-------------------------------------------------------------------------------
s12z_prog_eeprom:	ldi	XL,0x11
			rjmp	s12z_prog_flash_0	

s12z_prog_flash:	ldi	XL,0x06
s12z_prog_flash_0:	mov	r7,XL
			movw	r24,r16			;addr
			mov	r23,r18			;addr ext
;			subi	r19,0xff		;+1
			mov	r6,r19
			rcall	s12z_fktentry
						
s12z_prog_flash_1:	ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x86			;AL
			rcall	s12z_sendbyte
			ldi	XL,0x30			;clear flags
			rcall	s12z_sendbyte
			call	bdm_wait16

			ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x82			;AL
			rcall	s12z_sendbyte
			ldi	XL,0x05			;FCCOBIX
			rcall	s12z_sendbyte
			call	bdm_wait16

			call	bdm_wait160

			ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x8c			;AL
			rcall	s12z_sendbyte
			mov	XL,r7			;PROG
			rcall	s12z_sendbyte
			call	bdm_wait16
			
			mov	XL,r23			;AH
			rcall	s12z_write_nbyte	
			mov	XL,r25			;AM
			rcall	s12z_write_nbyte	
			mov	XL,r24			;AL
			rcall	s12z_write_nbyte	

			ldi	r19,8
s12z_prog_flash_2:	call	api_buf_bread
			call	s12z_write_nbyte
			dec	r19
			brne	s12z_prog_flash_2

			ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x86			;AL
			rcall	s12z_sendbyte
			ldi	XL,0x80			;start program
			rcall	s12z_sendbyte
			call	bdm_wait16

s12z_prog_flash_p:	ldi	XL,0x30			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x86			;AL
			rcall	s12z_sendbyte
			call	bdm_wait16
			call	bdm_recv_byte
			andi	XL,0x80
			breq	s12z_prog_flash_p

			ldi	XL,8
			add	r24,XL
			adc	r25,const_0
			adc	r23,const_0
			
			dec	r6
			breq	s12z_prog_flash_e
			rjmp	s12z_prog_flash_1
			
s12z_prog_flash_e:	jmp	main_loop_ok
			



;-------------------------------------------------------------------------------
; debug subroutines
;-------------------------------------------------------------------------------
s12z_active:		rcall	s12z_fktentry		
			ldi	XL,0x04			;background
			rcall	s12z_sendbyte
			jmp	main_loop_ok

s12z_go:		rcall	s12z_fktentry		
			ldi	XL,0x08			;go
			rcall	s12z_sendbyte
			jmp	main_loop_ok

s12z_step:		rcall	s12z_fktentry		
			ldi	XL,0x09			;step (trace)
			rcall	s12z_sendbyte
			
	
s12z_readregs:		rcall	s12z_fktentry		
			ldi	r19,0x60		;read D0

s12z_readregs_1:	mov	XL,r19
			call	bdm_wait16
			rcall	s12z_sendbyte
			call	bdm_recv_word
			call	api_buf_mwrite
			call	bdm_recv_word
			call	api_buf_mwrite
	
			inc	r19
			cpi	r19,0x6D
			brne	s12z_readregs_1
			
			call	s12z_read_status	;add status word
			jmp	main_loop_ok	
	
s12z_writereg:		rcall	s12z_fktentry		
			subi	r19,0xC0		;+0x40
			rcall	s12z_sendbyte
		
			call	api_buf_lread			
			call	bdm_send_word

			call	api_buf_lread			
			call	bdm_send_word
				
			jmp	main_loop_ok	
	
	
;-------------------------------------------------------------------------------
; write byte
; r23,r25,r24=addr
; XL=data
;-------------------------------------------------------------------------------
s12z_write_byte:	push	XL
			ldi	XL,0x10			;CMD
			rcall	s12z_write_acmd
			pop	XL
			rcall	s12z_sendbyte
			jmp	bdm_wait16

s12z_write_nbyte:	push	XL
			ldi	XL,0x12			;CMD
			rcall	s12z_sendbyte
			pop	XL
			rcall	s12z_sendbyte
			jmp	bdm_wait16


s12z_read_byte:		ldi	XL,0x30			;CMD
			rcall	s12z_write_acmd
			call	bdm_wait16
			jmp	bdm_recv_byte
	
						
;-------------------------------------------------------------------------------
; write word
; r23,r25,r24=addr
; X=data
;-------------------------------------------------------------------------------
s12z_write_word:	push	XH
			push	XL
			ldi	XL,0x14			;CMD
			rcall	s12z_write_acmd

s12z_write_word_1:	pop	XL			;hi byte
			rcall	s12z_sendbyte
			pop	XL
			rcall	s12z_sendbyte
			jmp	bdm_wait16

s12z_write_nword:	push	XH
			push	XL
			ldi	XL,0x16			;CMD
			rcall	s12z_sendbyte
			rjmp	s12z_write_word_1

;-------------------------------------------------------------------------------
; write word
; r23,r25,r24=addr
; X=data
;-------------------------------------------------------------------------------
s12z_read_word:		ldi	XL,0x34			;CMD
			rcall	s12z_write_acmd
			call	bdm_wait16
			jmp	bdm_recv_word

s12z_read_nword:	ldi	XL,0x36			;CMD
			rcall	s12z_sendbyte
			call	bdm_wait16
			jmp	bdm_recv_word

;-------------------------------------------------------------------------------
; write addr + cmd
; r23,r25,r24=addr
; X=data
;-------------------------------------------------------------------------------
s12z_write_acmd:	rcall	s12z_sendbyte
			mov	XL,r23			;addrx
			rcall	s12z_sendbyte
			mov	XL,r25			;addrh
			rcall	s12z_sendbyte
			mov	XL,r24			;addrl
			jmp	bdm_send_byte						

;-------------------------------------------------------------------------------
; read and write status /X)
;-------------------------------------------------------------------------------
s12z_read_status:	ldi	XL,0x2d			;read BDCCSR
			rcall	s12z_sendbyte
			call	bdm_recv_word
			jmp	bdm_wait160

s12z_write_status:	push	XL
			push	XH
			ldi	XL,0x0d			;write BDCCSR
			rcall	s12z_sendbyte
			pop	XH
			pop	XL
			call	bdm_send_word
			jmp	bdm_wait160
	

s12z_sendbyte:		call	bdm_send_byte
			jmp	bdm_wait16
			
s12z_write_fstat:	push	XL
			ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x86			;AL
			rcall	s12z_sendbyte
			pop	XL
			rcall	s12z_sendbyte
			jmp	bdm_wait16

s12z_write_fccobix:	push	XL
			ldi	XL,0x10			;CMD
			rcall	s12z_sendbyte
			ldi	XL,0x00			;AH
			rcall	s12z_sendbyte
			ldi	XL,0x03			;AM
			rcall	s12z_sendbyte
			ldi	XL,0x82			;AL
			rcall	s12z_sendbyte
			pop	XL
			rcall	s12z_sendbyte
			jmp	bdm_wait16

s12z_fktentry:		call	api_resetptr
			jmp	bdm_prepare


			