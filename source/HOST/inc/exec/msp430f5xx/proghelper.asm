;################################################################################
;#										#
;# JTAG-Proghelper für MSP430F5xxx						#
;#										#
;# copyright (c) 2017 Joerg Wolfram (joerg@jcwolfram.de)			#
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
;-------------------------------------------------------------------------------
; commands
; --------
; A153		addr		command			erase
; A152		addr		len(words)		program
; A151		addr		len(words)		readout
; A161		7955					protect BSL

		cpu msp430
		include	regmsp.inc

;-------------------------------------------------------------------------------
; I/O settings
;-------------------------------------------------------------------------------
RAM_START	equ	01c00H
FLASH_START	equ	0c000H
FLASH_WORDS	equ	02000H
INFO_START	equ	01800H

FCTL1X		equ	00140H
FCTL3X		equ	00144H
FCTL4X		equ	00146H
PMMCTL0X	equ	00120H
SYSBSLCX	equ	00182H
SYSJMBC		equ	00186H
SYSJMBI0	equ	00188H
SYSJMBO0	equ	0018CH

;SYSJMBC
JMB0_OUTFLAG	equ	004H		;1 = ready to write
JMB0_INFLAG	equ	001H		;1 = ready to read

;-------------------------------------------------------------------------------
; code starts here
;-------------------------------------------------------------------------------
		org	RAM_START		;RAM start
start:		nop
		nop
		;we dont need to disable watchdog, this is done by SBW-WRITEIO
		mov.w	#05a80H,&0158H		;disable watchdog

start1:		mov.w	#01effH,sp		;set stack pointer to end of RAM

		;unlock INFO A segment
		mov.w	#0a500H,&FCTL4X
		bit	#040H,&FCTL3X		;check locka
		jz	unlock_1
		mov.w	#0a540H,&FCTL3X

unlock_1:

;-------------------------------------------------------------------------------
; the main loop
;-------------------------------------------------------------------------------
loop:		mov	#0ABCDH,r7
		call	put_word		;write 0xABCD in mailbox
		call	get_word		;get word from spx

;-------------------------------------------------------------------------------
; erase flash segments
; W0	0x7853
; W1	Address
; W2	type (0x502 segment, 0x504 sector)
;-------------------------------------------------------------------------------
erase:		cmp.w	#0A153H,r7
		jnz	program
		call	get_word		;get address
		mov.w	r7,r6			;addr
		call	get_word		;get command

erase_w0:	bit.b	#1,&FCTL3X
		jnz	erase_w0
		mov.w	#0a500H,&FCTL3X		;unlock
		mov.w	r5,&FCTL1X		;erase command
		mov.w	r7,0(r6)		;dummy write
erase_w1:	bit.b	#1,&FCTL3X		;wait for ready
		jnz	erase_w1
erae_goloop:	mov.w	#0a510H,&FCTL3X		;lock
		jmp	loop			;jump to main loop

;-------------------------------------------------------------------------------
; program main flash
; W0 = 0x7852
; W1 = address
; W2 = length (words)
; W3+ data
;-------------------------------------------------------------------------------
program:	cmp.w	#0A152H,r7
		jnz	readout
		call	get_word		;get address
		mov.w	r7,r6			;flash start address
		call	get_word		;get length
		mov.w	r7,r5			;flash words
prog_loop:
prog_w1:	bit.b	#1,&FCTL3X		;wait for ready
		jnz	prog_w1
		; write flash word, r6=pointer, r7=data
		mov.w	#0a500H,&FCTL3X		;unlock
		mov.w	#0a540H,&FCTL1X		;WRT = 1
		call	get_word		;get Word to r7
		mov.w	r7,0(r6)		;dummy write
prog_w2:	bit.b	#1,&FCTL3X		;wait for ready
		jnz	prog_w2
		mov.w	#0a510H,&FCTL3X		;lock
		add	#2,r6			;increment address
		sub.w	#1,r5			;decrement loop counter
		jnz	prog_loop		;do the word loop
		jmp	loop			;jump to main loop

;-------------------------------------------------------------------------------
; readout main flash
; W0 = 0x7851
; W1 = address
; W2 = length (words)
; W3+ data
;-------------------------------------------------------------------------------
readout:	cmp.w	#0A151H,r7
		jnz	bsl_protect
		call	get_word		;get address
		mov.w	r7,r6			;flash start address
		call	get_word		;get address
		mov.w	r7,r5			;flash words

read_loop:	mov.w	0(r6),r7		;read
		call	put_word		;send via spx
		add	#2,r6			;increment address
		sub	#1,r5			;loop counter
		jnz	read_loop		;do the loop
		jmp	loop

;-------------------------------------------------------------------------------
; unprotect and protect BSL memeory area
;-------------------------------------------------------------------------------
bsl_protect:	cmp.w	#0A161H,r7
		jnz	bsl_nofu
		call	get_word
		cmp.w	#07955H,r7		;this is for security
		jnz	bsl_nofu
		mov.w	#00003,&SYSBSLCX
		mov.w	#017FCH,r6
		mov.w	#05555H,r7
		mov.w	#2,r5

prot_loop:	bit.b	#1,&FCTL3X		;wait for ready
		jnz	prot_loop
		; write flash word, r6=pointer, r7=data
		mov.w	#0a500H,&FCTL3X		;unlock
		mov.w	#0a540H,&FCTL1X		;WRT = 1
		mov.w	r7,0(r6)		;dummy write
prot_w2:	bit.b	#1,&FCTL3X		;wait for ready
		jnz	prot_w2
		mov.w	#0a510H,&FCTL3X		;lock
		add	#2,r6			;increment address
		sub.w	#1,r5			;decrement loop counter
		jnz	prot_loop		;do the word loop
		mov.w	#08003,&SYSBSLCX

bsl_nofu:	jmp	loop			;jump to main loop


;-------------------------------------------------------------------------------
; get a word (r7) msb first
;-------------------------------------------------------------------------------
get_word:	bit.b	#JMB0_INFLAG,SYSJMBC		
		jz	get_word
		
		mov.w	SYSJMBI0,r7		
		ret

;-------------------------------------------------------------------------------
; put a word (r7) msb first
;-------------------------------------------------------------------------------
put_word:	bit.b	#JMB0_OUTFLAG,SYSJMBC		
		jz	put_word
	
		mov.w	r7,SYSJMBO0		
		ret
end

