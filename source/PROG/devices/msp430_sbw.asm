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

;Constants for the JTAG instruction register (IR, requires LSB first).
;The MSB has been interchanged with LSB due to use of the same shifting
;function as used for the JTAG data register (DR, requires MSB first).

.equ		SBWTCLK				= SIG1
.equ		SBWTDIO				= SIG2
.equ		SBW_TST				= SIG3
.equ		SBW_WAIT			= 3

;Instructions for the JTAG control signal register
.equ		msp_IR_CNTRL_SIG_M8BIT		= 0x11
.equ		msp_IR_CNTRL_SIG_L8BIT		= 0x12
.equ		msp_IR_CNTRL_SIG_16BIT		= 0x13
.equ		msp_IR_CNTRL_SIG_CAPTURE	= 0x14
.equ		msp_IR_CNTRL_SIG_RELEASE	= 0x15
;Instructions for the JTAG Fuse
.equ		msp_IR_PREPARE_BLOW		= 0x22
.equ		msp_IR_EX_BLOW			= 0x24
;Instructions for the JTAG data register
.equ		msp_IR_DATA_16BIT		= 0x41
.equ		msp_IR_DATA_CAPTURE		= 0x42
.equ		msp_IR_DATA_QUICK		= 0x43
;Instructions for the JTAG PSA mode
.equ		msp_IR_DATA_PSA			= 0x44
.equ		msp_IR_SHIFT_OUT_PSA		= 0x46
;Instructions for the JTAG address register
.equ		msp_IR_ADDR_16BIT		= 0x83
.equ		msp_IR_ADDR_CAPTURE		= 0x84
.equ		msp_IR_DATA_TO_ADDR		= 0x85
;additional instructions for JTAG91
.equ		msp_IR_COREIP_ID		= 0x17
.equ		msp_IR_DEVICE_ID		= 0x87
;Bypass instruction
.equ		msp_IR_BYPASS			= 0xFF
;mailbox exchange
.equ		msp_IR_JMB_EXCHANGE		= 0x61

;JTAG identification value for all existing Flash-based MSP430 devices
.equ		msp_JTAG_ID			= 0x91	;normal
.equ		msp_JTAG_IDV2			= 0x89	;XV2 devices

.equ		base_bytes			= 0x00	;load 256 bytes

.equ		SBW_DEBUG			= 0

;------------------------------------------------------------------------------
; macro definitions
;------------------------------------------------------------------------------
.macro	sbw_pulse
		rcall	sbw_w10
		cbi	CTRLPORT,SBWTCLK		;clock pulse H->L
		sbi	CTRLPORT,SBWTCLK		;clock pulse L->H
.endm

.macro sbwm_IR_Shift
		ldi	XL,@0
		rcall	sbw_IR_Shift
.endm

.macro sbwm_DR_Shift
		ldi	XL,LOW(@0)
		ldi	XH,HIGH(@0)
		rcall	sbw_DR_Shift16
.endm

.macro sbwm_DR_Shift8
		ldi	XH,@0
		ldi	r17,8
		rcall	sbw_DR_Shiftn
.endm

.macro sbwm_DR_Shift20
		ldi	XL,LOW(@0)
		ldi	XH,HIGH(@0)
		rcall	sbw_DR_Shift20
.endm

;------------------------------------------------------------------------------
; sme subroutines
;------------------------------------------------------------------------------
sbw_TMSLDH:	cbi	CTRLPORT,SBWTDIO		;clear sbwdata
		rcall	sbw_w10
		cbi	CTRLPORT,SBWTCLK		;clock of TMS slot
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTDIO		;set sbwdata
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTCLK		;end clock of tms slot
		rcall	sbw_w10
sbw_w10:	ret

;------------------------------------------------------------------------------
; shift out bit 0 of r20
;------------------------------------------------------------------------------
sbw_outbit:	sbrc	r20,0
		sbi	CTRLPORT,SBWTDIO		;set sbwdata
		sbrs	r20,0
		cbi	CTRLPORT,SBWTDIO		;clear sbwdata
sbw_outbit_0:	rcall	sbw_w10
		cbi	CTRLPORT,SBWTCLK		;clock pulse H->L
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTCLK		;clock pulse L->H
		rcall	sbw_w10
		ret

;------------------------------------------------------------------------------
; shift out 0-bit 
;------------------------------------------------------------------------------
sbw_outbit0:	cbi	CTRLPORT,SBWTDIO		;clear sbwdata
		rjmp	sbw_outbit_0

;------------------------------------------------------------------------------
; shift out 1-bit 
;------------------------------------------------------------------------------
sbw_outbit1:	sbi	CTRLPORT,SBWTDIO		;set sbwdata
		rjmp	sbw_outbit_0

;------------------------------------------------------------------------------
; shift in bit 0 of r20
;------------------------------------------------------------------------------
sbw_inbit:	cbi	CTRLDDR,SBWTDIO			;set to input
		cbi	CTRLPORT,SBWTDIO		;set sbwdata
		cbi	CTRLPORT,SBWTCLK		;clock pulse
		clr	r20
		rcall	sbw_w10
		sbic	CTRLPIN,SBWTDIO
		inc	r20
		sbi	CTRLPORT,SBWTDIO		;set sbwdata
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTCLK
		sbi	CTRLDDR,SBWTDIO			;set to output
		ret


sbw_ClrTCLK:	cbi	CTRLPORT,SBWTDIO		;clear sbwdata
		rcall	sbw_w10
		cbi	CTRLPORT,SBWTCLK		;clock of TMS slot
		rcall	sbw_w10
		sbic	GPIOR0,0
		sbi	CTRLPORT,SBWTDIO		;set sbwdata if stored = 1
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTCLK		;end clock of TMS slot
		rcall	sbw_outbit0			;TDI=L
		rcall	sbw_inbit			;ignore TDO
		cbi	GPIOR0,0			;TCLK_saved
		ret


sbw_SetTCLK:	cbi	CTRLPORT,SBWTDIO		;clear sbwdata
		rcall	sbw_w10
		cbi	CTRLPORT,SBWTCLK		;clock of TMS slot
		rcall	sbw_w10
		sbic	GPIOR0,0
		sbi	CTRLPORT,SBWTDIO		;set sbwdata if stored = 1
		rcall	sbw_w10
		sbi	CTRLPORT,SBWTCLK		;end clock of TMS slot
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit			;ignore TDO
		sbi	GPIOR0,0			;TCLK_saved
		ret

;------------------------------------------------------------------------------
; init spy by wire
;------------------------------------------------------------------------------
sbw_init:	cbi	CTRLPORT,SBWTCLK		;SBWTCK  LO
		cbi	CTRLPORT,SBWTDIO		;SBWTDIO LO
		sbi	CTRLDDR,SBWTCLK			;set to output 
		sbi	CTRLDDR,SBWTDIO
		rcall	sbw_init_w
		sbi	CTRLPORT,SBWTDIO		;SBWTDIO HI
		rcall	sbw_init_w
		sbi	CTRLPORT,SBWTCLK		;SBWTCK HI
		rcall	sbw_init_w
		cbi	CTRLPORT,SBWTCLK		;SBWTCK LO
		rcall	sbw_init_w
		sbi	CTRLPORT,SBWTCLK		;SBWTCK HI

sbw_init_w:	ldi	r21,160
sbw_init_w1:	dec	r21
		brne	sbw_init_w1
		ret

;------------------------------------------------------------------------------
; exit spy by wire
;------------------------------------------------------------------------------
sbw_exit:	cbi	CTRLPORT,SBWTCLK		;SBWTCK  LO
		cbi	CTRLPORT,SBWTDIO		;SBWTDIO LO
		sbi	CTRLDDR,SBWTCLK			;set to output 
		sbi	CTRLDDR,SBWTDIO
		cbi	CTRLDDR,SBWTCLK			;set to input 
		cbi	CTRLDDR,SBWTDIO
		rjmp	sbw_init_w

;------------------------------------------------------------------------------
; DR shift 16 bit (X -> Z)
;------------------------------------------------------------------------------
sbw_DR_Shift16:	ldi	r17,16
sbw_DR_Shiftn:	;JTAG FSM state = Run-Test/Idle
		rcall	sbw_outbit1			;TMS=H
		in	r20,GPIOR0
		rcall	sbw_outbit			;TDI=saved
		rcall	sbw_inbit
		;JTAG FSM state = Select DR-Scan
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Capture-DR 
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Shift-DR, Shift in TDI (16-bit)
sbw_DR_Shift_0:
sbw_DR_Shift_1:	ldi	r20,1
		cpse	r17,const_1
		ldi	r20,0
		rcall	sbw_outbit
		lsl	XL
		rol	XH
		rol	r20
		rcall	sbw_outbit
		rcall	sbw_inbit
		lsr	r20
		rol	ZL
		rol	ZH
		dec	r17
		brne	sbw_DR_Shift_1
		rjmp	sbw_IR_Shift_2


;------------------------------------------------------------------------------
; DR shift 20 bit (X -> Z) [only 16 bits used]
;------------------------------------------------------------------------------
sbw_DR_Shift20:	;JTAG FSM state = Run-Test/Idle
		rcall	sbw_outbit1			;TMS=H
		in	r20,GPIOR0
		rcall	sbw_outbit			;TDI=saved
		rcall	sbw_inbit
		;JTAG FSM state = Select DR-Scan
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Capture-DR 
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Shift-DR, Shift in TDI (16-bit)

		ldi	r17,4				;4 dummy bits
sbw_DR_Shift_5:	ldi	r20,0
		rcall	sbw_outbit
		rcall	sbw_outbit
		rcall	sbw_inbit
		dec	r17
		brne	sbw_DR_Shift_5
		ldi	r17,16
		rjmp	sbw_DR_Shift_0

;------------------------------------------------------------------------------
; IR shift 8 bit (XL -> ZL)
;------------------------------------------------------------------------------
sbw_IR_Shift:	;JTAG FSM state = Run-Test/Idle
		rcall	sbw_outbit1			;TMS=H
		in	r20,GPIOR0
		rcall	sbw_outbit			;TDI=saved
		rcall	sbw_inbit
		;JTAG FSM state = Select DR-Scan
		rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Select IR-Scan
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Capture-IR
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Shift-IR, Shift in TDI (8-bit)
		ldi	r17,8
sbw_IR_Shift_1:	ldi	r20,1
		cpse	r17,const_1
		ldi	r20,0
		rcall	sbw_outbit
		lsr	XL
		rol	r20
		rcall	sbw_outbit
		rcall	sbw_inbit
		lsr	r20
		ror	ZL
		dec	r17
		brne	sbw_IR_Shift_1

		;JTAG FSM state = Exit-IR (DR)
sbw_IR_Shift_2:	rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		;JTAG FSM state = Update-IR (DR)
		rcall	sbw_outbit0			;TMS=L
		in	r20,GPIOR0
		rcall	sbw_outbit			;TDI=saved
		rcall	sbw_inbit
		rjmp	sbw_init_w

;------------------------------------------------------------------------------
; reset TAP
;------------------------------------------------------------------------------
sbw_reset_TAP:	ldi	r17,6
sbw_res_TAP_1:	rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit
		dec	r17
		brne	sbw_res_TAP_1
		;JTAG FSM is now in Test-Logic-Reset
		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		;perform fuse check
		rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit


		rcall	sbw_outbit1			;TMS=H
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		rcall	sbw_outbit0			;TMS=L
		rcall	sbw_outbit1			;TDI=H
		rcall	sbw_inbit

		ret

;------------------------------------------------------------------------------
; Function to set the CPU into a controlled stop state
;------------------------------------------------------------------------------
sbw_HaltCPU:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		ldi	r18,100				;loops
sbw_SetIF_1:	sbwm_DR_Shift 0x0000
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		dec	r18
		brne	sbw_SetIF_1

		sbwm_IR_Shift	msp_IR_DATA_16BIT
		sbwm_DR_Shift	0x3FFF			;JMP $

		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2409			;set Halt bit

		rcall	sbw_SetTCLK
		ret

;------------------------------------------------------------------------------
; Function to set the CPU into a controlled stop state
;------------------------------------------------------------------------------
sbw_ReleaseCPU:	sbwm_IR_Shift	msp_IR_DATA_16BIT
		sbwm_DR_Shift	0x3FFF			;JMP $

		rcall	sbw_ClrTCLK			;Set CPU into instruction fetch mode

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2401
		sbwm_IR_Shift	msp_IR_ADDR_CAPTURE
		rcall	sbw_SetTCLK
		ret

;------------------------------------------------------------------------------
; Function to execute a Power-On Reset (POR) using JTAG CNTRL SIG register
;------------------------------------------------------------------------------
sbw_AssertPOR:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x1501			; se device into JTAG mode
		
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		ldi	r18,50				;loops
sbw_APOR_1:	sbwm_DR_Shift 0x0000
		dec	r18
		brne	sbw_APOR_1

sbw_APOR_2:	rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0c01			; Apply Reset
		sbwm_DR_Shift	0x0401			; Remove Reset
		ldi	YL,5
sbw_APOR_3:	rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		dec	YL
		brne	sbw_APOR_3
		sbwm_DR_Shift	0x0501			; Remove Reset
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000
		clt
		ret

;------------------------------------------------------------------------------
; check JTAG security fuse
;------------------------------------------------------------------------------
sbw_CheckLock:	clt
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0xaaaa
		cpi	ZL,0x55
		brne	sbw_CheckLk_2
		cpi	ZH,0x55
		brne	sbw_CheckLk_2
		set					; status is NOK
sbw_CheckLk_2:	ret

;------------------------------------------------------------------------------
; sync JTAG
;------------------------------------------------------------------------------
sbw_GetDevice:	sbwm_IR_Shift msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2401
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE

		ldi	r18,100				;num tries
sbw_GetDev_1:	sbwm_DR_Shift	0x0000
		dec	r18
		brne	sbw_GetDev_1
		sbrs	ZH,1
		set
		ret

;------------------------------------------------------------------------------
; read devic ID
;------------------------------------------------------------------------------
sbw_DevID:	ldi	XL,msp_IR_COREIP_ID
		rcall	sbw_IR_Shift
		ldi	XH,0x00				; set device into JTAG mode
		ldi	XL,0x00
		rcall	sbw_DR_Shift16
		mov	r16,ZL
		ret

;------------------------------------------------------------------------------
; read devic ID
;------------------------------------------------------------------------------
sbw_DevID2:	ldi	XL,msp_IR_DEVICE_ID
		rcall	sbw_IR_Shift
		ldi	XH,0x00				; set device into JTAG mode
		ldi	XL,0x00
		rjmp	sbw_DR_Shift20


;------------------------------------------------------------------------------
; par 1 is the requiered JTAG ID
;------------------------------------------------------------------------------
sbw_startup:	mov	r24,r16				;ID
		rcall	sbw_exit			;all signals to zero
		call	api_vcc_on			; poser on
		sbi	GPIOR0,0			; TCLK=1
		ldi	ZL,60				; wait a little bit
		ldi	ZH,0
		call	api_wait_ms

		rcall	sbw_init			;go into SBW mode
		rcall	sbw_init_w
		rcall	sbw_reset_TAP
		rcall	sbw_init_w
		sbwm_IR_Shift msp_IR_BYPASS
		sts	0x100,ZL			;store read ID
		cp	ZL,r24
		brne	sbw_startup_1			;ID is OK
		ret
sbw_startup_1:	ldi	r16,0x51			;error, no ID match
		pop	r0				;kill stack
		pop	r0
		rjmp	sbw_exit1


;------------------------------------------------------------------------------
; SBW init for F1/2/3/4
; PAR 1/2 = addr of WD register
; result = 0 / error, buf 0 = JTAG ID
;------------------------------------------------------------------------------
sbw_init1:	movw	r24,r18				;Position for watchdog register
		rcall	sbw_startup

sbw_init1_1:	clt
		ldi	r16,0x52			;lock error
		rcall	sbw_CheckLock
		brts	sbw_exit1

sbw_init1_2:	ldi	r16,0x53			;sync error
		rcall	sbw_GetDevice			;set CPU to sync state
		brts	sbw_exit1

		rcall	sbw_HaltCPU			;prepare for write memory

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
;		movw	XL,r24				;wd addr
;		rcall	sbw_DR_Shift16
		sbwm_DR_Shift	0x0120
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0x5a80
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK

sbw_init1_ok:	clr	r16
		jmp	main_loop

;------------------------------------------------------------------------------
; sbw mode exit for F1/2/3/4
;------------------------------------------------------------------------------
sbw_exit1:	rcall	sbw_exit			; disconnect
		call	api_vcc_off
		jmp	main_loop

;------------------------------------------------------------------------------
; readout memory for F1/2/3/4
;------------------------------------------------------------------------------
sbw_read1:	movw	r22,r16				;start addr
		movw	r24,r18				;word len

		call	api_resetptr
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2409

sbw_read1_1:	sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift16			;shift out address
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		sbwm_DR_Shift	0x0000
		movw	XL,ZL
		call	api_buf_lwrite
		sbiw	r24,1				;max bytes
		brne	sbw_read1_1
		rjmp	sbw_init1_ok

;------------------------------------------------------------------------------
; write for F1/2/3/4
;------------------------------------------------------------------------------
sbw_bwrite1:	movw	r22,r16				;start addr
		movw	r24,r18				;byte len

		;write data to RAM/IO
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2418			;byte write
		call	api_resetptr

sbw_bwrite1_1:	sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift16
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		call	api_buf_bread			;get data bytes
		clr	XH
		rcall	sbw_DR_Shift16
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		sbiw	r24,1
		brne	sbw_bwrite1_1

		rjmp	sbw_init1_ok

;------------------------------------------------------------------------------
; write for F1/2/3/4
;------------------------------------------------------------------------------
sbw_wwrite1:	movw	r22,r16				;start addr
		movw	r24,r18				;word len


		;write data to RAM/IO
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		call	api_resetptr

sbw_wwrite1_1:	sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift16
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		call	api_buf_lread			;get data bytes
		rcall	sbw_DR_Shift16
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		sbiw	r24,1
		brne	sbw_wwrite1_1

		rjmp	sbw_init1_ok


;------------------------------------------------------------------------------
; run for F1/2/3/4
;------------------------------------------------------------------------------
sbw_run1:	movw	r22,r16				;run addr

		rcall	sbw_ReleaseCPU

		;now write PC
sbw_run1_1:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x3401

		sbwm_IR_Shift	msp_IR_DATA_16BIT
		sbwm_DR_Shift	0x4030			;load PC

		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK

		movw	XL,r22				;run addr
		rcall	sbw_DR_Shift16
;		sbwm_DR_Shift	0x0200
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_CAPTURE
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2401

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_RELEASE
		rjmp	sbw_init1_ok

;------------------------------------------------------------------------------
; erase for F1/2/3/4
; r16 bit0=1 -> fast flash
;------------------------------------------------------------------------------
sbw_erase1:	movw	r18,r4
		ldi	r24,LOW(10600)
		ldi	r25,HIGH(10600)
		ldi	r23,1
		sbrc	r16,0				;1 = fast flash
		rjmp	sbw_erase1_1
		ldi	r24,LOW(5300)
		ldi	r25,HIGH(5300)
		ldi	r23,19

sbw_erase1_1:	rcall	sbw_HaltCPU			;prepare for write memory

sbw_erase1_2:	rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x0128
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa506			;mass erase all
		rcall	sbw_SetTCLK

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012a
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa540
		rcall	sbw_SetTCLK

		sbrs	r16,4
		rjmp	sbw_erase1_nu
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012c
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa540			;UNLOCK A
		rcall	sbw_SetTCLK

sbw_erase1_nu:

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0xfffe
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0x55aa
		rcall	sbw_SetTCLK

		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2409			;word read

		in	r18,CTRLPORT
		andi	r18,0xfc			;both zero
		mov	r19,r18
		ori	r19,0x01
		mov	r20,r18
		ori	r20,0x02
		mov	r21,r18
		ori	r21,0x03

		movw	XL,r24				;cycles

sbw_erase1_3:
		;sbw_SetTCLK
		out	CTRLPORT,r19			;1 end clock of TMS slot
		out	CTRLPORT,r18			;1 clock of TMS slot
		out	CTRLPORT,r19			;1 end clock of TMS slot

		out	CTRLPORT,r21			;1 end clock of TDI slot
		out	CTRLPORT,r20			;1 clock of TDI slot
		out	CTRLPORT,r21			;1 end clock of TDI slot

		cbi	CTRLDDR,SBWTDIO			;2 set to input
		out	CTRLPORT,r20			;1 clock of TDO slot
		out	CTRLPORT,r21			;1 end clock of TDO slot
		sbi	CTRLDDR,SBWTDIO			;2 set to output

		;sbw_ClrTCLK
		out	CTRLPORT,r19			;1 end clock of TMS slot
		out	CTRLPORT,r18			;1 clock of TMS slot
		out	CTRLPORT,r20			;1 clock of TDO slot
		out	CTRLPORT,r21			;1 end clock of TMS slot

		out	CTRLPORT,r19			;1 end clock of TDI slot
		out	CTRLPORT,r18			;1 clock of TDI slot
		out	CTRLPORT,r19			;1 end clock of TDI slot

		cbi	CTRLDDR,SBWTDIO			;2 set to input
		out	CTRLPORT,r18			;1 clock of TDO slot
		out	CTRLPORT,r19			;1 end clock of TDO slot
		sbi	CTRLDDR,SBWTDIO			;2 set to output

		sbiw	XL,1				;2
		brne	sbw_erase1_3			;2

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x0128
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa500
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012c
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa500
		rcall	sbw_SetTCLK

		dec	r23
		breq	sbw_erase1_4
		rjmp	sbw_erase1_2

sbw_erase1_4:	rcall	sbw_ReleaseCPU
		rjmp	sbw_init1_ok


;------------------------------------------------------------------------------
; program for F1/2/3/4
; r16 bit0=1 -> fast flash
;------------------------------------------------------------------------------
sbw_flash1:	movw	r22,r16				;start addr
		movw	r24,r18				;word len
		rcall	sbw_HaltCPU			;prepare for write memory
		call	api_resetptr

sbw_flash1_2:	rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x0128
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa540
		rcall	sbw_SetTCLK

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012a
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa540
		rcall	sbw_SetTCLK

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012c
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa500
		rcall	sbw_SetTCLK

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT

sbw_flash1_3:	sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,r22
		add	XL,YL
		adc	XH,YH
		rcall	sbw_DR_Shift16
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		call	api_buf_lread			;get data bytes
		rcall	sbw_DR_Shift16
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2409			;word read

		in	r18,CTRLPORT
		andi	r18,0xfc			;both zero
		mov	r19,r18
		ori	r19,0x01
		mov	r20,r18
		ori	r20,0x02
		mov	r21,r18
		ori	r21,0x03

		ldi	XL,35				;cycles

sbw_flash1_4:
		;sbw_SetTCLK
		out	CTRLPORT,r19			;1 end clock of TMS slot
		out	CTRLPORT,r18			;1 clock of TMS slot
		out	CTRLPORT,r19			;1 end clock of TMS slot

		out	CTRLPORT,r21			;1 end clock of TDI slot
		out	CTRLPORT,r20			;1 clock of TDI slot
		out	CTRLPORT,r21			;1 end clock of TDI slot

		cbi	CTRLDDR,SBWTDIO			;2 set to input
		out	CTRLPORT,r20			;1 clock of TDO slot
		out	CTRLPORT,r21			;1 end clock of TDO slot
		sbi	CTRLDDR,SBWTDIO			;2 set to output

		;sbw_ClrTCLK
		out	CTRLPORT,r19			;1 end clock of TMS slot
		out	CTRLPORT,r18			;1 clock of TMS slot
		out	CTRLPORT,r20			;1 clock of TDO slot
		out	CTRLPORT,r21			;1 end clock of TMS slot

		out	CTRLPORT,r19			;1 end clock of TDI slot
		out	CTRLPORT,r18			;1 clock of TDI slot
		out	CTRLPORT,r19			;1 end clock of TDI slot

		cbi	CTRLDDR,SBWTDIO			;2 set to input
		out	CTRLPORT,r18			;1 clock of TDO slot
		out	CTRLPORT,r19			;1 end clock of TDO slot
		sbi	CTRLDDR,SBWTDIO			;2 set to output

		dec	XL				;2
		brne	sbw_flash1_4			;2

		sbiw	r24,1
		brne	sbw_flash1_3

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x2408			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x0128
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa500
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift	0x012c
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0xa500
		rcall	sbw_SetTCLK

		rcall	sbw_ReleaseCPU
		rjmp	sbw_init1_ok


;----------------------------------------------------------------------
; F5xxx routines
;----------------------------------------------------------------------
sbw_init2:	rcall	sbw_startup			;

		rcall	sbw_CheckLock

		sbwm_IR_Shift msp_IR_JMB_EXCHANGE
		sbwm_DR_Shift 0x0011
		andi	ZL,0xf0				;mask bits
		sbwm_DR_Shift 0xa55a
		sbwm_DR_Shift 0x1e1e

		cbi	CTRLDDR,SBWTCLK			;set to input
		cbi	CTRLDDR,SBWTDIO

		ldi	ZL,15				;15ms wait
		ldi	ZH,0
		call	api_wait_ms

		rcall	sbw_init			;go into SBW mode
		rcall	sbw_init_w
		rcall	sbw_reset_TAP			;[D] reset JTAG-TAP
		rcall	sbw_init_w

		sbwm_IR_Shift msp_IR_JMB_EXCHANGE

		;now send the password
		ldi	YL,16				;words to send
		sbwm_DR_Shift 0x0001

sbw_init2_1:	ldi	ZL,1
		clr	ZH
		call	api_wait_ms
		sbwm_DR_Shift 0xffff
		dec	YL
		brne	sbw_init2_1

		rcall	sbw_AssertPOR

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000

		;disable watchdog
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0500			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		sbwm_DR_Shift20	0x015c
		rcall	sbw_SetTCLK
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		sbwm_DR_Shift	0x5a80
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0501
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK

sbw_init2_ok:	clr	r16
		jmp	main_loop


;------------------------------------------------------------------------------
; readout memory for F5/6
;------------------------------------------------------------------------------
sbw_read2:	movw	r22,r16				;start addr
		movw	r24,r18				;word len
		call	api_resetptr

sbw_read2_1:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0501			;word read
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift20
		rcall	sbw_SetTCLK
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		sbwm_DR_Shift	0x0000
		movw	XL,ZL
		call	api_buf_lwrite
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbiw	r24,1				;max words
		brne	sbw_read2_1
		rjmp	sbw_init2_ok

;------------------------------------------------------------------------------
; byte write for F5/6
;------------------------------------------------------------------------------
sbw_bwrite2:	movw	r22,r16				;start addr
		movw	r24,r18				;byte len

		;write data to RAM/IO
		call	api_resetptr

sbw_bwrite2_1:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0510			;byte write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift20
		rcall	sbw_SetTCLK
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		call	api_buf_bread			;get data bytes
		clr	XH
		rcall	sbw_DR_Shift16
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0501
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbiw	r24,1				;max words
		brne	sbw_bwrite2_1
		rjmp	sbw_init2_ok


;------------------------------------------------------------------------------
; word write for F5/6
;------------------------------------------------------------------------------
sbw_wwrite2:	movw	r22,r16				;start addr
		movw	r24,r18				;word len

		;write data to RAM/IO
		call	api_resetptr

sbw_wwrite2_1:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0500			;word write
		sbwm_IR_Shift	msp_IR_ADDR_16BIT
		movw	XL,YL				;copy address
		add	XL,r22				;add base addr
		adc	XH,r23
		rcall	sbw_DR_Shift20
		rcall	sbw_SetTCLK
		sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
		call	api_buf_lread			;get data bytes
		rcall	sbw_DR_Shift16
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0501
		rcall	sbw_SetTCLK
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbiw	r24,1				;max words
		brne	sbw_wwrite2_1
		rjmp	sbw_init2_ok

;------------------------------------------------------------------------------
; single word read for F5/6
; r24/r25		ADDR
; r22/r23	DATA 
;------------------------------------------------------------------------------
sbw_rword2:		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
			sbwm_DR_Shift	0x0000
			rcall	sbw_ClrTCLK
			sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
			sbwm_DR_Shift	0x0501			;word read
			sbwm_IR_Shift	msp_IR_ADDR_16BIT
			movw	XL,r24				;copy address
			rcall	sbw_DR_Shift20
			rcall	sbw_SetTCLK
			sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
			rcall	sbw_SetTCLK
			rcall	sbw_ClrTCLK
			sbwm_DR_Shift	0x0000
			movw	r22,ZL
			rcall	sbw_SetTCLK
			rcall	sbw_ClrTCLK
			rcall	sbw_SetTCLK
			ret

;------------------------------------------------------------------------------
; single word write for F5/6
; r24/r25	ADDR
; r22/r23	DATA 
;------------------------------------------------------------------------------
sbw_wword2:		sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
			sbwm_DR_Shift	0x0000
			rcall	sbw_ClrTCLK
			sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
			sbwm_DR_Shift	0x0500			;word write
			sbwm_IR_Shift	msp_IR_ADDR_16BIT
			movw	XL,r24				;copy address
			rcall	sbw_DR_Shift20
			rcall	sbw_SetTCLK
			sbwm_IR_Shift	msp_IR_DATA_TO_ADDR
			movw	XL,r22				;get data bytes
			rcall	sbw_DR_Shift16
			rcall	sbw_ClrTCLK
			sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
			sbwm_DR_Shift	0x0501
			rcall	sbw_SetTCLK
			rcall	sbw_ClrTCLK
			rcall	sbw_SetTCLK
			ret

;------------------------------------------------------------------------------
; erase for F5/F6
; R16/R17	= CMD (0x502 segment, 0x504 sector)
; R18/R19	= ADDR
;------------------------------------------------------------------------------
sbw_erase2:		movw	r4,r16
			ldi	r24,0x44		;FCTL3x
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_erase2
			
			ldi	XL,0x00
			ldi	XH,0xA5
			sbrc	r22,6
			ldi	XL,0x40
			movw	r22,XL
			rcall	sbw_wword2		;unlock

			ldi	r24,0x40		;FCTL1x
			ldi	r25,0x01
			movw	r22,r4			;get CMD
			rcall	sbw_wword2
									
			movw	r24,r18			;ADDR
			rcall	sbw_wword2		;dummy write
			
sbw_erase2_1:		ldi	r24,0x44		;FCTL3x
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_erase2_1
			
			ldi	r22,0x10
			ldi	r23,0xA5
			rcall	sbw_wword2		;lock
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; program for F5/F6 (longwords)
; R16/R17	= ADDR
; R18/R19	= WORD LEN
;------------------------------------------------------------------------------
sbw_program2:		movw	r4,r16			;store ADDR
			call	api_resetptr

sbw_program2_1:		ldi	r24,0x44		;FCTL3x, wait for busy=0
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_program2_1
			
			ldi	XL,0x00	
			ldi	XH,0xA5
			sbrc	r22,6
			ldi	XL,0x40
			movw	r22,XL
			rcall	sbw_wword2		;unlock

			ldi	r24,0x40		;FCTL1x
			ldi	r25,0x01
			ldi	r22,0x80		;BLKWRT
			ldi	r23,0xA5
			rcall	sbw_wword2
													
sbw_program2_loop:	movw	r24,r4			;addr
			call	api_buf_lread
			movw	r22,XL			;data
			rcall	sbw_wword2		;data write			
			adiw	r24,2
			call	api_buf_lread
			movw	r22,XL			;data
			rcall	sbw_wword2		;data write			
			adiw	r24,2
			movw	r4,r24		
				
sbw_program2_2:		ldi	r24,0x44		;FCTL3x
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_program2_2
			
sbw_program2_next:	movw	XL,r18			;counter
			sbiw	XL,2
			movw	r18,XL			
			
			brne	sbw_program2_1

			ldi	YL,0x44			;FCTL3x
			ldi	YH,0x01
			ldi	r22,0x10
			ldi	r23,0xA5
			rcall	sbw_wword2		;lock
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; program for F5/F6 (words, currently not used)
; R16/R17	= ADDR
; R18/R19	= WORD LEN
;------------------------------------------------------------------------------
sbw_program2b:		movw	r4,r16			;store ADDR
			call	api_resetptr

sbw_program2b_1:	ldi	r24,0x44		;FCTL3x, wait for busy=0
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_program2b_1
			
			ldi	XL,0x00	
			ldi	XH,0xA5
			sbrc	r22,6
			ldi	XL,0x40
			movw	r22,XL
			rcall	sbw_wword2		;unlock

			ldi	r24,0x40		;FCTL1x
			ldi	r25,0x01
			ldi	r22,0x40		;WRT
			ldi	r23,0xA5
			rcall	sbw_wword2
									
sbw_program2b_loop:	call	api_buf_lread
			movw	r22,XL			;data
			cpi	XL,0xff
			brne	sbw_program2b_do
			cpi	XH,0xff
			breq	sbw_program2b_next	
				
sbw_program2b_do:	movw	r24,r4			;addr
			rcall	sbw_wword2		;data write
			
sbw_program2b_2:		ldi	r24,0x44		;FCTL3x
			ldi	r25,0x01
			rcall	sbw_rword2
			sbrc	r22,0
			rjmp	sbw_program2b_2
			
sbw_program2b_next:	movw	XL,r4			;ADDR
			adiw	XL,2
			movw	r4,XL			

			movw	XL,r18			;counter
			sbiw	XL,1
			movw	r18,XL			
			
			brne	sbw_program2b_1

			ldi	YL,0x44			;FCTL3x
			ldi	YH,0x01
			ldi	r22,0x10
			ldi	r23,0xA5
			rcall	sbw_wword2		;lock
			
			jmp	main_loop_ok
			

;------------------------------------------------------------------------------
; run for F1/2/3/4
;------------------------------------------------------------------------------
sbw_run2:	movw	r22,r16				;run addr

		;now write PC
sbw_run2_1:	sbwm_IR_Shift	msp_IR_CNTRL_SIG_CAPTURE
		sbwm_DR_Shift	0x0000

		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_DATA_16BIT

		rcall	sbw_SetTCLK
		sbwm_DR_Shift	0x0080
		rcall	sbw_ClrTCLK

		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x1400
		sbwm_IR_Shift	msp_IR_DATA_16BIT
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbwm_DR_Shift	0x1c00
		rcall	sbw_ClrTCLK
		rcall	sbw_SetTCLK
		sbwm_DR_Shift	0x4303
		rcall	sbw_ClrTCLK
		sbwm_IR_Shift	msp_IR_ADDR_CAPTURE
		sbwm_DR_Shift20	0x0000

		;release
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_16BIT
		sbwm_DR_Shift	0x0401			;prepare release
		sbwm_IR_Shift	msp_IR_ADDR_CAPTURE
		sbwm_IR_Shift	msp_IR_CNTRL_SIG_RELEASE

		rjmp	sbw_init2_ok

;------------------------------------------------------------------------------
; write to JTAG mailbox
;------------------------------------------------------------------------------
sbw_boxwrite:	ldi	r22,LOW(3000)
		ldi	r23,HIGH(3000)
		sbwm_IR_Shift	msp_IR_JMB_EXCHANGE
		sbic	GPIOR0,2			;skip if no JTAG17 error
		rjmp	sbw_boxwrite_5

sbw_boxwrite_1:	sbwm_DR_Shift	0			;set
		sbrc	XL,0				;skip if not ready
		rjmp	sbw_boxwrite_2			;OK, ready
		sub	r22,const_1
		sbc	r23,const_0
		brne	sbw_boxwrite_1
		pop	r0
		pop	r0
		ldi	r16,0x61			;write readout
		jmp	main_loop

sbw_boxwrite_2:	sbwm_DR_Shift	1			;write
sbw_boxwrite_3:	call	api_buf_lread			;get data bytes
		rcall	sbw_DR_Shift16
		ret

sbw_boxwrite_5:	sbwm_DR_Shift	0			;set
		sbrc	XL,0				;skip if not ready
		rjmp	sbw_boxwrite_3			;OK, ready
		sub	r22,const_1
		sbc	r23,const_0
		brne	sbw_boxwrite_5
		pop	r0
		pop	r0
		ldi	r16,0x61			;write readout
		jmp	main_loop

;------------------------------------------------------------------------------
; read from JTAG mailbox
;------------------------------------------------------------------------------
sbw_boxread:	ldi	r22,LOW(3000)
		ldi	r23,HIGH(3000)

sbw_boxread_1:	sbwm_IR_Shift	msp_IR_JMB_EXCHANGE
		sbwm_DR_Shift	0			;set
		sbrc	XL,3				;skip if no data
		rjmp	sbw_boxread_2			;OK, data available
		sub	r22,const_1
		sbc	r23,const_0
		brne	sbw_boxread_1
		pop	r0
		pop	r0
		ldi	r16,0x62			;read readout
		jmp	main_loop

sbw_boxread_2:	sbwm_DR_Shift	4			;read
		sbwm_DR_Shift	0			;dummy
		call	api_buf_lwrite			;put data bytes
		ret

;------------------------------------------------------------------------------
; read from JTAG mailbox
;------------------------------------------------------------------------------
sbw_boxtrans:	movw	r24,r16				;words to write
		cbi	GPIOR0,2			;no JATAG17 error
		sbrc	r25,7
		sbi	GPIOR0,2			;no JATAG17 error
		andi	r25,0x7f
		call	api_resetptr

sbw_boxtrans_1:	rcall	sbw_boxwrite
		sbiw	r24,1
		brne	sbw_boxtrans_1

		call	api_resetptr
		movw	r24,r18
sbw_boxtrans_2:	rcall	sbw_boxread
		sbiw	r24,1
		brne	sbw_boxtrans_2
		jmp	main_loop

