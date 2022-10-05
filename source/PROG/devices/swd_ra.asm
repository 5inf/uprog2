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
			
;-------------------------------------------------------------------------------
; init
; R19 bit 4 = release reset
;-------------------------------------------------------------------------------
swd32ra_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,SWD32_RST
			sbi		CTRLDDR,SWD32_CLOCK
			sbi		CTRLDDR,SWD32_DATA
			sbi		CTRLPORT,SWD32_RST	;release reset

			;we do a connect under reset
			call		api_vcc_on		;power on
swd32ra_init_0:		ldi		ZL,200
			ldi		ZH,0
			call		api_wait_ms
;			sbi		CTRLPORT,SWD32_RST	;release reset

swd32ra_init_1:		cbi		CTRLPORT,SWD32_CLOCK
			cbi		CTRLPORT,SWD32_DATA
			clr		ZL
			call		swd32_w0_1

			ldi		r16,0x41		;timeout
			call		swd32_reginit		;set registers for faster output
			ldi		YL,0
			ldi		YH,1
		
			;now get chip id
swd32ra_init_2:		clr		r18
			call		swd32_reset		;reset state machine
			ldi		r18,0xde
			call		swd32_reset		;reset state machine

swd32ra_init_2a:	ldi		XL,SWD32_READ_IDCODE	;read ID code
			call		swd32_read_dap
			
			sts		0x100,XL
			cpi		XL,0x04			;no ack -> exit
			breq		swd32ra_init_3

swd32ra_init_3:		call		gen_w32			;return ID

			ldi		XL,SWD32_READ_CTRL	;read CTRLSTAT
			call		swd32_read_dap
			
			ldi		ZL,LOW(swd32ra_data_init1 * 2)
			ldi		ZH,HIGH(swd32ra_data_init1 * 2)

	
swd32ra_init_4:		call		swd32_write_dap_table
			call		swd32_wait_1ms		;delay
			ldi		XL,SWD32_READ_CTRL	;controlstat
			call		swd32_read_dap
			call		swd32_wait_1ms		;delay
			call		swd32_write_dap_table
			call		swd32_wait_1ms		;delay
			ldi		XL,SWD32_READ_CTRL	;controlstat
			call		swd32_read_dap
		
			call		gen_w32			;return ID

			jmp		main_loop_ok

swd32ra_init_err:	ldi		r16,0x41
			jmp		main_loop



swd32ra_data_init1:	;DebugPortStart
			.db SWD32_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db SWD32_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;init AP transfer mode

			
;-------------------------------------------------------------------------------
; init
; R19 bit 4 = release reset
;-------------------------------------------------------------------------------
swd32ra_era:		ldi		r24,0
			ldi		r25,10
		
swd32ra_era1:		ldi		XL,SWD32_READ_CTRL	;controlstat
			call		swd32_read_dap
			andi		r23,0xC0
			cpi		r23,0xc0
			breq		swd32ra_era2
			
			call		swd32_wait_1ms		;next try
			sbiw		r24,1
			brne		swd32ra_era1
			rjmp		swd32ra_init_err
			
			
			
swd32ra_era2:	;	jmp		main_loop_ok

			call		api_vcc_off		;power on
			ldi		ZL,0
			ldi		ZH,2
			call		api_wait_ms
			rjmp		swd32ra_init

		
swd32ra_reset:		cbi		CTRLPORT,SWD32_RST	;release reset
			call		swd32_wait_1ms		;next try
			sbi		CTRLPORT,SWD32_RST	;release reset
			call		swd32_wait_1ms		;next try
			jmp		main_loop_ok	
			
swd32ra_hpulse:		out		CTRLPORT,r14
			nop
			nop
			nop
			out		CTRLPIN,r15
			dec		XL
			brne		swd32ra_hpulse
			ret

swd32ra_lpulse:		out		CTRLPORT,r13
			nop
			nop
			nop
			out		CTRLPIN,r15
			dec		XL
			brne		swd32ra_lpulse
			ret


			ldi		XL,56
			rcall		swd32ra_hpulse
			ldi		XL,1
			rcall		swd32ra_lpulse

			ldi		r24,2			
swd32ra_init_1a:	ldi		XL,4
			rcall		swd32ra_hpulse
			ldi		XL,1
			rcall		swd32ra_lpulse
			dec		r24
			brne		swd32ra_init_1a

			ldi		XL,56
			rcall		swd32ra_hpulse
			ldi		XL,1
			rcall		swd32ra_lpulse

			ldi		r24,4			
swd32ra_init_1b:	ldi		XL,2
			rcall		swd32ra_hpulse
			ldi		XL,1
			rcall		swd32ra_lpulse
			dec		r24
			brne		swd32ra_init_1b

			ldi		XL,59
			rcall		swd32ra_hpulse

			ldi		XL,16
			rcall		swd32ra_lpulse



			cbi		CTRLDDR,SWD32_DATA
			ldi		XL,32
			rcall		swd32ra_hpulse
			