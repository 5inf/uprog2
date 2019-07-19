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

;pic offset
;
.equ	PIC2_EECON1	= 4	;r4
.equ	PIC2_EEADR	= 5
.equ	PIC2_EEADRH	= 6
.equ	PIC2_EEDATA	= 7
.equ	PIC2_TBLPTRU	= 8
.equ	PIC2_TBLPTRH	= 9
.equ	PIC2_TBLPTRL	= 10
.equ	PIC2_TABLAT	= 11

.equ	PIC2_MOVLW	= 0x0e
.equ	PIC2_MOVWF	= 0x6e
.equ	PIC2_MOVF	= 0x50
.equ	PIC2_8E		= 0x8e
.equ	PIC2_9C		= 0x9c
.equ	PIC2_9E		= 0x9e
.equ	PIC2_84		= 0x84
.equ	PIC2_8C		= 0x8c
.equ	PIC2_82		= 0x82
.equ	PIC2_80		= 0x80
.equ	PIC2_94		= 0x94

.MACRO pic2_rcmd
	lds	XL,@1
	ldi	XH,@0
	rcall	pic2_six
.ENDM

.MACRO pic2_vcmd
	ldi	XL,@1
	ldi	XH,@0
	rcall	pic2_six
.ENDM

.MACRO pic2_sixhex
	ldi	XL,(@0 & 0xff)
	ldi	XH,(@0 >> 8)
	rcall	pic2_six
.ENDM


.MACRO pic2_twhex
	ldi	XL,(@0 & 0xff)
	ldi	XH,(@0 >> 8)
	rcall	pic2_twrite
.ENDM

;------------------------------------------------------------------------------
; init and send key (if par4=1)
;------------------------------------------------------------------------------
pic2_init:		ldi	YL,0			;copy table
			ldi	YH,1
			ldi	XL,4			;base register
			ldi	XH,0
			ldi	r16,10
pic2_init_1:		ld	r17,Y+
			st	X+,r17
			dec	r16
			brne	pic2_init_1

			cbi	CTRLPORT,DS_DATA	;all low
			cbi	CTRLPORT,DS_CLOCK	;all low
			sbi	CTRLDDR,DS_DATA		;all to output
			sbi	CTRLDDR,DS_CLOCK	;all to output

			call	api_vcc_on
			rcall	pic_w20ms

			call	api_vpp_on
			rcall	pic_w20ms

			sbrc	r19,0
			rcall	pic2_okey		;emit key

			jmp	main_loop_ok

			;omit key
pic2_okey:		ldi	XH,0x4d
			ldi	XL,0x43
			rcall	pic2_outword
			ldi	XH,0x48
			ldi	XL,0x50
			rjmp	pic2_outword


;------------------------------------------------------------------------------
; erase
; r16=bit 0 write 2/3 bytes
; r17=3c0006
; r18=3c0005
; r19=3c0004
;------------------------------------------------------------------------------
pic2_erase:		pic2_vcmd	PIC2_MOVLW,0x3C			;movlw 3ch
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRU		;movwf TBLPTRU

			pic2_vcmd	PIC2_MOVLW,0x00			;movlw 00h
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRH		;movwf TBLPTRH
		
			pic2_vcmd	PIC2_MOVLW,0x04			;movlw 04h
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRL		;movmf TBLPTRL
			mov	XL,r19					;data for 0x3c0004
			mov	XH,XL					;data for 0x3c0004
			rcall	pic2_twrite
		
			pic2_vcmd	PIC2_MOVLW,0x05			;movlw 05h
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRL		;movwf TBLPTRL
			mov	XL,r18					;data for 0x3c0005
			mov	XH,XL					;data for 0x3c0005
			rcall	pic2_twrite
				
			sbrs	r16,0
			rjmp	pic2_erase_1
		
			pic2_vcmd	PIC2_MOVLW,0x06			;movlw 06h
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRL		;movwf TBLPTRL
			mov	XL,r17					;data for 0x3c0006
			mov	XH,XL					;data for 0x3c0006
			rcall	pic2_twrite


pic2_erase_1:		
			pic2_sixhex	0x0000		;NOP

			cbi	CTRLPORT,DS_DATA		;=1
			rcall	pic2_clock			;data
			rcall	pic2_clock			;data
			rcall	pic2_clock			;data
			rcall	pic2_clock			;data

			ldi	ZL,20
			ldi	ZH,0
			call	api_wait_ms

			ldi	r16,16
pic2_erase_2:		rcall	pic2_clock			;data
			dec	r16
			brne	pic2_erase_2

			jmp	main_loop_ok


;------------------------------------------------------------------------------
; readf 256B blocks
; par1 = AADRL
; par2 = ADDRH
; par3 = ADDRU
; par4 = blocks
;------------------------------------------------------------------------------
pic2_readf:		call	api_resetptr
			mov	r24,r16
			rcall	pic2_addrout

pic2_readf_1:		ldi		r24,0
pic2_readf_2:		rcall		pic2_rtabi
			call	api_buf_bwrite		;write result to buffer
			dec		r24
			brne		pic2_readf_2
			dec		r19
			brne		pic2_readf_1

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read bytes
; par1 = AADRL
; par2 = ADDRH
; par3 = ADDRU
; par4 = bytes
;------------------------------------------------------------------------------
pic2_readb:		call	api_resetptr
			mov	r24,r16
			rcall	pic2_addrout

pic2_readb_1:		rcall		pic2_rtabi
			call	api_buf_bwrite		;write result to buffer
			dec		r19
			brne		pic2_readb_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; progf 2K blocks (par 1/2/3), par4=pagesize
; par1 = AADRL
; par2 = ADDRH
; par3 = ADDRU
; par4 = pagesize
;------------------------------------------------------------------------------
pic2_progf:		call	api_resetptr
			pic2_rcmd	PIC2_8E,PIC2_EECON1		;bsf EECON1,EEPGD
			pic2_rcmd	PIC2_9C,PIC2_EECON1		;bcf EECON1,CFGS
			pic2_rcmd	PIC2_84,PIC2_EECON1		;bsf EECON1,bsf EECON1,WREN
			
			mov	r24,r16
			rcall	pic2_addrout

pic2_progf_1:		mov		r24,r19		;pagesize in words
			dec		r24
pic2_progf_2:		call	api_buf_lread
			rcall		pic2_twritei	;write + increment
			dec		r24
			brne		pic2_progf_2
			call	api_buf_lread
			rcall		pic2_twritepi	;write, program and increment
			ldi		ZL,1
			rcall		pic2_p9

			cpi		YH,8
			brne		pic2_progf_1

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; prog UID (Par4 = words)
; par1 = AADRL
; par2 = ADDRH
; par3 = ADDRU
; par4 = words
;------------------------------------------------------------------------------
pic2_progu:		call	api_resetptr
			pic2_rcmd	PIC2_8E,PIC2_EECON1		;bsf EECON1,EEPGD
			pic2_rcmd	PIC2_9C,PIC2_EECON1		;bcf EECON1,CFGS
			pic2_rcmd	PIC2_84,PIC2_EECON1		;bsf EECON1,bsf EECON1,WREN
			
			mov	r24,r16
			rcall	pic2_addrout

pic2_progu_1:		mov		r24,r19		;length in words
			dec		r24
pic2_progu_2:		call	api_buf_lread
			rcall		pic2_twritei	;write + increment
			dec		r24
			brne		pic2_progu_2
			call	api_buf_lread
			rcall		pic2_twritepi	;write, program and increment
			ldi		ZL,1
			rcall		pic2_p9

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; prog config word
;------------------------------------------------------------------------------
pic2_progc:		call	api_resetptr
			pic2_rcmd	PIC2_8E,PIC2_EECON1		;bsf EECON1,EEPGD
			pic2_rcmd	PIC2_8C,PIC2_EECON1		;bsf EECON1,CFGS
			pic2_rcmd	PIC2_84,PIC2_EECON1		;bsf EECON1,bsf EECON1,WREN
			
			mov	r24,r16
			rcall	pic2_addrout

			call		api_buf_bread
			mov		XH,XL
			rcall		pic2_twritep	;write, program
;		pic2_sixhex	0x0000		;nop
			ldi		ZL,5
			rcall		pic2_p9

			inc		r24
			rcall		pic2_addrout

			call		api_buf_bread
			mov		XH,XL
			rcall		pic2_twritep	;write, program
;		pic2_sixhex	0x0000		;nop

			ldi		ZL,5
			rcall		pic2_p9

			jmp		main_loop_ok


;------------------------------------------------------------------------------
; readout eeprom data (addr 1/2) length(3/4)
;------------------------------------------------------------------------------
pic2_reade:		movw		r24,r16		;address
			call	api_resetptr

pic2_reade_1:
			pic2_rcmd	PIC2_9E,PIC2_EECON1		;bcf EECON1,EEPGD
			pic2_rcmd	PIC2_9C,PIC2_EECON1		;bcf EECON1,CFGS

			mov		XL,r24		;
			ldi		XH,0x0E
			rcall		pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_EEADR		;movwf EEADR
			mov		XL,r25
			ldi		XH,0x0E
			rcall		pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_EEADRH		;movwf EEADRH

			pic2_rcmd	PIC2_80,PIC2_EECON1		;bsf EECON1,RD
			pic2_rcmd	PIC2_MOVF,PIC2_EEDATA		;movf EEDATA,W,0
			pic2_rcmd	PIC2_MOVWF,PIC2_TABLAT		;movwf TABLAT

			pic2_sixhex	0x0000				;nop
			rcall		pic2_rtab
			call		api_buf_bwrite			;write result to buffer
			adiw		r24,1
			sub		r18,const_1
			sbc		r19,const_0
			brne		pic2_reade_1

			jmp		main_loop_ok

;------------------------------------------------------------------------------
; program eeprom data (addr 1/2) length(3/4)
;------------------------------------------------------------------------------
pic2_proge:		movw		r24,r16		;address
			call		api_resetptr

pic2_proge_1:
			pic2_rcmd	PIC2_9E,PIC2_EECON1		;bcf EECON1,EEPGD
			pic2_rcmd	PIC2_9C,PIC2_EECON1		;bcf EECON1,CFGS

			mov		XL,r24
			ldi		XH,0x0E
			rcall		pic2_six

			pic2_rcmd	PIC2_MOVWF,PIC2_EEADR		;movwf EEADR
			mov		XL,r25
			ldi		XH,0x0E
			rcall		pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_EEADRH		;movwf EEADRH

			call		api_buf_bread	;get data
			ldi		XH,0x0E
			rcall		pic2_six

			pic2_rcmd	PIC2_MOVWF,PIC2_EEDATA		;movwf EEDATA
			
			pic2_rcmd	PIC2_84,PIC2_EECON1		;bsf EECON1,WREN
			pic2_rcmd	PIC2_82,PIC2_EECON1		;bsf EECON1,WR
			
			pic2_sixhex	0x0000		;nop
			pic2_sixhex	0x0000		;nop

			ldi		ZL,5
			ldi		ZH,0
			call		api_wait_ms

			pic2_rcmd	PIC2_94,PIC2_EECON1		;bcf EECON1,WREN


			adiw		r24,1
			sub		r18,const_1
			sbc		r19,const_0
			brne		pic2_proge_1

			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write out data word for key access
;------------------------------------------------------------------------------
pic2_outword:		ldi	r21,16
pic2_outw_1:		cbi	CTRLPORT,DS_DATA		;=0
			sbrc	XH,7
			sbi	CTRLPORT,DS_DATA		;=1
			nop
			nop
			sbi	CTRLPORT,DS_CLOCK		;clk=1
			nop
			lsl	XL
			rol	XH
			cbi	CTRLPORT,DS_CLOCK		;clk=0
			dec	r21
			brne	pic2_outw_1
			ret

;------------------------------------------------------------------------------
; six serial execution (X)
;------------------------------------------------------------------------------
pic2_p9:		cbi	CTRLPORT,DS_DATA		;=0
			rcall	pic2_clock			;data
			rcall	pic2_clock			;data
			rcall	pic2_clock			;data
			sbi	CTRLPORT,DS_CLOCK		;clk=1
			clr	ZH
			call	api_wait_ms
			cbi	CTRLPORT,DS_CLOCK		;clk=0
			ldi	ZL,1
			call	api_wait_ms
			clr	XL
			clr	XH
			rjmp	pic2_cmdp

pic2_six:		ldi	r20,0x00			;core instruction
			rjmp	pic2_cmd

pic2_twrite:		ldi	r20,0x0c			;table write
			rjmp	pic2_cmd

pic2_twritei:		ldi	r20,0x0d			;table write, post increment +2
			rjmp	pic2_cmd

pic2_twritep:		ldi	r20,0x0f			;table write, program
			rjmp	pic2_cmd

pic2_twritepi:		ldi	r20,0x0e			;table write, program, post increment +2
			rjmp	pic2_cmd

pic2_cmd:		sbi	CTRLDDR,DS_DATA
			cbi	CTRLPORT,DS_DATA
			ldi	r21,4
pic2_cmd_1:		sbrc	r20,0
			sbi	CTRLPORT,DS_DATA		;=1
			sbrs	r20,0
			cbi	CTRLPORT,DS_DATA		;=1
			rcall	pic2_clock			;data
			lsr	r20
			dec	r21
			brne	pic2_cmd_1

pic2_cmdp:		ldi	r21,16
pic2_cmd_2:		sbrc	XL,0
			sbi	CTRLPORT,DS_DATA		;=1
			sbrs	XL,0
			cbi	CTRLPORT,DS_DATA		;=1
			rcall	pic2_clock			;data
			lsr	XH
			ror	XL
			dec	r21
			brne	pic2_cmd_2
			ldi	r21,20
pic_cmd_3:		dec	r21
			brne	pic_cmd_3
			ret

;------------------------------------------------------------------------------
; table read data to XL
;------------------------------------------------------------------------------
pic2_rtab:		cbi	CTRLPORT,DS_DATA
			rcall	pic2_clock			;0
			sbi	CTRLPORT,DS_DATA
			rcall	pic2_clock			;1
			cbi	CTRLPORT,DS_DATA
			rcall	pic2_clock			;0
			rcall	pic2_clock			;0
			rjmp	pic2_rtabi_0

pic2_rtabi:		sbi	CTRLPORT,DS_DATA
			sbi	CTRLDDR,DS_DATA			;output
			rcall	pic2_clock			;1
			cbi	CTRLPORT,DS_DATA
			rcall	pic2_clock			;0
			rcall	pic2_clock			;0
			sbi	CTRLPORT,DS_DATA
			rcall	pic2_clock			;1

pic2_rtabi_0:		cbi	CTRLPORT,DS_DATA		;->0

			ldi	r21,8
pic2_rtabi_1:		rcall	pic2_clock			;1
			dec	r21
			brne	pic2_rtabi_1

			ldi	r21,8
			cbi	CTRLDDR,DS_DATA			;input
			clr	XL
pic2_rtabi_3:		rcall	pic2_clock			;1
			lsr	XL
			sbic	CTRLPIN,DS_DATA
			ori	XL,0x80
			dec	r21
			brne	pic2_rtabi_3
			ret


pic2_clock:		sbi	CTRLPORT,DS_CLOCK		;clk=1
			nop
			nop
			nop
			nop
			cbi	CTRLPORT,DS_CLOCK		;clk=0
			ret


pic2_addrout:		mov		XL,r18
			ldi		XH,0x0E
			rcall	pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRU		;movwf TBLPTRU
			mov		XL,r17
			ldi		XH,0x0E
			rcall	pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRH		;movwf TBLPTRH
			mov		XL,r24
			ldi		XH,0x0E
			rcall	pic2_six
			pic2_rcmd	PIC2_MOVWF,PIC2_TBLPTRL		;movwf TBLPTRL
			ret
