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
;-------------------------------------------------------------
; send one byte with 1M/s (BL)
; 20 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_1m:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1 startbit
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
send3_1m_1:		ldi	ZL,3			;9
send3_1m_2:		dec	ZL
			brne	send3_1m_2
			nop				;1
			nop				;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_1m_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_1m_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_1m_1		;2
			ldi	ZL,4			;12 stopp-bit
send3_1m_4:		dec	ZL
			brne	send3_1m_4
			ret				;5


;-------------------------------------------------------------
; receive one byte with 1M/s (BL)
; 20 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv3_1m:		clr	ZL
			clr	ZH
			set
recv3_1m_1:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_1m_sb
			sbiw	ZL,1
			brne	recv3_1m_1
			clt				;timeout
			ret

recv3_1m_sb:		ldi	ZL,7			;21
recv3_1m_2:		dec	ZL
			brne	recv3_1m_2

			ldi	ZH,8			;1 8 bits

recv3_1m_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,3			;12
recv3_1m_4:		dec	ZL
			brne	recv3_1m_4

			nop				;1
			nop				;1
			dec	ZH			;1
			brne	recv3_1m_3		;2

recv3_1m_5:		sbis	CTRLPIN,SIG3		;2
			rjmp	recv3_1m_5
			ret


;-------------------------------------------------------------
; send one byte with 500K/s (R8c, M16c)
; 40 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_500k:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1 startbit
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_500k_1:		ldi	ZL,10			;30
send3_500k_2:		dec	ZL
			brne	send3_500k_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_500k_3		;2
			ori	XH,SIG3_OR		;1 set bit
send3_500k_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_500k_1		;2
			ldi	ZL,14			;18 stopp-bits
send3_500k_4:		dec	ZL
			brne	send3_500k_4
			cbi	CTRLDDR,SIG3		;2 set to input
			ret

;-------------------------------------------------------------
; receive one byte with 500K/s (R8c, M16c)
; 40 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv3_500k:		clr	ZL
			clr	ZH
			set
recv3_500k_1:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_500k_sb
			sbiw	ZL,1
			brne	recv3_500k_1
			clt				;timeout
			ret

recv3_500k_sb:		ldi	ZL,15
recv3_500k_2:		dec	ZL
			brne	recv3_500k_2

			ldi	ZH,8			;1 8 bits

recv3_500k_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,11			;33
recv3_500k_4:		dec	ZL
			brne	recv3_500k_4

			nop				;1
			dec	ZH			;1
			brne	recv3_500k_3		;2

recv3_500k_5:		sbis	CTRLPIN,SIG3		;2
			rjmp	recv3_500k_5
			ret


;-------------------------------------------------------------
; send one byte with 250k/s (RL78) and switch to input
; 80 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_250k:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1 startbit
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_250k_1:		ldi	ZL,23			;69
send3_250k_2:		dec	ZL
			brne	send3_250k_2
			nop				;1 filling
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry for shift-in stopp-bit
			ror	XL			;1
			brcc	send3_250k_3		;2
			ori	XH,SIG3_OR		;1 set bit
send3_250k_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_250k_1		;2
			ldi	ZL,90			;150 > 2 stopp-bits
send3_250k_4:		dec	ZL
			brne	send3_250k_4
			ret

;-------------------------------------------------------------
; send one byte with 250k/s (RL78) and switch to input
; 80 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3l_250k:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1 startbit
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3l_250k_1:		ldi	ZL,23			;69
send3l_250k_2:		dec	ZL
			brne	send3l_250k_2
			nop				;1 filling
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry for shift-in stopp-bit
			ror	XL			;1
			brcc	send3l_250k_3		;2
			ori	XH,SIG3_OR		;1 set bit
send3l_250k_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3l_250k_1		;2
			ldi	ZL,16			;1 1 stopp-bit
send3l_250k_4:		dec	ZL
			brne	send3l_250k_4
			cbi	CTRLDDR,SIG3		;2 set to input
			ret	

;-------------------------------------------------------------
; receive one byte with 250k/s (R8c, M16c)
; 80 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv3_250k:		clr	ZL
			clr	ZH
			set
recv3_250k_1:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_250k_sb
			sbiw	ZL,1
			brne	recv3_250k_1
			clt				;timeout
			ret

recv3_250k_sb:		ldi	ZL,35
recv3_250k_2:		dec	ZL
			brne	recv3_250k_2

			ldi	ZH,8			;1 8 bits

recv3_250k_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,24			;72
recv3_250k_4:		dec	ZL
			brne	recv3_250k_4

			nop				;1
			nop				;1
			dec	ZH			;1
			brne	recv3_250k_3		;2

recv3_250k_5:		sbis	CTRLPIN,SIG3		;2 wait for stopp bit
			rjmp	recv3_250k_5
			ret


;-------------------------------------------------------------
; send one byte with 9600/s (R8c, M16c)
; 22 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_9600:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_9600_1:		ldi	ZL,208			;2075 (n*10)
send3_9600_2:		dec	ZL
			rcall	serio_delay7
			brne	send3_9600_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_9600_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_9600_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_9600_1		;2
			ldi	ZL,00			;2083 (n*10)
send3_9600_4:		dec	ZL
			brne	send3_9600_4
			cbi	CTRLDDR,SIG3		;2 set to input
			ret

;-------------------------------------------------------------
; receive one byte with 9600/s (R8c, M16c)
; XL = Data
;-------------------------------------------------------------
recv3_9600:		clr	ZL			;timeout
			clr	ZH
			set
recv3_9600_1:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_9600_2
			rcall	serio_delay9
			sbiw	ZL,1
			brne	recv3_9600_1
			clt				;timeout
			ret

recv3_9600_sb:		ldi	ZL,224			;x 1,5

recv3_9600_2:		dec	ZL
			rcall	serio_delay11
			brne	recv3_9600_2

			ldi	ZH,8			;1 8 bits

recv3_9600_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,208			;15
recv3_9600_4:		dec	ZL
			rcall	serio_delay7	
			brne	recv3_9600_4

			nop				;1
			dec	ZH			;1
			brne	recv3_9600_3		;2

			ldi	ZL,132			;x0,5
recv3_9600_5:		dec	ZL
			nop
			nop
			nop
			nop
			nop
			brne	recv3_9600_5
			ret


;-------------------------------------------------------------
; send one byte with 38400/s
; 288 clocks/bit / 524
; XL = Data
;-------------------------------------------------------------
send3_38400:		push	ZL
			push	ZH
			push	XL
			sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_38400_1:		ldi	ZL,172			;279 (n*3)
send3_38400_2:		dec	ZL
			brne	send3_38400_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_38400_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_38400_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_38400_1		;2
			ldi	ZL,172			;95
send3_38400_4:		dec	ZL
			brne	send3_38400_4
;			cbi	CTRLDDR,SIG3		;2 set to input
			pop	XL
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------
; receive one byte with 38400/s (R8c, M16c)
; 288 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv3_38400:		push	ZL
			push	ZH
			clr	ZL			;timeout
			clr	ZH
			cbi	CTRLDDR,SIG3		;set to input
			set				;OK
recv3_38400_1:		clr	XL
recv3_38400_1a:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_38400_2a
			dec	XL
			brne	recv3_38400_1a
			sbiw	ZL,1
			brne	recv3_38400_1
			clt				;timeout
			pop	ZH
			pop	ZL
			ret

recv3_38400_2a:		ldi	ZL,196			;x 1,5
recv3_38400_2:		dec	ZL
			nop
			brne	recv3_38400_2

			ldi	ZH,8			;1 8 bits

recv3_38400_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,172			;15
recv3_38400_4:		dec	ZL
			brne	recv3_38400_4

			dec	ZH			;1
			brne	recv3_38400_3		;2

			ldi	ZL,87			;x0,5
recv3_38400_5:		dec	ZL
			brne	recv3_38400_5
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------
; send one byte with 115K/s
; 174 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_115K:		push	ZL
			push	ZH
			push	XL
			sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_115K_1:		ldi	ZL,55			;165 (n*3)
send3_115K_2:		dec	ZL
			brne	send3_115K_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_115K_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_115K_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_115K_1		;2
			ldi	ZL,55			;165
send3_115K_4:		dec	ZL
			brne	send3_115K_4
;			cbi	CTRLDDR,SIG3		;2 set to input
			pop	XL
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------
; receive one byte with 115K/s (UPD)
; 174 clocks/bit
; XL = Data
;-------------------------------------------------------------
recv3_115K:		cbi	CTRLDDR,SIG3
			push	ZL
			push	ZH
			clr	ZL			;timeout
			clr	ZH
			set				;OK
recv3_115K_1:		clr	XL
recv3_115K_1a:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_115K_2a
			dec	XL
			brne	recv3_115K_1a
			sbiw	ZL,1
			brne	recv3_115K_1
			clt				;timeout
			pop	ZH
			pop	ZL
			ret

recv3_115K_2a:		ldi	ZL,70			;x 1,5
recv3_115K_2:		dec	ZL
			brne	recv3_115K_2

			ldi	ZH,8			;1 8 bits

recv3_115K_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,56			;15
recv3_115K_4:		dec	ZL
			brne	recv3_115K_4

			dec	ZH			;1
			brne	recv3_115K_3		;2

			ldi	ZL,28			;x0,5
recv3_115K_5:		dec	ZL
			brne	recv3_115K_5
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------
; send one byte with 19200/s (unidir)
; 22 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_19200:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_19200_1:		ldi	ZL,104			;2075 (n*10)
send3_19200_2:		dec	ZL
			rcall	serio_delay7
			brne	send3_19200_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_19200_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_19200_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_19200_1		;2
			ldi	ZL,66			;2083 (n*10)
send3_19200_4:		dec	ZL
			rcall	serio_delay7	
			brne	send3_19200_4
			ret

;-------------------------------------------------------------
; receive one byte with 19200/s
; 1042 clocks
; XL = Data
;-------------------------------------------------------------
recv3_19200:		clr	ZL			;timeout
			clr	ZH
			set
recv3_19200_1:		sbis	CTRLPIN,SIG3		;wait for start bit
			rjmp	recv3_19200_sb
			rcall	serio_delay9
			sbiw	ZL,1
			brne	recv3_19200_1
			clt				;timeout
			ret

recv3_19200_sb:		ldi	ZL,120			;x 1,5

recv3_19200_2:		dec	ZL
			rcall	serio_delay11
			brne	recv3_19200_2

			ldi	ZH,8			;1 8 bits

recv3_19200_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG3		;2
			ori	XL,0x80

			ldi	ZL,103			;15
recv3_19200_4:		dec	ZL
			rcall	serio_delay7
			brne	recv3_19200_4

			nop				;1
			dec	ZH			;1
			brne	recv3_19200_3		;2

			ldi	ZL,66			;x0,5
recv3_19200_5:		dec	ZL
			nop
			nop
			nop
			nop
			nop
			brne	recv3_19200_5
			ret



;-------------------------------------------------------------
; receive one byte with 500K/s (R8c, M16c, PPCBAM)
; 40 clocks/bit
; XL = Data
;-------------------------------------------------------------
			;long timeout (10s) version
recv3_500k_lt:		clr	ZL
			ldi	ZH,0x00
			set
recv3_500k_lt_1:	clr	XL			;1 
recv3_500k_lt_2:	sbis	CTRLPIN,SIG3		;2 wait for start bit
			rjmp	recv3_500k_sb		;0 is zero
			sbis	CTRLPIN,SIG3		;2 wait for start bit
			rjmp	recv3_500k_sb		;0 is zero
			sbis	CTRLPIN,SIG3		;2 wait for start bit
			rjmp	recv3_500k_sb		;0 is zero
			sbis	CTRLPIN,SIG3		;2 wait for start bit
			rjmp	recv3_500k_sb		;0 is zero
			dec	XL			;1
			brne	recv3_500k_lt_2		;2
			sbiw	ZL,1
			brne	recv3_500k_lt_1
			clt				;timeout
			ret

;-------------------------------------------------------------
; send one byte with 24000/s (unidir)
; 833 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_24000:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_24000_1:		ldi	ZL,83			;2075 (n*10)
send3_24000_2:		dec	ZL
			rcall	serio_delay7
			brne	send3_24000_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_24000_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_24000_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_24000_1		;2
			ldi	ZL,52			;2083 (n*10)
send3_24000_4:		dec	ZL
			rcall	serio_delay7
			brne	send3_24000_4
			ret


;-------------------------------------------------------------
; send one byte with 48000/s (unidir)
; 417 clocks/bit
; XL = Data
;-------------------------------------------------------------
send3_48000:		sbi	CTRLPORT,SIG3		;2 set to one
			sbi	CTRLDDR,SIG3		;2 set to output
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			out	CTRLPORT,XH		;1
			ldi	ZH,9			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
send3_48000_1:		ldi	ZL,41			;2075 (n*10)
send3_48000_2:		dec	ZL
			rcall	serio_delay7
			brne	send3_48000_2
			in	XH,CTRLPORT		;1
			andi	XH,SIG3_AND		;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	send3_48000_3		;2
			ori	XH,SIG3_OR		;  set bit
send3_48000_3:		out	CTRLPORT,XH		;1
			dec	ZH			;1
			brne	send3_48000_1		;2
			ldi	ZL,26			;2083 (n*10)
send3_48000_4:		dec	ZL
			rcall	serio_delay7
			brne	send3_48000_4
			ret
