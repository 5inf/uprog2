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
.equ		JTAG_TMS	= SIG1
.equ		JTAG_TCK	= SIG2
.equ		JTAG_TDI	= SIG3
.equ		JTAG_TDO	= SIG4
.equ		JTAG_TRST	= SIG5

.equ		jtag_buffer	= 0x0a00

;------------------------------------------------------------------------------
; init JTAG interface and goto run-test-idle
;------------------------------------------------------------------------------
jtag_init:		out	CTRLPORT,const_0
			ldi	XL,0x07			;all output except TDO
			out	CTRLDDR,XL
			call	api_vcc_on
			ldi	ZL,200
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,JTAG_TMS
			clr	r21
			ldi	r20,100
			rcall	jtag_ntck		;->reset
			cbi	CTRLPORT,JTAG_TMS
			ldi	r20,10
			rcall	jtag_ntck		;->run-test-idle
			ret
		

jtag_exit:		out	CTRLPORT,const_0
			out	CTRLDDR,const_0
			call	api_vcc_off
			ret


;------------------------------------------------------------------------------
; do one tck clock
; do r20-r21 tck clocks
; do r20-r23 tck clocks
;------------------------------------------------------------------------------
jtag_ntck:		sbi	CTRLPORT,JTAG_TCK	;2
			sub	r20,const_1		;1
			sbc	r21,const_0		;1
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			cbi	CTRLPORT,JTAG_TCK	;2
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
			brne	jtag_ntck		;2
			ret

