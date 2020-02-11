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

.equ		S08_FCDIV	= 0x1820
.equ		S08_FOPT	= 0x1821
.equ		S08_FCNFG	= 0x1823
.equ		S08_FPROT	= 0x1824
.equ		S08_FSTAT	= 0x1825
.equ		S08_FCMD	= 0x1826

.macro	s08_writereg
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		ldi	XL,@1
		call	bdm8_bwritef
.endm

;-------------------------------------------------------------------------------
; set clock divider
;
; PAR1 = FCDIV value
; PAR2 = BDM speed select
; PAR3 = 
; PAR4 =
;-------------------------------------------------------------------------------
s08_fdiv:		mov	r19,r16			;save PAR2
			call	bdm_prepare
			ldi	r18,HIGH(bdm_jtab)
			add	r17,r18
			out	EEARL,r17		;set speed

			ldi	XL,0xd5			;enable ACK
			call	bdm_send_byte

			call	bdm_wait_ack

;			call	bdm_wait16
;			ldi	XL,0xd6			;disable ACK
;			call	bdm_send_byte

			rcall	s08_clear_err		;clear err flags

			mov	XL,r19			;PAR1
			ldi	r22,LOW(S08_FCDIV)
			ldi	r23,HIGH(S08_FCDIV)
			call	bdm8_bwritef

			ldi	r22,LOW(S08_FSTAT)
			ldi	r23,HIGH(S08_FSTAT)
			call	bdm8_breadf

			subi	XL,0x80
			andi	XL,0xb0
			mov	r16,XL
s08_fdiv_2:		jmp	main_loop

;-------------------------------------------------------------------------------
; unsecure
;
; PAR1 =
; PAR2 =
; PAR3 = 
; PAR4 =
;-------------------------------------------------------------------------------
s08_unsecure:		call	bdm_prepare
			rcall	s08_clear_err		;clear err flags

			s08_writereg S08_FPROT,0xff	;unprotect all

			s08_writereg 0xfc00,0x00	;dummy write
			s08_writereg S08_FCMD,0x05	;blank check cmd
			rcall	s08_fexec		;wait for end

			ldi	r22,LOW(S08_FOPT)	;check for unlocked state
			ldi	r23,HIGH(S08_FOPT)
			call	bdm8_breadf
			sts	0x100,XL		;DEBUG - FOPT status
			andi	XL,0x03			;mask for 
			cpi	XL,0x02
			brne	s08_unsec_2
s08_unsec_1:		jmp	main_loop_ok		;OK, is unsecured

s08_unsec_2:		s08_writereg 0xfc00,0x00	;dummy write
			s08_writereg S08_FCMD,0x41	;mass erase cmd
			rcall	s08_fexec		;wait for end

			s08_writereg 0xfc00,0x00	;dummy write
			s08_writereg S08_FCMD,0x05	;blank check cmd
			rcall	s08_fexec		;wait for end

s08_unsec_r3:		ldi	r22,LOW(S08_FOPT)	;check for unlocked state
			ldi	r23,HIGH(S08_FOPT)
			call	bdm8_breadf
			sts	0x101,XL		;DEBUG - FOPT status
			andi	XL,0x03
			cpi	XL,0x02
			ldi	r16,0x10		;forced mass erase
			breq	s08_unsec_3
			ldi	r16,0x38		;no unsecure possible
s08_unsec_3:		jmp	main_loop		;OK, is unsecured

;-------------------------------------------------------------------------------
; mass erase
;
; PAR1 =
; PAR2 =
; PAR3 = 
; PAR4 =
;-------------------------------------------------------------------------------
s08_merase:		call	bdm_prepare
			rcall	s08_clear_err		;clear err flags

			s08_writereg S08_FPROT,0xff	;unprotect all
			s08_writereg 0xfc00,0x00	;dummy write into flash area
			s08_writereg S08_FCMD,0x41	;mass erase cmd

			rcall	s08_fexec		;wait for end

			;do blank check
			rcall	s08_clear_err		;clear err flags
			s08_writereg 0xfc00,0x00	;dummy write into flash area
			s08_writereg S08_FCMD,0x05	;blank check cmd
			call	s08_fexec		;wait for end
s08_merase_e:		jmp	main_loop

;-------------------------------------------------------------------------------
; program
;
; PAR1 = ADDR low
; PAR2 = ADDR high
; PAR3 = COUNT low
; PAR4 = COUNT high
;-------------------------------------------------------------------------------
s08_prog:		call	bdm_prepare
			movw	r24,r16			;addr
			call	api_resetptr		;reset pointer
			clr	r16

			rcall	s08_clear_err		;clear err flags
			s08_writereg S08_FPROT,0xff	;unprotect all

			ldi	XL,0x90			;background
			call	bdm_send_byte
			call	bdm_wait160

			ldi	XL,0x4c			;write HX
			call	bdm_send_byte
			movw	XL,r24			;addr
			sbiw	XL,1
			call	bdm_send_word
			call	bdm_wait160


s08_prog_1:		ldi	XL,0x50			;write next
			call	bdm_send_byte
			call	api_buf_bread
			call	bdm_send_byte
			call	bdm_wait160

			s08_writereg S08_FCMD,0x25	;PROG cmd
			rcall	s08_fexec		;exec and wait for done

			cpi	r16,0
			brne	s08_merase_e

			sub	r18,const_1		;loop counter
			sbc	r19,const_0
			brne	s08_prog_1

			jmp	main_loop_ok		;done

;-------------------------------------------------------------------------------
; write to RAM
;
; PAR1 = ADDR low
; PAR2 = ADDR high
; PAR3 = COUNT low
; PAR4 = COUNT high
;-------------------------------------------------------------------------------
s08_write:		call	bdm_prepare
			movw	r24,r16			;addr
			call	api_resetptr

s08_write_1:		call	bdm8_bwrite		;write next data

			sub	r18,const_1
			sbc	r19,const_0

			brne	s08_write_1
			jmp	main_loop_ok		;done


;-------------------------------------------------------------------------------
; execute code
;
; PAR1 = ADDR low
; PAR2 = ADDR high
; PAR3 =
; PAR4 =
;-------------------------------------------------------------------------------
s08_exec:		call	bdm_prepare

			ldi	XL,0x90			;background
			call	bdm_send_byte
			call	bdm_wait160

			ldi	XL,0x4b			;write PC
			call	bdm_send_byte
			movw	XL,r16			;addr
			call	bdm_send_word
			call	bdm_wait160

			ldi	XL,0x08			;GO
			call	bdm_send_byte
			call	bdm_wait160

			clr	r16
			jmp	main_loop

;-------------------------------------------------------------------------------
; read memory
;
; PAR1 = ADDR low
; PAR2 = ADDR high
; PAR3 = COUNT low
; PAR4 = COUNT high
;-------------------------------------------------------------------------------
s08_read:		call	bdm_prepare
			movw	r24,r16			;addr
			call	api_resetptr

			ldi	XL,0x90			;background
			call	bdm_send_byte
			call	bdm_wait160

			ldi	XL,0x4c			;write HX
			call	bdm_send_byte
			movw	XL,r24			;addr
			sbiw	XL,1
			call	bdm_send_word
			call	bdm_wait160

s08_read_1:		ldi	XL,0x70			;read next
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_byte
			call	api_buf_bwrite

			sub	r18,const_1
			sbc	r19,const_0
			brne	s08_read_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; get trim value
;
; PAR1 =
; PAR2 =
; PAR3 = 
; PAR4 =
;------------------------------------------------------------------------------
s08_trim:		cbi	CTRLPORT,SIG2		;BKGD LOW
			sbi	CTRLDDR,SIG2		;set BKGD
			ldi	ZL,2
			ldi	ZH,0
			call	api_wait_ms
			ldi	ZL,0
			ldi	ZH,0
			sbi	CTRLPORT,SIG2		;BKGD high
			nop
			nop
			nop
			nop
			cbi	CTRLDDR,SIG2		;release BKGD
s08_trim_1:		sbic	CTRLPIN,SIG2		;2 wait for sync
			rjmp	s08_trim_1		;wait

s08_trim_2:		inc	ZL			;1
			sbis	CTRLPIN,SIG2		;1/2 wait for sync end
			rjmp	s08_trim_2		;2 wait

			sts	0x102,ZL
			sts	0x103,ZH

			call	reinit_bdm_nf
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; subroutines
;-------------------------------------------------------------------------------
s08_clear_err:		ldi	XL,0x30
			ldi	r22,LOW(S08_FSTAT)
			ldi	r23,HIGH(S08_FSTAT)
			jmp	bdm8_bwritef

s08_fexec:		pop	r17			;return address
			pop	r16

			ldi	XL,0x80
			ldi	r22,LOW(S08_FSTAT)
			ldi	r23,HIGH(S08_FSTAT)
			call	bdm8_bwritef

			ldi	ZL,0
			ldi	ZH,0
s08_fexec_1:		push	ZL
			push	ZH
			ldi	r22,LOW(S08_FSTAT)
			ldi	r23,HIGH(S08_FSTAT)
			call	bdm8_breadf
			call	bdm_wait16
			pop	ZH
			pop	ZL
			sbrc	XL,7			;check FCCF
			rjmp	s08_fexec_2
			sbiw	ZL,1
			brne	s08_fexec_1
			ldi	r16,0x41		;time out status
			jmp	main_loop

s08_fexec_2:		movw	ZL,r16			;return address
			clr	r16			;OK
			ijmp				;return to caller


;-------------------------------------------------------------------------------
; debug subroutines
;-------------------------------------------------------------------------------
s08_active:		call	bdm_prepare
			ldi	XL,0x90			;background
			call	bdm_send_byte
			call	bdm_wait160
			jmp	main_loop_ok

s08_go:			call	bdm_prepare
			ldi	XL,0x08			;go
			call	bdm_send_byte
			call	bdm_wait160
			jmp	main_loop_ok

s08_write_regs:		call	api_resetptr
			call	bdm_prepare
			ldi	XL,0x48			;write A
			call	bdm_send_byte
			call	api_buf_bread
			call	bdm_send_byte
			call	bdm_wait160

			ldi	XL,0x49			;write CCR
			call	bdm_send_byte
			call	api_buf_bread
			call	bdm_send_byte
			call	bdm_wait160


			ldi	XL,0x4b			;write PC
			call	bdm_send_byte
			call	api_buf_mread
			call	bdm_send_word
			call	bdm_wait160

			ldi	XL,0x4c			;write HX
			call	bdm_send_byte
			call	api_buf_mread
			call	bdm_send_word
			call	bdm_wait160

			ldi	XL,0x4f			;write SP
			call	bdm_send_byte
			call	api_buf_mread
			call	bdm_send_word
			call	bdm_wait160
			jmp	main_loop_ok


s08_read_regs:		call	bdm_prepare
			call	api_resetptr
	
			ldi	XL,0x68			;read A
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_byte
			call	api_buf_bwrite

			ldi	XL,0x69			;read CCR
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_byte
			call	api_buf_bwrite
			
			ldi	XL,0x6b			;read PC
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_word
			call	api_buf_mwrite

			ldi	XL,0x6c			;read HX
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_word
			call	api_buf_mwrite
			
			ldi	XL,0x6f			;read SP
			call	bdm_send_byte
			call	bdm_wait160
			call	bdm_recv_word
			call	api_buf_mwrite

			jmp	main_loop_ok			
	