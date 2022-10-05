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
.equ			TLE986X_RST		= SIG1
.equ			TLE986X_CLOCK		= SIG2
.equ			TLE986X_DATA		= SIG3
.equ			TLE986X_TRG		= SIG5

.equ			TLE986X_ZERO_R		= 0				;none
.equ			TLE986X_ONE_R		= SIG3_OR			;data
.equ			TLE986X_ZERO		= SIG1_OR			;reset
.equ			TLE986X_ONE		= (SIG3_OR + SIG1_OR)		;data + reset
.equ			TLE986X_CLK		= SIG2_OR			;only clock


;SW-DP registers
.equ			TLE986X_READ_IDCODE	= 0xa5
.equ			TLE986X_WRITE_ABORT	= 0x81

.equ			TLE986X_READ_CTRL		= 0xb1
.equ			TLE986X_WRITE_CTRL	= 0x95

.equ			TLE986X_READ_STAT		= 0xb5
.equ			TLE986X_WRITE_SELECT	= 0x8d

.equ			TLE986X_READ_RDBUFF	= 0xbd		;read buffer


; AHB-AP registers
.equ			TLE986X_READ_CSW		= 0xe1
.equ			TLE986X_WRITE_CSW		= 0xc5

.equ			TLE986X_READ_TAR		= 0xF5
.equ			TLE986X_WRITE_TAR		= 0xD1

.equ			TLE986X_READ_BASE		= 0xED
.equ			TLE986X_WRITE_BASE	= 0xC9

.equ			TLE986X_READ_DRW		= 0xf9
.equ			TLE986X_WRITE_DRW		= 0xdd

			
;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
tle986x_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,TLE986X_RST
			sbi		CTRLDDR,TLE986X_CLOCK
			sbi		CTRLDDR,TLE986X_DATA
			sbi		CTRLDDR,TLE986X_TRG

			;we do a connect under reset
			call		api_vcc_on		;power on
;			sbi		CTRLPORT,TLE986X_RST	;release reset
			ldi		ZL,100
			ldi		ZH,0
			call		api_wait_ms

tle986x_init_1:		sbi		CTRLPORT,TLE986X_CLOCK
			sbi		CTRLPORT,TLE986X_DATA
			sbi		CTRLPORT,TLE986X_RST	;release reset
			ldi		ZL,25
			ldi		ZH,0
			call		api_wait_ms

			ldi		r16,0x41		;timeout

			call		swd32_reginit		;set registers for faster output
			ldi		YL,0
			ldi		YH,1

;			sbi		CTRLPORT,TLE986X_TRG	;trigger LA			

			;INIT DP
tle986x_idp:		call		swd32_reset		;reset state machine
			ldi		XL,TLE986X_READ_IDCODE	;read ID code
			call		swd32_read_dap			
			cpi		XL,0x04			;check ack
			breq		tle986x_init_2
			rjmp		tle986x_init_err

tle986x_init_2:		rcall		tle986x_store_val		;store JTAG port ID

			;set pointer to table
			ldi		ZL,LOW(tle986x_data_init1*2)
			ldi		ZH,HIGH(tle986x_data_init1*2)

;			sbi		CTRLPORT,TLE986X_TRG	;trigger LA			

			;init DP and read ID code
			rcall		tle986x_write_dap_table	;clear flags
			rcall		tle986x_write_dap_table	;set ctrlstat
			rcall		tle986x_write_dap_table	;clear flags
			rcall		tle986x_write_dap_table	;set ctrlstat
			call		swd32_read_ctrlstat
			cpi		r23,0xf0		;check for DP is powered
			brne		tle986x_init_err
							
			;init AHB AP
			sbi		CTRLPORT,TLE986X_TRG	;trigger LA			
			ldi		r16,0x50		;error code
			rcall		tle986x_write_dap_table	;write CSW
			rcall		tle986x_write_dap_table	;write TAR (CPUID)
			call		swd32_read_drwx			
 			rcall		tle986x_store_val	;store CPUID

			;halt target
			sbi		CTRLPORT,TLE986X_TRG	;trigger LA			
			ldi		r16,0x50		;error code
			rcall		tle986x_write_dap_table	;write CSW
			rcall		tle986x_write_dap_table	;write CSW
			rcall		tle986x_write_dap_table	;write CSW
			call		swd32_read_drwx
 			rcall		tle986x_store_val	;store CPUID
			

			jmp		main_loop_ok

			;test
			ldi		r24,5
tle986x_ptest1:		rcall		tle986x_write_dap_table	;write CSW
			dec		r24
			brne		tle986x_ptest1		


			jmp		main_loop_ok

tle986x_init_err:		sts		0x13F,XL
			jmp		main_loop


tle986x_data_init1:	;init DP
			.db TLE986X_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db TLE986X_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface
			.db TLE986X_WRITE_ABORT,	0x00,	0x00,0x00,0x00,0x1e	;clear all errors
			.db TLE986X_WRITE_CTRL,	0x00,	0x50,0x00,0x00,0x00	;power up debug interface

			;init AHB AP
			.db TLE986X_WRITE_CSW,	0x00,	0x23,0x00,0x00,0x02	;32 bit access
			.db TLE986X_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0x00	;CPUID

			;Halt target
			.db TLE986X_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR
			.db TLE986X_WRITE_DRW,	0x00,	0xA0,0x5F,0x00,0x03	;halt core and enable debug
			.db TLE986X_WRITE_TAR,	0x00,	0xE0,0x00,0xED,0xF0	;DHCSR

			;test
;			.db TLE986X_WRITE_TAR,	0x00,	0x40,0x00,0x80,0x64	;CMU_CLEKEN0
;			.db TLE986X_WRITE_DRW,	0x00,	0x04,0x00,0x00,0x00	;enable GPIO
			.db TLE986X_WRITE_TAR,	0x00,	0x48,0x02,0x80,0x04	;P0DIR
			.db TLE986X_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;enable P0.0
			.db TLE986X_WRITE_TAR,	0x00,	0x48,0x02,0x80,0x00	;DOUT
			.db TLE986X_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;P0.0=1
			.db TLE986X_WRITE_DRW,	0x00,	0x00,0x00,0x00,0x01	;P0.0=1
			
tle986x_write_dap_table:	jmp	swd32_write_dap_table
tle986x_store_val:		jmp	gen_w32
tle986x_read_dap:		jmp	swd32_read_dap

