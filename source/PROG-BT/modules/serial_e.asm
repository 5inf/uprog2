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


;-------------------------------------------------------------
; send one byte with 115K/s and even parity (STM32)
; 173/174 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3e_115K:	push	ZL
		push	ZH
		push	XL
		push	XH
		push	YL
		ldi	ZL,80
send3e_115k_x:	dec	ZL
		brne	send3e_115k_x
		sbi	CTRLPORT,SIG3		;2 set to one
		sbi	CTRLDDR,SIG3		;2 set to output

		in	XH,CTRLPORT		;1
		andi	XH,SIG3_AND		;1 clear bit
		out	CTRLPORT,XH		;1 startbit	---
		ldi	ZH,8			;1 bits to do
		clr	YL			;1 parity
		nop				;1 filling
send3e_115K_1:	ldi	ZL,55			;165 (n*3)
send3e_115K_2:	dec	ZL
		brne	send3e_115K_2

		in	XH,CTRLPORT		;1
		andi	XH,SIG3_AND		;1 clear bit
		ror	XL			;1
		brcc	send3e_115K_3		;2
		ori	XH,SIG3_OR		;  set bit
		inc	YL			;  parity
send3e_115K_3:	out	CTRLPORT,XH		;1		---
		dec	ZH			;1
		brne	send3e_115K_1		;2
		
send3e_115K_4:	ldi	ZL,55			;165 (n*3)
send3e_115K_5:	dec	ZL
		brne	send3e_115K_5

		in	XH,CTRLPORT		;1
		andi	XH,SIG3_AND		;1 clear bit
		ror	YL			;1
		brcc	send3e_115K_6		;2
		ori	XH,SIG3_OR		;  set bit
		inc	YL			;  parity
send3e_115K_6:	out	CTRLPORT,XH		;1		---
		
		ldi	ZL,57			;172
send3e_115K_7:	dec	ZL
		brne	send3e_115K_7
		
		sbi	CTRLPORT,SIG3		;		---

		ldi	ZL,55			;165
send3e_115K_8:	dec	ZL
		brne	send3e_115K_8

		pop	YL
		pop	XH
		pop	XL
		pop	ZH
		pop	ZL
		ret



;-------------------------------------------------------------
; receive one byte with 115K/s and even parity (STM32 boot)
; 174 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv4e_115K:	cbi	CTRLDDR,SIG4
		sbi	CTRLPORT,SIG4
		push	ZL
		push	ZH
		clr	ZL			;timeout
		clr	ZH
		set				;OK
recv4e_115K_1:	clr	XL
recv4e_115K_1a:	sbis	CTRLPIN,SIG4		;wait for start bit
		rjmp	recv4e_115K_2a
		nop
		nop
		nop
		nop
		dec	XL
		brne	recv4e_115K_1a
		sbiw	ZL,1
		brne	recv4e_115K_1
		clt				;timeout
		clr	XL
		pop	ZH
		pop	ZL
		ret

recv4e_115K_2a:	ldi	ZL,70			;x 1,5
recv4e_115K_2:	dec	ZL
		brne	recv4e_115K_2

		ldi	ZH,8			;1 8 bits

recv4e_115K_3:	lsr	XL			;1
		sbic	CTRLPIN,SIG4		;2
		ori	XL,0x80

		ldi	ZL,56			;15
recv4e_115K_4:	dec	ZL
		brne	recv4e_115K_4

		dec	ZH			;1
		brne	recv4e_115K_3		;2

		ldi	ZL,100			;x2
recv4e_115K_5:	dec	ZL
		brne	recv4e_115K_5
		pop	ZH
		pop	ZL
		ret


