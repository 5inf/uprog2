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

.equ			PSOC4_RST		= SIG1
.equ			PSOC4_CLOCK		= SIG2
.equ			PSOC4_DATA		= SIG3
.equ			PSOC4_TDATA		= SIG4
.equ			PSOC4_TCMD		= SIG5

.equ			PSOC4_READ_IDCODE	= 0xa5
.equ			PSOC4_WRITE_CTRL	= 0x95
.equ			PSOC4_READ_STAT		= 0xb5
.equ			PSOC4_WRITE_SELECT	= 0x8d
.equ			PSOC4_READ_CSW		= 0xe1
.equ			PSOC4_WRITE_CSW		= 0xc5
.equ			PSOC4_READ_TAR		= 0xf5
.equ			PSOC4_WRITE_TAR		= 0xd1
.equ			PSOC4_READ_DRW		= 0xf9
.equ			PSOC4_WRITE_DRW		= 0xdd


;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
psoc4_init:		sts		devbuf,r19		;store par 4
			out		CTRLPORT,const_0
			sbi		CTRLDDR,PSOC4_RST
			sbi		CTRLDDR,PSOC4_CLOCK
			sbi		CTRLDDR,PSOC4_DATA
			sbi		CTRLDDR,PSOC4_TDATA
			sbi		CTRLDDR,PSOC4_TCMD
			call		api_vcc_on		;power on
			ldi		ZL,50
			ldi		ZH,0
			call		api_wait_ms
			sbi		CTRLPORT,psoc4_RST	;release reset
		;	rcall		psoc4_wait_1ms
		;	cbi		CTRLPORT,psoc4_RST	;set reset

psoc4_init_1:		sbi		CTRLPORT,PSOC4_CLOCK
			sbi		CTRLPORT,PSOC4_DATA
		;	clr		ZL
		;	rcall		psoc4_w0_1
		;	sbi		CTRLPORT,psoc4_RST	;release reset
		;	rcall		psoc4_wait_1ms

			ldi		r16,0x41		;timeout

			;now get jtag id
			ldi		r24,0
			ldi		r25,4			;1024 tries to get chip id
psoc4_init_2:		rcall		psoc4_reset		;reset state machine
			ldi		XL,PSOC4_READ_IDCODE
			rcall		psoc4_read_dap
			sts		0x100,XL
			cpi		XL,0x01			;status OK
			breq		psoc4_init_3
			rcall		psoc4_wait_100us
			sbiw		r24,1
			brne		psoc4_init_2
			rjmp		psoc4_init_err

psoc4_init_3:;		ldi		XL,PSOC4_READ_IDCODE
	;		rcall		psoc4_read_dap
			sts		0x100,r20
			sts		0x101,r21
			sts		0x102,r22
			sts		0x103,r23
			ldi		r16,0x42

;			jmp		main_loop_ok

			;configure debug port and enter test mode
			ldi		ZL,LOW(psoc4_data_cdp*2)
			ldi		ZH,HIGH(psoc4_data_cdp*2)
			clr		r16
			ldi		r24,5			;transfer 5 LW
psoc4_init_4:		rcall		psoc4_write_dap_z
			cpi		XL,0x01
			brne		psoc4_init_err
psoc4_init_4a:		dec		r24
			brne		psoc4_init_4
			;check test mode
			ldi		r16,0x43
			rcall		psoc4_read_io_fixed
			cpi		XL,0x01
			brne		psoc4_init_err
			andi		r23,0x80
			cpi		r23,0x80
			brne		psoc4_init_err
			;poll srom privileged bit
			ldi		r16,0x44
			ldi		r24,0

psoc4_init_5:		ldi		ZL,LOW(psoc4_data_spoll*2)
			ldi		ZH,HIGH(psoc4_data_spoll*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,4
			rcall		psoc4_read_io_fixed
			andi		r23,0x90
			cpi		r23,0x00
			breq		psoc4_init_pass
			rcall		psoc4_wait_5ms
			dec		r24
			brne		psoc4_init_5
psoc4_init_err:		jmp		main_loop

psoc4_init_pass:	jmp		main_loop_ok

psoc4_data_cdp:		.db PSOC4_WRITE_CTRL,	0x00,	0x54,0x00,0x00,0x00	;configure debug port
			.db PSOC4_WRITE_SELECT,	0x00,	0x00,0x00,0x00,0x00
			.db PSOC4_WRITE_CSW,	0x00,	0x00,0x00,0x00,0x02
			.db PSOC4_WRITE_TAR,	0x00,	0x40,0x03,0x00,0x14	;enter test mode
			.db PSOC4_WRITE_DRW,	0x00,	0x80,0x00,0x00,0x00

			.db 0x40,0x03,0x00,0x14		;check test mode
psoc4_data_spoll:	.db 0x40,0x00,0x00,0x04		;srom privileged bit
psoc4_data_spoll_2:	.db 0x40,0x10,0x00,0x04		;srom privileged bit V2


;-------------------------------------------------------------------------------
; check silicon ID
; if PAR4=1 then set to 48MHz
;-------------------------------------------------------------------------------
psoc4_check_sid:	lds		XL,devbuf
			sbrs		XL,1
			rjmp		psoc4_check_sid_nof
			
			ldi		r16,0x56
			ldi		ZL,LOW(psoc4_data_iom*2)
			ldi		ZH,HIGH(psoc4_data_iom*2)
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err

			ldi		r16,0x57
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_check_sid_err

psoc4_check_sid_nof:	ldi		r16,0x50
			ldi		ZL,LOW(psoc4_data_csid*2)
			ldi		ZH,HIGH(psoc4_data_csid*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,16
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err

			ldi		r16,0x51
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_check_sid_err

			ldi		r16,0x52
			ldi		ZL,LOW(psoc4_data_csid*2)
			ldi		ZH,HIGH(psoc4_data_csid*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,16
			rcall		psoc4_read_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err
			sts		0x100,r21		;SID[0]
			sts		0x101,r20		;SID[1]
			andi		r22,0xf0		;ignore minor die's revision
			sts		0x102,r22		;SID[2]
			adiw		ZL,4
			rcall		psoc4_read_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err
			sts		0x103,r20		;SID[3]
			swap		r21
			andi		r21,0x0f
			sts		0x104,r21		;protect state

psoc4_check_sid_pass:	jmp		main_loop_ok


psoc4_check_sid_err:	jmp		main_loop

psoc4_data_csid:	.db		0x40,0x00,0x00,0x08		;sysarg
			.db		0x00,0x00,0xd3,0xb6
			.db		0x40,0x00,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x00


psoc4_data_csid_2:	.db		0x40,0x10,0x00,0x08		;sysarg
			.db		0x00,0x00,0xd3,0xb6
			.db		0x40,0x10,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x00

psoc4_data_iom:		.db		0x40,0x10,0x00,0x08		;sysarg
			.db		0x00,0x00,0xe8,0xb6
			.db		0x40,0x10,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x15

;-------------------------------------------------------------------------------
; unprotect /protect
;-------------------------------------------------------------------------------
psoc4_protect:		ldi		r16,0x60
			ldi		ZL,LOW(psoc4_data_prot*2)
			ldi		ZH,HIGH(psoc4_data_prot*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,16
			rjmp		psoc4_unprot_1

psoc4_unprot:		ldi		r16,0x60
			ldi		ZL,LOW(psoc4_data_unprot*2)
			ldi		ZH,HIGH(psoc4_data_unprot*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,16

psoc4_unprot_1:		rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_err

			ldi		r16,0x61
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_check_sid_err

			jmp		main_loop_ok


psoc4_data_unprot:	.db		0x40,0x00,0x00,0x08		;sysarg
			.db		0x00,0x01,0xe0,0xb6
			.db		0x40,0x00,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x0D
psoc4_data_unprot_2:	.db		0x40,0x10,0x00,0x08		;sysarg
			.db		0x00,0x01,0xe0,0xb6
			.db		0x40,0x10,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x0D

psoc4_data_prot:	.db		0x40,0x00,0x00,0x08		;sysarg
			.db		0x00,0x02,0xe0,0xb6
			.db		0x40,0x00,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x0D
psoc4_data_prot_2:	.db		0x40,0x10,0x00,0x08		;sysarg
			.db		0x00,0x02,0xe0,0xb6
			.db		0x40,0x10,0x00,0x04		;sysreq
			.db		0x80,0x00,0x00,0x0D



;-------------------------------------------------------------------------------
; erase all flash
;-------------------------------------------------------------------------------
psoc4_erase:		ldi		r16,0x70
			ldi		ZL,LOW(psoc4_data_erase*2)
			ldi		ZH,HIGH(psoc4_data_erase*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,24
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_errx
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_errx
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_check_sid_errx

			ldi		r16,0x71
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_check_sid_errx

			jmp		main_loop_ok

psoc4_check_sid_errx:	rjmp		psoc4_check_sid_err

psoc4_data_erase:	.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE
			.db		0x00,0x00,0xdd,0xb6		;D=erase all
			.db		0x40,0x00,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=DSRAM_PARAMS_BASE
			.db		0x40,0x00,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x0A		;D=erase all

psoc4_data_erase_2:	.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE
			.db		0x00,0x00,0xdd,0xb6		;D=erase all
			.db		0x40,0x10,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=DSRAM_PARAMS_BASE
			.db		0x40,0x10,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x0A		;D=erase all



;-------------------------------------------------------------------------------
; program flash
; r18-r19 = address
;-------------------------------------------------------------------------------
psoc4_prog_err2:	rjmp		psoc4_prog_err

psoc4_prog:		ldi		YL,0				;buffer addr
			ldi		YH,1
			ldi		r25,16				;rows to program
			mov		r5,r25

psoc4_prog_1:		ldi		r16,0x90			;errcode
			ldi		ZL,LOW(psoc4_data_prog*2)
			ldi		ZH,HIGH(psoc4_data_prog*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,52
;			rjmp		pqq1
			rcall		psoc4_write_io_fixed		;(A)
			cpi		XL,0x01
			brne		psoc4_prog_err2
			rcall		psoc4_write_io_fixed		;(B)
			cpi		XL,0x01
			brne		psoc4_prog_err2

			ldi		r24,0x08			;buffer address
			ldi		r25,0x01
			ldi		XL,32				;LW/row
			mov		r6,XL				;longwords
			ldi		r16,0x91

			;write data to buffer
psoc4_prog_2:		movw		r20,r24
			ldi		r22,0
			ldi		r23,0x20
			ldi		XL,PSOC4_WRITE_TAR
			rcall		psoc4_write_dap
			cpi		XL,0x01
			brne		psoc4_prog_err
			ld		r20,Y+
			ld		r21,Y+
			ld		r22,Y+
			ld		r23,Y+
			ldi		XL,PSOC4_WRITE_DRW
			rcall		psoc4_write_dap
			cpi		XL,0x01
			brne		psoc4_prog_err
			adiw		r24,4
			dec		r6
			brne		psoc4_prog_2

			;load latch command
			ldi		r16,0x92
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_prog_err
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_prog_err

			ldi		r16,0x93
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_prog_err


			;program row
			ldi		r16,0x94
			ldi		XL,PSOC4_WRITE_TAR
			rcall		psoc4_write_dap_z1
			cpi		XL,0x01
			brne		psoc4_prog_err

			ldi		r16,0x95		;errcode
			ldi		r20,0xb6
			ldi		r21,0xd9
			movw		r22,r18
			ldi		XL,PSOC4_WRITE_DRW
			rcall		psoc4_write_dap
			cpi		XL,0x01
			brne		psoc4_prog_err

			;load latch command
			ldi		r16,0x96		;errcode
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_prog_err
			rcall		psoc4_write_io_fixed
			cpi		XL,0x01
			brne		psoc4_prog_err

			ldi		r16,0x97
			rcall		psoc4_poll_romstat
			cpi		r16,0x00
			brne		psoc4_prog_err

			add		r18,const_1
			adc		r19,const_0

pqq1:			dec		r5
			breq		psoc4_prog_pass
			rjmp		psoc4_prog_1

psoc4_prog_pass:	jmp		main_loop_ok

psoc4_prog_err:		sts		0x100,XL
			jmp		main_loop

psoc4_data_prog:	.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE
			.db		0x00,0x00,0xd7,0xb6		;D=load latch at addr=0
			.db		0x20,0x00,0x01,0x04		;A=SRAM_PARAMS_BASE + 4
			.db		0x00,0x00,0x00,0x7f		;D=row size - 1

			.db		0x40,0x00,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=SRAM_PARAMS_BASE
			.db		0x40,0x00,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x04		;D=load latch

			.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE

			.db		0x40,0x00,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=DSRAM_PARAMS_BASE
			.db		0x40,0x00,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x06		;D=program row


psoc4_data_prog_2:	.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE
			.db		0x00,0x00,0xd7,0xb6		;D=load latch at addr=0
			.db		0x20,0x00,0x01,0x04		;A=SRAM_PARAMS_BASE + 4
			.db		0x00,0x00,0x00,0x7f		;D=row size - 1

			.db		0x40,0x10,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=SRAM_PARAMS_BASE
			.db		0x40,0x10,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x04		;D=load latch

			.db		0x20,0x00,0x01,0x00		;A=SRAM_PARAMS_BASE

			.db		0x40,0x10,0x00,0x08		;A=sysarg
			.db		0x20,0x00,0x01,0x00		;D=DSRAM_PARAMS_BASE
			.db		0x40,0x10,0x00,0x04		;A=sysreq
			.db		0x80,0x00,0x00,0x06		;D=program row


;-------------------------------------------------------------------------------
; readout 2K
; param=addr
;-------------------------------------------------------------------------------
psoc4_readout:		ldi		r24,0
			ldi		YL,0
			ldi		YH,1
	
psoc4_readout_1:	rcall		psoc4_read_io_var
			cpi		XL,0x01
			brne		psoc4_readout_err
			rcall		psoc4_read_io_var
			cpi		XL,0x01
			brne		psoc4_readout_err
			dec		r24
			brne		psoc4_readout_1
			jmp		main_loop_ok

psoc4_readout_err:	ldi		r16,0x81
			jmp		main_loop

;-------------------------------------------------------------------------------
; reset and goto idle state
;-------------------------------------------------------------------------------
psoc4_reset:		sbi		CTRLPORT,PSOC4_DATA		;TMS HIGH
			sbi		CTRLDDR,PSOC4_DATA		;TMS OUTPUT
			ldi		XH,60
psoc4_reset_1:		cbi		CTRLPORT,PSOC4_CLOCK
			nop
			sbi		CTRLPORT,PSOC4_CLOCK
			dec		XH
			brne		psoc4_reset_1
			rcall		psoc4_w0			;wait
			cbi		CTRLPORT,PSOC4_DATA		;TMS LOW
			rcall		psoc4_w0			;wait
			ldi		XH,20
psoc4_reset_2:		cbi		CTRLPORT,PSOC4_CLOCK
			nop
			sbi		CTRLPORT,PSOC4_CLOCK
			dec		XH
			brne		psoc4_reset_2
			ret

;-------------------------------------------------------------------------------
; header
; XL=config in
; XL=ack out
;-------------------------------------------------------------------------------
psoc4_head:		ldi		XH,8
			sbi		CTRLPORT,PSOC4_TCMD		;trigger command
psoc4_head_1:		sbrc		XL,7
			sbi		CTRLPORT,PSOC4_DATA
			sbrs		XL,7
			cbi		CTRLPORT,PSOC4_DATA
			cbi		CTRLPORT,PSOC4_CLOCK
			lsl		XL
			dec		XH
			sbi		CTRLPORT,PSOC4_CLOCK
			brne		psoc4_head_1
			cbi		CTRLPORT,PSOC4_TCMD		;release trigger command

			cbi		CTRLPORT,PSOC4_CLOCK
			cbi		CTRLDDR,PSOC4_DATA
			sbi		CTRLPORT,PSOC4_CLOCK

			;get ack
			ldi		XH,3
psoc4_head_2:		cbi		CTRLPORT,PSOC4_CLOCK
			lsr		XL
			sbic		CTRLPIN,PSOC4_DATA
			ori		XL,0x80
			dec		XH
			sbi		CTRLPORT,PSOC4_CLOCK
			brne		psoc4_head_2
			lsr		XL
			swap		XL
			ret

;-------------------------------------------------------------------------------
; write
; XL=config in
; XL=ack out
; r20-r23 data in
;-------------------------------------------------------------------------------
psoc4_write_dap_z:	lpm		XL,Z+		;CMD
			adiw		ZL,1		;skip additional byte
psoc4_write_dap_z1:	rcall		psoc4_rom_lw	;get long word
psoc4_write_dap:	rcall		psoc4_head	;send header

			;TrN switch to output
			cbi		CTRLPORT,PSOC4_CLOCK
			sbi		CTRLDDR,PSOC4_DATA
			sbi		CTRLPORT,PSOC4_CLOCK

			cpi		XL,0x01
			brne		psoc4_wd_e

			sbi		CTRLPORT,PSOC4_TDATA		;trigger data

			clr		r4		;parity
			ldi		XH,32
psoc4_wd_1:		sbrc		r20,0
			sbi		CTRLPORT,PSOC4_DATA
			sbrs		r20,0
			cbi		CTRLPORT,PSOC4_DATA
			cbi		CTRLPORT,PSOC4_CLOCK
			lsr		r23
			ror		r22
			ror		r21
			ror		r20
			adc		r4,const_0
			sbi		CTRLPORT,PSOC4_CLOCK
			dec		XH
			brne		psoc4_wd_1
			;now send parity bit
			sbrc		r4,0
			sbi		CTRLPORT,PSOC4_DATA
			sbrs		r4,0
			cbi		CTRLPORT,PSOC4_DATA
			cbi		CTRLPORT,PSOC4_CLOCK
			nop
			sbi		CTRLPORT,PSOC4_CLOCK

			cbi		CTRLPORT,PSOC4_TDATA		;release trigger data

psoc4_wd_e:		ret

;-------------------------------------------------------------------------------
; read
; XL=config in
; XL=ack out
; r20-r23 data in
;-------------------------------------------------------------------------------
psoc4_read_drwx:	ldi		XL,PSOC4_READ_DRW

psoc4_read_dap:		rcall		psoc4_head			;send header

			sbi		CTRLPORT,PSOC4_TDATA		;trigger data

			ldi		XH,32
psoc4_rd_1:		cbi		CTRLPORT,PSOC4_CLOCK
			lsr		r23
			ror		r22
			ror		r21
			ror		r20
			sbic		CTRLPIN,PSOC4_DATA
			ori		r23,0x80
			sbi		CTRLPORT,PSOC4_CLOCK
			dec		XH
			brne		psoc4_rd_1

			;ignore parity
			cbi		CTRLPORT,PSOC4_CLOCK
			nop
			sbi		CTRLPORT,PSOC4_CLOCK

			cbi		CTRLPORT,PSOC4_TDATA		;release trigger data
psoc4_rd_e:
			;TrN switch to output
			cbi		CTRLPORT,PSOC4_CLOCK
			sbi		CTRLDDR,PSOC4_DATA
			sbi		CTRLPORT,PSOC4_CLOCK

			ret

;-------------------------------------------------------------------------------
; read from fix io address
;-------------------------------------------------------------------------------
psoc4_read_io_fixed:	ldi		XL,PSOC4_WRITE_TAR
			rcall		psoc4_write_dap_z1
			cpi		XL,0x01
			brne		psoc4_read_iofix_err
			rcall		psoc4_read_drwx
			cpi		XL,0x01
			brne		psoc4_read_iofix_err
			rcall		psoc4_read_drwx
psoc4_read_iofix_err:	ret


;-------------------------------------------------------------------------------
; read from var io address
;-------------------------------------------------------------------------------
psoc4_read_io_var:	ldi		XL,PSOC4_WRITE_TAR
			movw		r20,r16
			movw		r22,r18
			rcall		psoc4_write_dap
			cpi		XL,0x01
			brne		psoc4_read_iovar_err
			rcall		psoc4_read_drwx
			cpi		XL,0x01
			brne		psoc4_read_iovar_err
			rcall		psoc4_read_drwx
psoc4_read_iovar_err:	ldi		XH,4
			add		r16,XH
			adc		r17,const_0
			adc		r18,const_0
			adc		r19,const_0
			st		Y+,r20
			st		Y+,r21
			st		Y+,r22
			st		Y+,r23
			ret


;-------------------------------------------------------------------------------
; write to fix io address
;-------------------------------------------------------------------------------
psoc4_write_io_fixed:	ldi		XL,PSOC4_WRITE_TAR
			rcall		psoc4_write_dap_z1
			cpi		XL,0x01
			brne		psoc4_write_iofix_err
			ldi		XL,PSOC4_WRITE_DRW
			rcall		psoc4_write_dap_z1
psoc4_write_iofix_err:	ret


;-------------------------------------------------------------------------------
; poll srom status
;-------------------------------------------------------------------------------
psoc4_poll_romstat:	push		r24
			push		ZH
			push		ZL

			ldi		r24,0


psoc4_poll_romstat_1:	ldi		ZL,LOW(psoc4_data_sysreq*2)
			ldi		ZH,HIGH(psoc4_data_sysreq*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,4
			rcall		psoc4_read_io_fixed
			andi		r23,0x90
			breq		psoc4_poll_romstat_2
			rcall		psoc4_wait_5ms
			dec		r24
			brne		psoc4_poll_romstat_1
			rjmp		psoc4_poll_romstat_3

psoc4_poll_romstat_2:	ldi		ZL,LOW(psoc4_data_sysarg*2)
			ldi		ZH,HIGH(psoc4_data_sysarg*2)
			lds		r9,devbuf
			sbrc		r9,0
			adiw		ZL,4
			rcall		psoc4_read_io_fixed
			andi		r23,0xf0
			cpi		r23,0xa0
			brne		psoc4_poll_romstat_3
			clr		r16

psoc4_poll_romstat_3:	pop		ZL
			pop		ZH
			pop		r24
			ret


psoc4_data_sysreq:	.db		0x40,0x00,0x00,0x04
psoc4_data_sysreq_2:	.db		0x40,0x10,0x00,0x04
psoc4_data_sysarg:	.db		0x40,0x00,0x00,0x08
psoc4_data_sysarg_2:	.db		0x40,0x10,0x00,0x08

;-------------------------------------------------------------------------------
; get long word
;-------------------------------------------------------------------------------
psoc4_rom_lw:		lpm		r23,Z+		;address
			lpm		r22,Z+
			lpm		r21,Z+
			lpm		r20,Z+
			ret


;-------------------------------------------------------------------------------
; some wait routines
;-------------------------------------------------------------------------------
psoc4_wait_1ms:		ldi	ZL,1
			clr	ZH
			jmp	api_wait_ms

psoc4_w0:		ldi	ZL,33
psoc4_w0_1:		dec	ZL
			brne	psoc4_w0_1
psoc4_w0_2:		ret


psoc4_wait_5ms:		ldi		ZL,5
			ldi		ZH,0
			jmp		api_wait_ms


psoc4_wait_100us:	ldi	ZL,63
psoc4_wait_100us_loop:	dec	ZL
			brne	psoc4_wait_100us_loop	
			ret


;-------------------------------------------------------------------------------
; pdata
;-------------------------------------------------------------------------------

