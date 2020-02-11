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

.equ	DS_MCLR		= SIG3
.equ	DS_DATA		= SIG1
.equ	DS_CLOCK	= SIG2

.equ	RES_PULSE	= 2000	;(µs * 5)
.equ	P18		= 3
.equ	P19		= 3
.equ	P7		= 40
.equ	P11		= 120
.equ	P12		= 100
.equ	P13		= 2

.macro	do_six
	ldi	r20,@0
	ldi	XH,@1
	ldi	XL,@2
	rcall	dspic_six
.endm

.macro	sixhex
	ldi	r20,(@0 >> 16) & 0xff
	ldi	XH,(@0 >> 8) & 0xff
	ldi	XL,@0 & 0xff
	rcall	dspic_six
.endm

.macro	sixval
	ldi	r20,@0
	rcall	dspic_six16
.endm

.macro	do_nops
	ldi	r22,@0
	rcall	dspic_nop
.endm


;------------------------------------------------------------------------------
; init and send key
;------------------------------------------------------------------------------
dspic_init:	cbi	CTRLPORT,DS_MCLR	;all low
		cbi	CTRLPORT,DS_DATA	;all low
		cbi	CTRLPORT,DS_CLOCK	;all low

		sbi	CTRLDDR,DS_MCLR		;all to output
		sbi	CTRLDDR,DS_DATA		;all to output
		sbi	CTRLDDR,DS_CLOCK	;all to output

;		cpi	r16,0
;		breq	dspic_init_nv
		call	api_vcc_on

dspic_init_nv:	ldi	ZL,50			;wait a little bit
		ldi	ZH,0
		call	api_wait_ms

		ldi	ZL,LOW(RES_PULSE)
		ldi	ZH,HIGH(RES_PULSE)

		sbi	CTRLPORT,DS_MCLR	;reset high

dspic_init_1:	sbiw	ZL,1
		brne	dspic_init_1

		cbi	CTRLPORT,DS_MCLR	;reset LOW

		ldi	ZL,P18
		ldi	ZH,0
		call	api_wait_ms

		ldi	XH,0x4d
		ldi	XL,0x43
		rcall	dspic_outword

		ldi	XH,0x48
		ldi	XL,0x51
		rcall	dspic_outword

		ldi	ZL,P19
		ldi	ZH,0
		call	api_wait_ms

		sbi	CTRLPORT,DS_MCLR	;reset high

		ldi	ZL,P7
		ldi	ZH,0
		call	api_wait_ms

		jmp	main_loop_ok

;------------------------------------------------------------------------------
; init and send key
;------------------------------------------------------------------------------
dspic_einit:	cbi	CTRLPORT,DS_MCLR	;all low
		cbi	CTRLPORT,DS_DATA	;all low
		cbi	CTRLPORT,DS_CLOCK	;all low

		sbi	CTRLDDR,DS_MCLR		;all to output
		sbi	CTRLDDR,DS_DATA		;all to output
		sbi	CTRLDDR,DS_CLOCK	;all to output

		ldi	ZL,50			;wait a little bit
		ldi	ZH,0
		call	api_wait_ms

		ldi	ZL,LOW(RES_PULSE)
		ldi	ZH,HIGH(RES_PULSE)

		sbi	CTRLPORT,DS_MCLR	;reset high

dspic_einit_1:	sbiw	ZL,1
		brne	dspic_einit_1

		cbi	CTRLPORT,DS_MCLR	;reset LOW

		ldi	ZL,P18
		ldi	ZH,0
		call	api_wait_ms

		ldi	XH,0x4d
		ldi	XL,0x43
		rcall	dspic_outword

		ldi	XH,0x48
		ldi	XL,0x50
		rcall	dspic_outword

		ldi	ZL,P19
		ldi	ZH,0
		call	api_wait_ms

		sbi	CTRLPORT,DS_MCLR	;reset high

		ldi	ZL,P7
		ldi	ZH,0
		call	api_wait_ms

		jmp	main_loop_ok

;------------------------------------------------------------------------------
; exit
;------------------------------------------------------------------------------
dspic_exit:	jmp	main_loop_ok
		cbi	CTRLPORT,DS_MCLR	;all low
		cbi	CTRLPORT,DS_DATA	;all low
		cbi	CTRLPORT,DS_CLOCK	;all low

		cbi	CTRLDDR,DS_MCLR		;all to input
		cbi	CTRLDDR,DS_DATA		;all to input
		cbi	CTRLDDR,DS_CLOCK	;all to input

		call	api_vcc_off		;power off

		jmp	main_loop_ok


;------------------------------------------------------------------------------
; read the ID
;------------------------------------------------------------------------------
dspic_readid:	call	api_resetptr
		rcall	dspic_outentry
		rcall	dspic_ereset
		sixhex	0x200ff0		;mov	#FF,W0
		sixhex	0x8802a0		;mov	W0,TBLPAG
		sixhex	0x200006		;mov	#0000,W6
		sixhex	0x20f887		;mov	#VISI,W7
		sixhex	0xba0bb6		;TBLRDL	[W6++],[W7]
		do_nops	5
		rcall	dspic_rgo		;clockout VISI
		call	api_buf_lwrite		;write result to buffer
		do_nops	1
		sixhex	0x200026		;mov	#0002,W6
		sixhex	0x20f887		;mov	#VISI,W7
		sixhex	0xba0bb6		;TBLRDL	[W6++],[W7]
		do_nops	5
		rcall	dspic_rgo		;clockout VISI
		call	api_buf_lwrite		;write result to buffer
		do_nops	1

		sixhex	0x200800		;mov	#80,W0
		sixhex	0x8802a0		;mov	W0,TBLPAG
		sixhex	0x20FF06		;mov	#0FF0,W6
;		sixhex	0x200006		;mov	#0FF0,W6
		sixhex	0x20f887		;mov	#VISI,W7
		sixhex	0xba0bb6		;TBLRDL	[W6++],[W7]
		do_nops	5
		rcall	dspic_rgo		;clockout VISI
		call	api_buf_lwrite		;write result to buffer

		rcall	dspic_ereset
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; erase all
;------------------------------------------------------------------------------
dspic_erall:	rcall	dspic_ereset
		sixhex	0x2400Fa		;MOV	#400F,W10
		sixhex	0x88394a		;MOV	W10,NVMCON
		do_nops	2
		rcall	dspic_swrite
		do_nops	3

		ldi	ZL,LOW(200)
		ldi	ZH,HIGH(200)
		call	api_wait_ms
		rcall	dspic_ereset
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; erase executive memory
;------------------------------------------------------------------------------
dspic_exera:	rcall	dspic_ereset
		sixhex	0x24003a		;MOV	#4003,W10
		sixhex	0x88394a		;MOV	W10,NVMCON
		do_nops	2

		sixhex	0x200803		;MOV	#80,W3 !!!
		sixhex	0x883963		;MOV	W3,NVMADRU
		sixhex	0x200002		;MOV	#0,W2
		sixhex	0x883952		;MOV	W2,NVMADR
		do_nops	2

		sixhex	0x200551		;MOV	#55,W1
		sixhex	0x883971		;MOV	W1,NVMKEY
		sixhex	0x200AA1		;MOV	#AA,W1
		sixhex	0x883971		;MOV	W1,NVMKEY
		sixhex	0xa8e729		;BSET	NVMCON,#15
		do_nops	3

		rcall	dspic_swrite
		do_nops	2

		ldi	ZL,LOW(P12)
		ldi	ZH,HIGH(P12)
		call	api_wait_ms

		do_nops	2

		sixhex	0x24003a		;MOV	#4003,W10
		sixhex	0x88394a		;MOV	W10,NVMCON
		do_nops	2

		sixhex	0x200803		;MOV	#80,W3 !!!
		sixhex	0x883963		;MOV	W3,NVMADRU
		sixhex	0x208002		;MOV	#800,W2
		sixhex	0x883952		;MOV	W2,NVMADR
		do_nops	2

		rcall	dspic_swrite
		do_nops	2

		ldi	ZL,LOW(P12)
		ldi	ZH,HIGH(P12)
		call	api_wait_ms

		do_nops	4
		jmp	main_loop_ok

dspic_swrite:	sixhex	0x200551		;MOV	#55,W1
		sixhex	0x883971		;MOV	W1,NVMKEY
		sixhex	0x200AA1		;MOV	#AA,W1
		sixhex	0x883971		;MOV	W1,NVMKEY
		sixhex	0xa8e729		;BSET	NVMCON,#15
		ret


;------------------------------------------------------------------------------
; write config resgisters to default value
;------------------------------------------------------------------------------
dspic_defconf:	rcall	dspic_ereset		;exit reset vector
		sixhex	0x200007		;MOV	#00,W7
		sixhex	0x200FAC		;MOV	#FA,W12
		sixhex	0x8802AC		;MOV	W12,TBLPAG

		sixhex	0x200030		;MOV	#FGS, W0
		sixhex	0x200042		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200870		;MOV	#FOSCSEL, W0
		sixhex	0x200062		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200E70		;MOV	#FOSC, W0
		sixhex	0x200082		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200ff0		;MOV	#FWDT, W0
		sixhex	0x2000a2		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x2003f0		;MOV	#FPOR, W0
		sixhex	0x2000c2		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200d70		;MOV	#FICD, W0
		sixhex	0x2000e2		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200030		;MOV	#FAS, W0
		sixhex	0x200102		;MOV	#addr,W2
		rcall	dspic_cprog1

		sixhex	0x200ff0		;MOV	#FUID0, W0
		sixhex	0x200122		;MOV	#addr,W2
		rcall	dspic_cprog1

		jmp	main_loop_ok

dspic_cprog1:	sixhex	0xBB0B80		;TBLWTL	W0, [W7]
		do_nops	2
		sixhex	0x200F83		;MOV	#addr,W3
		sixhex	0x883963		;MOV	W3,NVMADRU
		sixhex	0x883952		;MOV	W2,NVMADDR
		sixhex	0x24000a		;MOV	#4000,W10
		sixhex	0x88394a		;MOV	W10,NVMCON
		do_nops	2
		rcall	dspic_swrite
		do_nops	3			;neu!!!
		ldi	ZL,50
		ldi	ZH,0
		call	api_wait_ms
		rjmp	dspic_ereset


;------------------------------------------------------------------------------
; program executive memory
;------------------------------------------------------------------------------
dspic_exprog:	movw	r24,r16			;copy addr
		clr	YL
		ldi	YH,0x01
		rcall	dspic_ereset

		;step 5
		sixhex	0x24002a		;MOV	#4002,W10
		sixhex	0x88394a		;MOV	W10,NVMCON
		do_nops	2
		ldi	ZH,2			;rows we can do in one step (2 in 1K RAM)

		;step 6
dspic_exprog_1:	push	ZH
		sixhex	0x200803		;MOV	#80,W3 !!!
		sixhex	0x883963		;MOV	W3,NVMADRU
		movw	XL,r24			;set ADDR
		sixval	0x22			;MOV	#ADDR,W2

		sixhex	0x883952		;MOV	W2,NVMADDR
		sixhex	0x200FAC		;MOV	#FA,W12
		sixhex	0x8802AC		;MOV	W12,TBLPAG
		sixhex	0xeb0380		;CLR	W7
		do_nops	1

		ldi	ZL,32
		;step 7
dspic_exprog_2:	ld	XL,Y
		ldd	XH,Y+1
		sixval	0x20
		ldd	XL,Y+2
		ldd	XH,Y+6
		sixval	0x21
		ldd	XL,Y+4
		ldd	XH,Y+5
		sixval	0x22
		ldd	XL,Y+8
		ldd	XH,Y+9
		sixval	0x23
		ldd	XL,Y+10
		ldd	XH,Y+14
		sixval	0x24
		ldd	XL,Y+12
		ldd	XH,Y+13
		sixval	0x25


		;step 8
		sixhex	0xeb0300		;CLR	W6
		do_nops	1

		ldi	r23,2

dspic_exprog_3:	sixhex	0xbb0bb6		;TBLWTL	[W6++],[W7]
		do_nops	2
		sixhex	0xbbdbb6		;TBLWTH.B	[W6++],[W7++]
		do_nops	2
		sixhex	0xbbebb6		;TBLWTH.B	[W6++],[++W7]
		do_nops	2
		sixhex	0xbb1bb6		;TBLWTL	[W6++],[W7++]
		do_nops	2
		dec	r23
		brne	dspic_exprog_3

		;setp 9 (repeat steps 7 + 8)
		adiw	YL,16			;increment pointer for next 4 instructions

		dec	ZL
		brne	dspic_exprog_2

		;step 10
		rcall	dspic_swrite
		do_nops	5


		;step 11
		ldi	ZL,LOW(P13)
		ldi	ZH,HIGH(P13)
		call	api_wait_ms

		rcall	dspic_ereset

		inc	r25
		pop	ZH
		dec	ZH
		breq	dspic_exprog_4
		rjmp	dspic_exprog_1

dspic_exprog_4:	jmp	main_loop_ok

;		sixhex	0x		;MOV
		


;------------------------------------------------------------------------------
; write out a 16 bit value, r20 = fill nibbles
;------------------------------------------------------------------------------
dspic_six16:	swap	r20
		mov	r23,r20
		ldi	r21,4
dspic_six16_a:	lsl	r23
		rol	XL
		rol	XH
		rol	r20
		dec	r21
		brne	dspic_six16_a
		rjmp	dspic_six


;------------------------------------------------------------------------------
; write out data word for key access
;------------------------------------------------------------------------------
dspic_outword:	ldi	r21,16
dspic_outw_1:	cbi	CTRLPORT,DS_DATA		;=0
		sbrc	XH,7
		sbi	CTRLPORT,DS_DATA		;=1
		nop
		nop
		sbi	CTRLPORT,DS_CLOCK		;clk=1
		nop
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		lsl	XL
		rol	XH
		dec	r21
		brne	dspic_outw_1
		ret

;------------------------------------------------------------------------------
; 5 clocks at entry
;------------------------------------------------------------------------------
dspic_outentry:	ldi	r21,5
dspic_oute_1:	cbi	CTRLPORT,DS_DATA		;=0
		nop
dspic_oute_2:	sbi	CTRLPORT,DS_CLOCK		;clk=1
		dec	r21
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		brne	dspic_oute_2
		ret


;------------------------------------------------------------------------------
; six serial execution
;------------------------------------------------------------------------------
dspic_six:	ldi	r21,4
dspic_six_1:	cbi	CTRLPORT,DS_DATA		;=0
		nop
dspic_six_2:	sbi	CTRLPORT,DS_CLOCK		;clk=1
		dec	r21
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		brne	dspic_six_2
		ldi	r21,24
dspic_six_3:	cbi	CTRLPORT,DS_DATA		;=0
		sbrc	XL,0
		sbi	CTRLPORT,DS_DATA		;=1
		nop
		nop
		sbi	CTRLPORT,DS_CLOCK		;clk=1
		nop
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		lsr	r20
		ror	XH
		ror	XL
		dec	r21
		brne	dspic_six_3
		ret

tgx:		ret

;------------------------------------------------------------------------------
; regout serial execution
;------------------------------------------------------------------------------
dspic_rgo:	sbi	CTRLPORT,DS_DATA		;=1
		sbi	CTRLPORT,DS_CLOCK		;clk=1
		cbi	CTRLPORT,DS_CLOCK		;clk=0

		ldi	r21,11
dspic_rgo_1:	cbi	CTRLPORT,DS_DATA		;=0
dspic_rgo_2:	sbi	CTRLPORT,DS_CLOCK		;clk=1
		dec	r21
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		brne	dspic_rgo_2
		ldi	r21,16
		cbi	CTRLDDR,DS_DATA			;input
		clr	XL
		clr	XH
dspic_rgo_3:	sbi	CTRLPORT,DS_CLOCK		;clk=1
		lsr	XH
		ror	XL
		sbic	CTRLPIN,DS_DATA
		ori	XH,0x80
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		dec	r21
		brne	dspic_rgo_3
		sbi	CTRLDDR,DS_DATA			;output
		ret

;------------------------------------------------------------------------------
; exit the reset vector
;------------------------------------------------------------------------------
dspic_ereset:	do_nops	3				;NOP
		do_six	0x04,0x02,0x00			;JMP 0x200
		do_nops	3
		ret

;------------------------------------------------------------------------------
; output r22 nop op
;------------------------------------------------------------------------------
dspic_nop:	clr	r20
		clr	XL
		clr	XH
		rcall	dspic_six
		dec	r22
		brne	dspic_nop
		ret

;------------------------------------------------------------------------------
; EICSP sanity check
;------------------------------------------------------------------------------
dspic_scheck:	ldi	ZL,200
		ldi	ZH,0
		call	api_wait_ms
		call	api_resetptr
		clr	XH
		ldi	XL,1
		rcall	dspic_wword
		cbi	CTRLDDR,DS_DATA			;input
		ldi	r20,100
		rcall	dspic_usec
		rcall	dspic_rword
		call	api_buf_lwrite			;write result to buffer
		ldi	r20,10
		rcall	dspic_usec
		rcall	dspic_rword
		call	api_buf_lwrite			;write result to buffer
		sbi	CTRLDDR,DS_DATA			;output
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EICSP bulk erase
;------------------------------------------------------------------------------
dspic_eraseb:	call	api_resetptr
		ldi	XH,0x70
		ldi	XL,0x01
		rcall	dspic_wword
		cbi	CTRLDDR,DS_DATA			;input
		ldi	ZL,250
		ldi	ZH,0
		call	api_wait_ms
		rcall	dspic_rword
		call	api_buf_lwrite			;write result to buffer
		ldi	r20,20
		rcall	dspic_usec
		rcall	dspic_rword
		call	api_buf_lwrite			;write result to buffer
		sbi	CTRLDDR,DS_DATA			;output
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EICSP program flash
;------------------------------------------------------------------------------
dspic_progp1:	ldi	YL,0				;PTR
		ldi	YH,1
		rcall	dspic_progp
		jmp	main_loop_ok

dspic_progp2:	ldi	YL,0				;PTR
		ldi	YH,1
		push	r16
		push	r17
		push	r18
		rcall	dspic_progp
		pop	r18
		pop	r17
		pop	r16
		inc	r17
		rcall	dspic_progp
		jmp	main_loop_ok

dspic_progp_0:	movw	r24,r16				;copy ptr
		ldi	YL,0				;PTR
		ldi	YH,1

dspic_progp:	ldi	XH,0x50
		ldi	XL,0xc3
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		clr	XH
		mov	XL,r18				;addr MSB
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		movw	XL,r16				;addr LS
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec

		ldi	r23,64

dspic_progp_1:	ld	XL,Y
		ldd	XH,Y+1
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		
		ldd	XL,Y+2
		ldd	XH,Y+6
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec

		ldd	XL,Y+4
		ldd	XH,Y+5
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec

		adiw	YL,8

		dec	r23
		brne	dspic_progp_1

		cbi	CTRLDDR,DS_DATA			;input
		ldi	ZL,3
		ldi	ZH,0
		call	api_wait_ms
		rcall	dspic_rword
		sts	0x100,XL
		sts	0x101,XH
		ldi	r20,100
		rcall	dspic_usec
		rcall	dspic_rword
		sts	0x102,XL
		sts	0x103,XH
		sbi	CTRLDDR,DS_DATA			;output
		ret

;------------------------------------------------------------------------------
; EICSP program config
;------------------------------------------------------------------------------
dspic_progc:	ldi	r24,4
		ldi	YL,0				;PTR
		ldi	YH,1

		ldi	r23,8

dspic_progc_1:	ldi	XH,0x40
		ldi	XL,0x04
		rcall	dspic_wword
		ldi	r20,20
		rcall	dspic_usec
		ldi	XH,0x00
		ldi	XL,0xf8				;addr MSB
		rcall	dspic_wword
		ldi	r20,20
		rcall	dspic_usec
		clr	XH
		mov	XL,r24				;addr LS
		rcall	dspic_wword
		ldi	r20,20
		rcall	dspic_usec
		ldi	XH,0x00				;data
		ld	XL,Y+
		rcall	dspic_wword
		ldi	r20,20
		rcall	dspic_usec

		cbi	CTRLDDR,DS_DATA			;input
		ldi	ZL,20
		ldi	ZH,0
		call	api_wait_ms
		rcall	dspic_rword
		ldi	r20,100
		rcall	dspic_usec
		rcall	dspic_rword
		sbi	CTRLDDR,DS_DATA			;output
		ldi	r20,100
		rcall	dspic_usec

		inc	r24
		inc	r24
		dec	r23
		brne	dspic_progc_1

		jmp	main_loop_ok

;------------------------------------------------------------------------------
; EICSP read flash
;------------------------------------------------------------------------------
dspic_readp:	ldi	YL,0				;PTR
		ldi	YH,1

		ldi	XH,0x20
		ldi	XL,0x04
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		ldi	XH,0x01				;256 instructions
		ldi	XL,0x00
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		clr	XH
		mov	XL,r18				;addr MSB
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		movw	XL,r16				;addr LS
		rcall	dspic_wword

		cbi	CTRLDDR,DS_DATA			;input
		ldi	r20,100
		rcall	dspic_usec
		rcall	dspic_rword
		sts	0x500,XL
		sts	0x501,XH
		ldi	r20,10
		rcall	dspic_usec
		rcall	dspic_rword
		sts	0x502,XL
		sts	0x503,XH

		ldi	r23,128

dspic_readp_1:	rcall	dspic_rword
		st	Y,XL
		std	Y+1,XH
;		ldi	r20,2
;		rcall	dspic_usec

		rcall	dspic_rword
		std	Y+2,XL
		std	Y+6,XH
		std	Y+3,const_0
		std	Y+7,const_0
;		ldi	r20,2
;		rcall	dspic_usec

		rcall	dspic_rword
		std	Y+4,XL
		std	Y+5,XH
;		ldi	r20,2
;		rcall	dspic_usec

		adiw	YL,8

		dec	r23
		brne	dspic_readp_1

		sbi	CTRLDDR,DS_DATA			;output
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EICSP read config
;------------------------------------------------------------------------------
dspic_readc:	ldi	YL,0				;PTR
		ldi	YH,1
		ldi	XL,8
dspic_readc_0:	st	Y+,const_0
		dec	XL
		brne	dspic_readc_0

		ldi	XH,0x10
		ldi	XL,0x03
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		ldi	XH,0x08				;no
		ldi	XL,0xf8				;addr MSB
		rcall	dspic_wword
		ldi	r20,10
		rcall	dspic_usec
		ldi	XH,0x00				;ADDR LSW
		ldi	XL,0x04
		rcall	dspic_wword

		cbi	CTRLDDR,DS_DATA			;input
		ldi	r20,100
		rcall	dspic_usec
		rcall	dspic_rword
		sts	0x130,XL
		sts	0x131,XH
		ldi	r20,10
		rcall	dspic_usec
		rcall	dspic_rword
		sts	0x132,XL
		sts	0x133,XH

		ldi	r23,8				;no of cfg words

dspic_readc_1:	rcall	dspic_rword
		st	Y+,XL
		st	Y+,const_0
		st	Y+,const_0
		st	Y+,const_0
		ldi	r20,10
		rcall	dspic_usec
		dec	r23
		brne	dspic_readc_1

		sbi	CTRLDDR,DS_DATA			;output
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EICSP blank check
;------------------------------------------------------------------------------
dspic_qblank:	jmp	main_loop_ok


;------------------------------------------------------------------------------
; EICSP write for busy (P9)
;------------------------------------------------------------------------------
dspic_wbusy:	cbi	CTRLDDR,DS_DATA			;input
		sbi	CTRLPORT,DS_DATA		;pull up
dspic_wbusy_1:	sbis	CTRLPIN,DS_DATA
		rjmp	dspic_wbusy_1
		rcall	dspic_wbusy_e
dspic_wbusy_2:	sbic	CTRLPIN,DS_DATA
		rjmp	dspic_wbusy_2
		ldi	r20,100
		rcall	dspic_usec
dspic_wbusy_e:	ret

;------------------------------------------------------------------------------
; EICSP write word
;------------------------------------------------------------------------------
dspic_wword:	ldi	r21,16
dspic_wword_1:	cbi	CTRLPORT,DS_DATA		;=0
		sbrc	XH,7
		sbi	CTRLPORT,DS_DATA		;=1
		nop
		nop
		nop
		nop
		nop
		sbi	CTRLPORT,DS_CLOCK		;clk=1
		nop
		nop
		nop
		nop
		nop
		nop
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		lsl	XL
		rol	XH
		dec	r21
		brne	dspic_wword_1
		ret

;------------------------------------------------------------------------------
; EICSP read word
;------------------------------------------------------------------------------
dspic_rword:	ldi	r21,16
		clr	XL
		clr	XH
dspic_rword_1:	sbi	CTRLPORT,DS_CLOCK		;clk=1
		nop
		nop
		nop
		nop
		nop
		lsl	XL
		rol	XH
		sbic	CTRLPIN,DS_DATA
		ori	XL,0x01
		cbi	CTRLPORT,DS_CLOCK		;clk=0
		nop
		nop
		nop
		nop
		nop
		dec	r21
		brne	dspic_rword_1
		ldi	r20,10
		rjmp	dspic_usec

;------------------------------------------------------------------------------
; wait r20 usec
;------------------------------------------------------------------------------
dspic_usec:	dec	r20
dspic_usec_1:	ldi	r21,6
dspic_usec_2:	dec	r21
		brne	dspic_usec_2
		dec	r20
		brne	dspic_usec_1
		ret

