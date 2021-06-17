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

.equ		ESP32_RST	= SIG1
.equ		ESP32_BOOT	= SIG2
.equ		ESP32_RXD	= SIG3
.equ		ESP32_TXD	= SIG4


.equ		ESP32_ODIR	= ESP32_RST | ESP32_BOOT | ESP32_RXD

;-------------------------------------------------------------------------------
; init /exit
;-------------------------------------------------------------------------------
esp32_init:	out	CTRLPORT,const_0
		ldi	XL,ESP32_ODIR
		out	CTRLDDR,XL

		call	api_vcc_on		;power on
		ldi	ZL,50
		clr	ZH
		call	api_wait_ms
		
		sbi	CTRLPORT,ESP32_RST
		sbi	CTRLPORT,ESP32_TXD



esp32_exit:	out	CTRLPORT,const_0
		call	api_vcc_off
		out	CTRLDDR,const_0
		jmp	main_loop_ok

esp32_err:	sts	0x100,XL		;save wrong result
		jmp	main_loop



;-------------------------------------------------------------------------------
; init /exit
;-------------------------------------------------------------------------------
