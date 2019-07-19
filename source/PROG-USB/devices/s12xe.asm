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
.equ		S12XE_FCDIV	= 0x0100
.equ		S12XE_FCCOBIX	= 0x0102
.equ		S12XE_FCNFG	= 0x0104
.equ		S12XE_FPROT	= 0x0108
.equ		S12XE_DFPROT	= 0x0109
.equ		S12XE_FSTAT	= 0x0106
.equ		S12XE_FCCOBHI	= 0x010a
.equ		S12XE_FCCOBLO	= 0x010b
.equ		S12XE_COPCTL	= 0x003c
.equ		S12XE_GPAGE	= 0x0010
.equ		S12XE_PPAGE	= 0x0015
.equ		S12XE_RPAGE	= 0x0016
.equ		S12XE_EPAGE	= 0x0017

.equ		S12XE_SYNR	= 0x0034
.equ		S12XE_REFDV	= 0x0035
.equ		S12XE_CLKSEL	= 0x0039

.macro	s12xe_writeregb
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		ldi	XL,@1
		call	bdm16_bwritef
.endm

.macro	s12xe_fcwritef
		ldi	r16,LOW(@1)
		ldi	r17,HIGH(@1)
		ldi	XL,@0
		rcall	s12xe_writefc
.endm

.macro	s12xe_writeregw
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		ldi	XL,LOW(@1)
		ldi	XH,HIGH(@1)
		call	bdm16_wwritef
.endm

.macro	s12xe_writeregwx
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		call	bdm16_wwritef
.endm

;-------------------------------------------------------------------------------
; set clock divider
;-------------------------------------------------------------------------------
s12xe_fdiv:	mov	r19,r16			;save PAR1
		call	bdm_prepare
		cpi	r17,25
		brcs	s12xe_fdiv_1

		ldi	r17,0x07		;8MHz if out of range
s12xe_fdiv_1:	ldi	r18,HIGH(bdm_jtab)
		add	r17,r18
		out	EEARL,r17		;set speed
		ldi	XL,0xd5			;enable ACK
		call	bdm_send_byte
		call	bdm_wait_ack

		ldi	XL,0xd6			;disable ACK
		call	bdm_send_byte
		call	bdm_wait160

		ldi	XL,0			;PAR1
		ldi	r22,LOW(S12XE_COPCTL)
		ldi	r23,HIGH(S12XE_COPCTL)
		call	bdm16_bwritef		;write fixed byte
		call	bdm_wait160

		mov	XL,r19			;PAR1
		ldi	r22,LOW(S12XE_FCDIV)
		ldi	r23,HIGH(S12XE_FCDIV)
		call	bdm16_bwritef		;write fixed byte
		call	bdm_wait160

		ldi	XL,0xff			;unprot
		ldi	r22,LOW(S12XE_FPROT)
		ldi	r23,HIGH(S12XE_FPROT)
		call	bdm16_bwritef		;write fixed byte
		call	bdm_wait160

		ldi	XL,0xff			;unprot
		ldi	r22,LOW(S12XE_DFPROT)
		ldi	r23,HIGH(S12XE_DFPROT)
		call	bdm16_bwritef		;write fixed byte
		call	bdm_wait160

		rcall	s12xe_fwready
s12xe_fdiv_2:	jmp	main_loop


;-------------------------------------------------------------------------------
; mass erase
;-------------------------------------------------------------------------------
s12xe_erase:	call	bdm_prepare
		rcall	s12xe_clear_err			;clear flash err flags
		s12xe_fcwritef 0,0x0800
		rcall	s12xe_fstart			;start action
		jmp	main_loop

;-------------------------------------------------------------------------------
; main erase 
;-------------------------------------------------------------------------------
s12xe_merase:	call	bdm_prepare
		rcall	s12xe_clear_err			;clear flash err flags
		s12xe_fcwritef 0,0x097f
		s12xe_fcwritef 1,0x0000			;ADDR
		rcall	s12xe_fstart			;start action
		jmp	main_loop


;-------------------------------------------------------------------------------
; data flash erase 
;-------------------------------------------------------------------------------
s12xe_derase:	call	bdm_prepare
		rcall	s12xe_clear_err			;clear flash err flags
		s12xe_fcwritef 0,0x0F00
		s12xe_fcwritef 1,0x0080			;ADDR
		s12xe_fcwritef 2,0x0000			;ADDR
		rcall	s12xe_fstart			;start action
		jmp	main_loop

;-------------------------------------------------------------------------------
; unsecure
;-------------------------------------------------------------------------------
s12xe_unsec:	call	bdm_prepare
		rcall	s12xe_clear_err			;clear flash err flags

		s12xe_fcwritef 0,0x067f			;CMD
		s12xe_fcwritef 1,0xff08			;ADDR
		s12xe_fcwritef 2,0xffff			;DATA 0
		s12xe_fcwritef 3,0xffff			;DATA 1
		s12xe_fcwritef 4,0xffff			;DATA 2
		s12xe_fcwritef 5,0xfffe			;DATA 3

		rcall	s12xe_fstart			;start action
		jmp	main_loop

;-------------------------------------------------------------------------------
; blank check
;-------------------------------------------------------------------------------
s12xe_blank:	call	bdm_prepare
		clr	r16
		clr	r16
		jmp	main_loop


;-------------------------------------------------------------------------------
; program
; r16	par1	addrlow
; r17	par2	addrmid
; r18	par3	addrhigh
; r19	par4
;-------------------------------------------------------------------------------
s12xe_dprog:	call	bdm_prepare
		call	api_resetptr			;reset buffer pointer
		movw	r24,r16				;ADDR
		rcall	s12xe_clear_err			;clear err flags
		ldi	r17,0x11			;WRITE DFLASH CMD
		rjmp	s12xe_prog_1

s12xe_pprog:	call	bdm_prepare
		call	api_resetptr			;reset buffer pointer
		movw	r24,r16				;ADDR
		rcall	s12xe_clear_err			;clear err flags
		ldi	r17,0x06			;WRITE PFLASH CMD

s12xe_prog_1:	push	r17				;save cmd
		ldi	XL,0				;POS 0
		mov	r16,r18				;ADDR 23..16
		rcall	s12xe_writefc

		movw	r16,r24
		ldi	XL,1				;POS 1
		rcall	s12xe_writefc

		call	api_buf_mread			;read bytes 0+1
		movw	r16,XL
		ldi	XL,2
		rcall	s12xe_writefc

		call	api_buf_mread			;read bytes 2+3
		movw	r16,XL
		ldi	XL,3
		rcall	s12xe_writefc

		call	api_buf_mread			;read bytes 4+5
		movw	r16,XL
		ldi	XL,4
		rcall	s12xe_writefc

		call	api_buf_mread			;read bytes 6+7
		movw	r16,XL
		ldi	XL,5
		rcall	s12xe_writefc

		rcall	s12xe_fstart			;start action

		adiw	r24,8				;inc ptr
		pop	r17
		cpi	YH,0x08				;all done?
		brne	s12xe_prog_1

s12xe_prog_2:	jmp	main_loop

;-------------------------------------------------------------------------------
; read
; FPAGE, EPAGE, HI-ADDR, LO-ADDR
;-------------------------------------------------------------------------------
s12xe_read:	call	bdm_prepare
		rcall	s12xe_clear_err		;clear err flags
		call	api_resetptr
		movw	r24,r18			;addr

		mov	XL,r16			;flash page number
		ldi	r22,LOW(S12XE_PPAGE)
		ldi	r23,HIGH(S12XE_PPAGE)
		call	bdm16_bwritef

		mov	XL,r17			;EEPROM page number
		ldi	r22,LOW(S12XE_EPAGE)
		ldi	r23,HIGH(S12XE_EPAGE)
		call	bdm16_bwritef

s12xe_read_1:	call	bdm16_wread		;read word
		cpi	YH,8
		brne	s12xe_read_1
		clr	r16
		jmp	main_loop


;-------------------------------------------------------------------------------
; read
; FPAGE, EPAGE, HI-ADDR, LO-ADDR
;-------------------------------------------------------------------------------
s12xe_read2:	call	bdm_prepare
		movw	r24,r18			;addr
		rcall	s12xe_clear_err		;clear err flags
		call	api_resetptr

		mov	XL,r16			;flash page number
		ldi	r22,LOW(S12XE_PPAGE)
		ldi	r23,HIGH(S12XE_PPAGE)
		call	bdm16_bwritef

		mov	XL,r17			;EEPROM page number
		ldi	r22,LOW(S12XE_EPAGE)
		ldi	r23,HIGH(S12XE_EPAGE)
		call	bdm16_bwritef

		ldi	XL,0x45			;write X
		call	bdm_send_byte
		movw	XL,r24
		sbiw	XL,2			;X will be incremented before write
		call	bdm_send_word
		call	bdm_wait160

s12xe_read2_1:	ldi	XL,0x62			;read next
		call	bdm_send_byte
		call	bdm_wait16
		call	bdm_wait16
		call	bdm_recv_word
		call	api_buf_mwrite
		cpi	YH,8
		brne	s12xe_read2_1
		clr	r16
		jmp	main_loop

;-------------------------------------------------------------------------------
; clear all errors
;-------------------------------------------------------------------------------
s12xe_clear_err:
		ldi	XL,0x30
		ldi	r22,LOW(S12XE_FSTAT)
		ldi	r23,HIGH(S12XE_FSTAT)
		jmp	bdm16_bwritef


;-------------------------------------------------------------------------------
; start cmd and wait upon completion
;-------------------------------------------------------------------------------
s12xe_fstart:	ldi	XL,0x80
		ldi	r22,LOW(S12XE_FSTAT)
		ldi	r23,HIGH(S12XE_FSTAT)
		call	bdm16_bwritef

s12xe_fwready:	clr	ZL
		ldi	ZH,0x20

s12xe_fwready_1:
		call	bdm_wait160
		ldi	r22,LOW(S12XE_FSTAT)
		ldi	r23,HIGH(S12XE_FSTAT)
		call	bdm16_breadf
		cpi	XL,0xff
		breq	s12xe_wready_a
		sbrc	XL,7			;check FCCF
		rjmp	s12xe_fwready_2
s12xe_wready_a:
		sbiw	ZL,1
		brne	s12xe_fwready_1
		ldi	r16,0x35		;time out status
		pop	XL
		pop	XL
		jmp	main_loop
s12xe_fwready_2:
		mov	r16,XL
		ret

;-------------------------------------------------------------------------------
; write FCCOB
; XL=NR
; r17=HI
; r16=LO
;-------------------------------------------------------------------------------
s12xe_writefc:	ldi	r22,LOW(S12XE_FCCOBIX)
		ldi	r23,HIGH(S12XE_FCCOBIX)
		call	bdm16_bwritef
		mov	XL,r17
		ldi	r22,LOW(S12XE_FCCOBHI)
		ldi	r23,HIGH(S12XE_FCCOBHI)
		call	bdm16_bwritef
		mov	XL,r16
		ldi	r22,LOW(S12XE_FCCOBLO)
		ldi	r23,HIGH(S12XE_FCCOBLO)
		jmp	bdm16_bwritef



;-------------------------------------------------------------------------------
; set PLL to f x n
;-------------------------------------------------------------------------------
s12xe_setpll:	call	bdm_prepare
		push	r16
		mov	XL,r17			;Factor
		ldi	r22,LOW(S12XE_SYNR)
		ldi	r23,HIGH(S12XE_SYNR)
		call	bdm16_bwritef

		pop	XL			;REF / 2
		ldi	r22,LOW(S12XE_REFDV)
		ldi	r23,HIGH(S12XE_REFDV)
		call	bdm16_bwritef

		ldi	ZL,50
		ldi	ZH,0
		call	api_wait_ms

		ldi	XL,0x80			;switch to pll clock
		ldi	r22,LOW(S12XE_CLKSEL)
		ldi	r23,HIGH(S12XE_CLKSEL)
		call	bdm16_bwritef

		ldi	ZL,5
		ldi	ZH,0
		call	api_wait_ms

		ldi	XL,0x84
		call	bdm_wstatus

		jmp	main_loop_ok

