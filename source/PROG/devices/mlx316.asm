;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2017 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.equ	MLX316_CS	= SIG1
.equ	MLX316_MOSI	= SIG2
.equ	MLX316_SCK	= SIG3

.equ	MLX316_DIRSET	= SIG1_OR | SIG3_OR

;------------------------------------------------------------------------------
; INIT CSI MODE
; PAR4 = number of pulses 
;------------------------------------------------------------------------------
mlx316_readout:		call	api_resetptr
			out	CTRLPORT,const_0		;alles aus
			ldi	XL,MLX316_DIRSET		;set direction
			out	CTRLDDR,XL
			call	api_vcc_on			;VCC on
			ldi	ZL,2
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,MLX316_CS
			cbi	CTRLPORT,MLX316_SCK
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms

			cbi	CTRLPORT,MLX316_CS

			ldi	XL,0xaa
			rcall	mlx316_byte

			ldi	XL,0xff
			rcall	mlx316_byte

			ldi	r24,4
mlx316_readout_1:	ldi	XL,0xff
			rcall	mlx316_byte
			call	api_buf_bwrite
			dec	r24
			brne	mlx316_readout_1
						
			ldi	r24,4;
mlx316_readout_2:	ldi	XL,0xff
			rcall	mlx316_byte
			dec	r24
			brne	mlx316_readout_2

			sbi	CTRLPORT,MLX316_CS

; EXIT
mlx316_exit:		out	CTRLPORT,const_0	;alles aus
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

			
;-------------------------------------------------------------------------------
; COMMUNICATION SUBROUTINES
;-------------------------------------------------------------------------------	
mlx316_byte:		ldi	XH,0x08
			cbi	CTRLPORT,MLX316_MOSI		;2 data LOW	
mlx316_byte_1:		sbrc	XL,7				;1
			cbi	CTRLDDR,MLX316_MOSI		;2 data HIGH/TS	
			sbrs	XL,7				;1
			sbi	CTRLDDR,MLX316_MOSI		;2 data LOW
			sbi	CTRLPORT,MLX316_SCK		;2 clock hi	
			lsl	XL				;1 result
			rcall	mlx316_byte_x
			cbi	CTRLPORT,MLX316_SCK		;2 clock hi	
			sbic	CTRLPIN,MLX316_MOSI		;1 SO
			inc	XL				;1
			rcall	mlx316_byte_x			
			dec	XH				;1
			brne	mlx316_byte_1			;2/1
			cbi	CTRLDDR,MLX316_MOSI		;2 data HIGH/TS	
			
			ldi	XH,50
mlx316_byte_2:		dec	XH
			brne	mlx316_byte_2
mlx316_byte_x:		ret

