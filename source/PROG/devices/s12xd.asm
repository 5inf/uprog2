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
.equ		S12XD_FCDIV	= 0x0100
.equ		S12XD_FOPT	= 0x0101
.equ		S12XD_FTSTMOD	= 0x0102
.equ		S12XD_FCNFG	= 0x0103
.equ		S12XD_FPROT	= 0x0104
.equ		S12XD_FSTAT	= 0x0105
.equ		S12XD_FCMD	= 0x0106
.equ		S12XD_FADDR	= 0x0108
.equ		S12XD_FDATA	= 0x010a
.equ		S12XD_ECDIV	= 0x0110
.equ		S12XD_ETSTMOD	= 0x0112
.equ		S12XD_ECNFG	= 0x0113
.equ		S12XD_EPROT	= 0x0114
.equ		S12XD_ESTAT	= 0x0115
.equ		S12XD_ECMD	= 0x0116
.equ		S12XD_EADDR	= 0x0118
.equ		S12XD_EDATA	= 0x011a
.equ		S12XD_PPAGE	= 0x0030
.equ		S12XD_COPCTL	= 0x003c
.equ		S12XD_EPAGE	= 0x0017
.equ		S12XD_SYNR	= 0x0034
.equ		S12XD_REFDV	= 0x0035
.equ		S12XD_CLKSEL	= 0x0039


.macro	s12xd_writeregb
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		ldi	XL,@1
		call	bdm16_bwritef
.endm

.macro	s12xd_writeregb1
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		call	bdm16_bwritef
.endm

.macro	s12xd_writeregw
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		ldi	XL,LOW(@1)
		ldi	XH,HIGH(@1)
		call	bdm16_wwritef
.endm

.macro	s12xd_writeregwx
		ldi	r22,LOW(@0)
		ldi	r23,HIGH(@0)
		call	bdm16_wwritef
.endm


;-------------------------------------------------------------------------------
; set clock divider
;-------------------------------------------------------------------------------
s12xd_fdiv:	mov	r19,r16			;save PAR1
		call	bdm_prepare
		cpi	r17,25
		brcs	s12xd_fdiv_1
		ldi	r17,0x07		;8MHz if out of range
s12xd_fdiv_1:	ldi	r18,HIGH(bdm_jtab)
		add	r17,r18
		out	EEARL,r17		;set speed
		ldi	XL,0xd5			;enable ACK
		call	bdm_send_byte
		call	bdm_wait_ack

		ldi	XL,0xd6			;disable ACK
		call	bdm_send_byte
		call	bdm_wait160

		;disable COP
		ldi	XL,0x00
		ldi	r22,LOW(S12XD_COPCTL)
		ldi	r23,HIGH(S12XD_COPCTL)
		call	bdm16_bwritef
		call	bdm_wait160

		;set ECLKDIV
		mov	XL,r19			;PAR1
		ldi	r22,LOW(S12XD_ECDIV)
		ldi	r23,HIGH(S12XD_ECDIV)
		call	bdm16_bwritef
		call	bdm_wait160

		;set FCLKDIV
		mov	XL,r19			;PAR1
		ldi	r22,LOW(S12XD_FCDIV)
		ldi	r23,HIGH(S12XD_FCDIV)
		call	bdm16_bwritef
		call	bdm_wait160

		;wait for flash and eeprom ready
		rcall	s12xd_fwready
		rcall	s12xd_fwready

		;unprotect flash and eeprom
		s12xd_writeregb S12XD_FPROT,0xff	;unprotect Flash
		s12xd_writeregb S12XD_EPROT,0xff	;unprotect EEPROM

s12xd_fdiv_2:	jmp	main_loop


;-------------------------------------------------------------------------------
; mass erase flash block
;-------------------------------------------------------------------------------
s12xd_merase:	call	bdm_prepare
		clr	r16

		;erase FLASH
		s12xd_writeregb S12XD_FSTAT,0x30	;clear flags
		s12xd_writeregb S12XD_FTSTMOD,0x00	;clear Wall
		s12xd_writeregb S12XD_FSTAT,0x02	;clear err flag
		s12xd_writeregb S12XD_FTSTMOD,0x10	;set Wall

		s12xd_writeregw S12XD_FADDR,0xFFFE	;set addr
		s12xd_writeregw S12XD_FDATA,0xFFFF	;set addr

		s12xd_writeregb S12XD_FCMD,0x41		;mass erase cmd
		rcall	s12xd_fstart			;start action
		jmp	main_loop


;-------------------------------------------------------------------------------
; mass erase eeprom
;-------------------------------------------------------------------------------
s12xd_eerase:	call	bdm_prepare
		clr	r16

		;erase EEPROM
		s12xd_writeregb S12XD_ESTAT,0x30	;clear flags

		s12xd_writeregw 0x0c00,0x0C00		;set addr

;		s12xd_writeregw S12XD_EADDR,0x0C00	;set addr
;		s12xd_writeregw S12XD_EDATA,0x0000	;set addr

		s12xd_writeregb S12XD_ECMD,0x41		;mass erase cmd
		rcall	s12xd_estart			;start action

		jmp	main_loop

;-------------------------------------------------------------------------------
; unsecure
;-------------------------------------------------------------------------------
s12xd_unsec:	call	bdm_prepare
		clr	r16

		ldi	ZL,0
		ldi	ZH,2
		call	api_wait_ms

		;erase FLASH
;		s12xd_writeregb S12XD_FPROT,0xff	;unprotect Flash
		s12xd_writeregb S12XD_FSTAT,0x30	;clear flags
		s12xd_writeregb S12XD_FTSTMOD,0x00	;clear Wall
		s12xd_writeregb S12XD_FSTAT,0x02	;clear err flag
		s12xd_writeregb S12XD_FTSTMOD,0x10	;set Wall

		s12xd_writeregw S12XD_FADDR,0xFFFE	;set addr
		s12xd_writeregw S12XD_FDATA,0xFFFF	;set addr

;		s12xd_writeregw 0xf000,0xffff		;dummy write
		s12xd_writeregb S12XD_FCMD,0x41		;mass erase cmd
		rcall	s12xd_fstart			;start action

		;erase EEPROM
;		s12xd_writeregb S12XD_EPROT,0xff	;unprotect Flash
		s12xd_writeregb S12XD_ESTAT,0x30	;clear flags
		s12xd_writeregb S12XD_ETSTMOD,0x00	;clear Wall
		s12xd_writeregb S12XD_ESTAT,0x02	;clear err flag
		s12xd_writeregb S12XD_ETSTMOD,0x10	;set Wall

		s12xd_writeregw S12XD_EADDR,0x0C00	;set addr
		s12xd_writeregw S12XD_EDATA,0x0000	;set addr

;		s12xd_writeregw 0xf000,0xffff		;dummy write
		s12xd_writeregb S12XD_ECMD,0x41		;mass erase cmd
		rcall	s12xd_estart			;start action

		call	reinit_bdm
		cpi	r16,0
		brne	s12xd_unsec_1

		;set ECLKDIV
		mov	XL,r19			;PAR1
		ldi	r22,LOW(S12XD_ECDIV)
		ldi	r23,HIGH(S12XD_ECDIV)
		call	bdm16_bwritef
		call	bdm_wait160

		;set FCLKDIV
		mov	XL,r19			;PAR1
		ldi	r22,LOW(S12XD_FCDIV)
		ldi	r23,HIGH(S12XD_FCDIV)
		call	bdm16_bwritef
		call	bdm_wait160

		;write unsecure word
		rcall	s12xd_fwready			;wait for flash ready
		s12xd_writeregb S12XD_FTSTMOD,0x00	;clear Wall
		s12xd_writeregb S12XD_PPAGE,0xff	;upper block
		s12xd_writeregb S12XD_FPROT,0xff	;unprotect Flash
		s12xd_writeregb S12XD_EPROT,0xff	;unprotect Flash
		s12xd_writeregb S12XD_FSTAT,0x32	;clear flags

		s12xd_writeregw 0xff0e,0xfffe		;flash block addr
		s12xd_writeregb S12XD_FCMD,0x20		;program cmd
		rcall	s12xd_fstart			;start action

s12xd_unsec_1:	jmp	main_loop

;-------------------------------------------------------------------------------
; program flash
; FLASHBLOCK, PAGE, HI-ADDR, LO-ADDR
;-------------------------------------------------------------------------------
s12xd_fprog:	call	bdm_prepare
		call	api_resetptr		;set buffer pointer
		movw	r24,r18			;addr

		mov	XL,r17			;page number
		ldi	r22,LOW(S12XD_PPAGE)
		ldi	r23,HIGH(S12XD_PPAGE)
		call	bdm16_bwritef

s12xd_fprog_1:	rcall	s12xd_clear_ferr	;clear err flags
		call	bdm16_wwrite		;write word
		s12xd_writeregb S12XD_FCMD,0x20	;PROG cmd
		rcall	s12xd_fstart
		sbrs	r16,6
		rjmp	s12xd_fprog_2		;error
		lds	r0,txlen_h
		cp	YH,r0
		brne	s12xd_fprog_1
		clr	r16
s12xd_fprog_2:	jmp	main_loop

;-------------------------------------------------------------------------------
; program EEPROM
; PGA,ignore,ignore,ignore
;-------------------------------------------------------------------------------
s12xd_eprog:	call	bdm_prepare
		rcall	s12xd_clear_eerr	;clear err flags
		call	api_resetptr
		ldi	r24,0			;addr
		ldi	r25,8

		mov	XL,r16			;page number
		ldi	r22,LOW(S12XD_EPAGE)
		ldi	r23,HIGH(S12XD_EPAGE)
		call	bdm16_bwritef

s12xd_eprog_1:	call	s12xd_clear_eerr	;clear err flags
		call	bdm16_wwrite		;write word
		s12xd_writeregb S12XD_ECMD,0x20	;PROG cmd
		rcall	s12xd_estart
		sbrs	r16,6
		rjmp	s12xd_eprog_2		;error
		lds	r0,txlen_h
		cp	YH,r0
		brne	s12xd_eprog_1
		clr	r16
s12xd_eprog_2:	jmp	main_loop


;-------------------------------------------------------------------------------
; read
; FPAGE, EPAGE, HI-ADDR, LO-ADDR
;-------------------------------------------------------------------------------
s12xd_read:	call	bdm_prepare
		rcall	s12xd_clear_ferr	;clear err flags
		call	api_resetptr
		movw	r24,r18			;addr

		mov	XL,r16			;flash page number
		ldi	r22,LOW(S12XD_PPAGE)
		ldi	r23,HIGH(S12XD_PPAGE)
		call	bdm16_bwritef

		mov	XL,r17			;EEPROM page number
		ldi	r22,LOW(S12XD_EPAGE)
		ldi	r23,HIGH(S12XD_EPAGE)
		call	bdm16_bwritef

s12xd_read_1:	call	bdm16_wread		;read word
		lds	r0,rxlen_h
		cp	YH,r0
		brne	s12xd_read_1
		clr	r16
		jmp	main_loop


;-------------------------------------------------------------------------------
; read 
; FPAGE, EPAGE, HI-ADDR, LO-ADDR
;-------------------------------------------------------------------------------
s12xd_read2:	call	bdm_prepare
		movw	r24,r18			;addr
		rcall	s12xd_clear_ferr	;clear err flags
		call	api_resetptr

		mov	XL,r16			;flash page number
		ldi	r22,LOW(S12XD_PPAGE)
		ldi	r23,HIGH(S12XD_PPAGE)
		call	bdm16_bwritef

		ldi	XL,0x45			;write X
		call	bdm_send_byte
		movw	XL,r24
		sbiw	XL,2			;X will be incremented before write
		call	bdm_send_word
		call	bdm_wait160

s12xd_read2_1:	ldi	XL,0x62			;read next
		call	bdm_send_byte
		call	bdm_wait16
		call	bdm_wait16
		call	bdm_recv_word
;		ldi	XL,0xff
;		ldi	XH,0xff
		call	api_buf_mwrite
		lds	r0,rxlen_h
		brne	s12xd_read2_1
		clr	r16
		jmp	main_loop

;-------------------------------------------------------------------------------
; read 
; EPAGR,ignore,ignore,ignore
;-------------------------------------------------------------------------------
s12xd_read_eep:	call	bdm_prepare
		rcall	s12xd_clear_ferr	;clear err flags
		call	api_resetptr
		ldi	r24,0
		ldi	r25,8

		mov	XL,r16			;EEPROM page number
		ldi	r22,LOW(S12XD_EPAGE)
		ldi	r23,HIGH(S12XD_EPAGE)
		call	bdm16_bwritef

s12xd_read_ee1:	call	bdm16_wread		;read word
		lds	r0,rxlen_h
		brne	s12xd_read2_1
		brne	s12xd_read_ee1
		clr	r16
		jmp	main_loop

;-------------------------------------------------------------------------------
; set PLL to f x n
;-------------------------------------------------------------------------------
s12xd_setpll:	call	bdm_prepare

		mov	XL,r16			;Factor
		lsl	XL			;*2
		dec	XL			;-1
		ldi	r22,LOW(S12XD_SYNR)
		ldi	r23,HIGH(S12XD_SYNR)
		call	bdm16_bwritef

		ldi	XL,3			;REF / 2
		ldi	r22,LOW(S12XD_REFDV)
		ldi	r23,HIGH(S12XD_REFDV)
		call	bdm16_bwritef

		ldi	ZL,50
		ldi	ZH,0
		call	api_wait_ms

		ldi	XL,0x80			;switch to pll clock
		ldi	r22,LOW(S12XD_CLKSEL)
		ldi	r23,HIGH(S12XD_CLKSEL)
		call	bdm16_bwritef

		ldi	ZL,5
		ldi	ZH,0
		call	api_wait_ms

		ldi	XL,0x84
		call	bdm_wstatus

		ldi	r16,0			;ok
		jmp	main_loop

;-------------------------------------------------------------------------------
; subroutines for flash
;-------------------------------------------------------------------------------
s12xd_clear_ferr:
		ldi	XL,0x32
		ldi	r22,LOW(S12XD_FSTAT)
		ldi	r23,HIGH(S12XD_FSTAT)
		jmp	bdm16_bwritef

s12xd_fstart:	ldi	XL,0x80
		ldi	r22,LOW(S12XD_FSTAT)
		ldi	r23,HIGH(S12XD_FSTAT)
		call	bdm16_bwritef

s12xd_fwready:	ldi	r18,0
		ldi	r19,200
s12xd_fwready_1:
		call	bdm_wait160
		ldi	r22,LOW(S12XD_FSTAT)
		ldi	r23,HIGH(S12XD_FSTAT)
		call	bdm16_breadf
		sbrc	XL,6			;check CCIF
		rjmp	s12xd_fwready_2
		sub	r18,const_1
		sbc	r19,const_0
		brne	s12xd_fwready_1
		ldi	r16,0x02		;time out status
		pop	XL
		pop	XL
		jmp	main_loop
s12xd_fwready_2:
		mov	r16,XL
		ret

;-------------------------------------------------------------------------------
; subroutines for eeprom
;-------------------------------------------------------------------------------
s12xd_clear_eerr:
		ldi	XL,0x30
		ldi	r22,LOW(S12XD_ESTAT)
		ldi	r23,HIGH(S12XD_ESTAT)
		jmp	bdm16_bwritef

s12xd_estart:	ldi	XL,0x80
		ldi	r22,LOW(S12XD_ESTAT)
		ldi	r23,HIGH(S12XD_ESTAT)
		call	bdm16_bwritef

s12xd_ewready:	ldi	r18,0
		ldi	r19,20
s12xd_ewready_1:
		call	bdm_wait160
		ldi	r22,LOW(S12XD_ESTAT)
		ldi	r23,HIGH(S12XD_ESTAT)
		call	bdm16_breadf
		sbrc	XL,6			;check FCCF
		rjmp	s12xd_ewready_2
		sub	r18,const_1
		sbc	r19,const_0
		brne	s12xd_ewready_1
		ldi	r16,0x02		;time out status
		pop	XL			;kill last stack entry
		pop	XL
		jmp	main_loop
s12xd_ewready_2:
		mov	r16,XL
		ret

