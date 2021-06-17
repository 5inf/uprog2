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

.equ	MLX363_CS	= SIG1
.equ	MLX363_SCK	= SIG2
.equ	MLX363_MOSI	= SIG3	;to device
.equ	MLX363_MISO	= SIG4	;from device

.equ	MLX363_DIRSET	= SIG1_OR | SIG2_OR | SIG3_OR 

;------------------------------------------------------------------------------
; INIT CSI MODE
; PAR4 = number of pulses 
;------------------------------------------------------------------------------
mlx363_init:		out	CTRLPORT,const_0		;alles aus
			ldi	XL,MLX363_DIRSET			;set direction
			out	CTRLDDR,XL
			call	api_vcc_on			;VCC on
			ldi	ZL,2
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,MLX363_CS
			cbi	CTRLPORT,MLX363_SCK
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms

mlx363_init_1:		ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms

			rcall	mlx363_nop
			cpi	r25,0xd1			;nop response
			brne	mlx363_init_1		

			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
			
			rcall	mlx363_get1raw		
			jmp	main_loop_ok
			
			
			cpi	r25,0xec			;ready
			brne	mlx363_init_err1		
			ldi	ZL,2
			ldi	ZH,0
			call	wait_ms
			rcall	mlx363_get1raw		
			cpi	r24,0x55			;challenge
			brne	mlx363_init_err1				
			cpi	r25,0xd1			;nop response
			brne	mlx363_init_err1		
			jmp	main_loop_ok
			
mlx363_init_err1:	ldi	r16,0x41			;init error
			rcall	mlx363_store_result
			jmp	main_loop
					
mlx363_init_1c:		rcall	mlx363_get1raw		
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; EXIT
;------------------------------------------------------------------------------
mlx363_exit:		out	CTRLPORT,const_0	;alles aus
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read xyz
;------------------------------------------------------------------------------
mlx363_readxyz:		ldi	r16,0

mlx363_readxyz_1:	dec	r16
			breq	mlx363_readxyz_err1	

			rcall	mlx363_get1raw
			mov	XL,r25
			andi	r25,0xc0
			cpi	r25,0x80
			breq	mlx363_readxyz_ok
					
			cpi	r25,0xfe
			brne	mlx363_readxyz_err1
			
			ldi	ZL,0
mlx363_readxyz_2:	dec	ZL
			brne	mlx363_readxyz_2

			rjmp	mlx363_readxyz_1
			
mlx363_readxyz_err1:	ldi	r16,0x41			;readxyz error
			rcall	mlx363_store_result
			jmp	main_loop
					
mlx363_readxyz_ok:	rcall	mlx363_store_result
			jmp	main_loop_ok



;-------------------------------------------------------------------------------
; nop
;-------------------------------------------------------------------------------
mlx363_nop:		ldi	r19,0x00
			ldi	r20,0x00
			ldi	r21,0xAA			;challenge
			ldi	r22,0xAA
			ldi	r23,0x00
			ldi	r24,0x00
			ldi	r25,0xD0			;NOP cmd
			rjmp	mlx363_frame		


;-------------------------------------------------------------------------------
; read x,y,z
;-------------------------------------------------------------------------------
mlx363_get1raw:		ldi	r19,0x00
			ldi	r20,0x01			;RST
			ldi	r21,0xFF			;timeout
			ldi	r22,0xFF
			ldi	r23,0x00
			ldi	r24,0x00
			ldi	r25,0x93			;GET1 (XYZ) cmd
			rjmp	mlx363_frame		


mlx363_store_result:	sts	0x100,r19			;byte 0
			sts	0x101,r20			;byte 1
			sts	0x102,r21			;byte 2
			sts	0x103,r22			;byte 3
			sts	0x104,r23			;byte 4
			sts	0x105,r24			;byte 5
			sts	0x106,r25			;byte 6 (CMD)
			sts	0x107,r4			;byte 7 (CRC)
			ret


;-------------------------------------------------------------------------------
; FRAME
;-------------------------------------------------------------------------------
mlx363_frame:		cbi	CTRLPORT,MLX363_CS
			rcall	mlx363_frames_x
			mov	XL,r19
			rcall	mlx363_firstbyte
			mov	r19,XL
			mov	XL,r20
			rcall	mlx363_sendbyte
			mov	r20,XL
			mov	XL,r21
			rcall	mlx363_sendbyte
			mov	r21,XL
			mov	XL,r22
			rcall	mlx363_sendbyte
			mov	r22,XL
			mov	XL,r23
			rcall	mlx363_sendbyte
			mov	r23,XL
			mov	XL,r24
			rcall	mlx363_sendbyte
			mov	r24,XL
			mov	XL,r25
			rcall	mlx363_sendbyte
			mov	r25,XL
			call	mlx363_crcbyte
			mov	r4,XL
			rcall	mlx363_frames_x
			sbi	CTRLPORT,MLX363_CS
mlx363_frames_x:	ret

			
;-------------------------------------------------------------------------------
; COMMUNICATION SUBROUTINES
;-------------------------------------------------------------------------------
mlx363_crcbyte:		mov	XL,r4
			com	XL
			mov	r5,XL
			rjmp	mlx363_sendbyte
			
mlx363_firstbyte:	clr	r4
			dec	r4
			
mlx363_sendbyte:	push	ZL
			push	ZH
			ldi	ZH,HIGH(mlx363_crc_table*2)				;checksum
			mov	ZL,r4
			eor	ZL,XL
			lpm	r4,Z
			pop	ZH
			pop	ZL
	
mlx363_byte:		ldi	XH,0x08
mlx363_byte_1:		sbrc	XL,7				;1
			sbi	CTRLPORT,MLX363_MOSI		;2 data HIGH	
			sbrs	XL,7				;1
			cbi	CTRLPORT,MLX363_MOSI		;2 data LOW
			sbi	CTRLPORT,MLX363_SCK		;2 clock hi	
			lsl	XL				;1 result
			rcall	mlx363_byte_x
			cbi	CTRLPORT,MLX363_SCK		;2 clock hi	
			sbic	CTRLPIN,MLX363_MISO		;1 SO
			inc	XL				;1
			rcall	mlx363_byte_x			
			dec	XH				;1
			brne	mlx363_byte_1			;2/1

			ldi	XH,50
mlx363_byte_2:		dec	XH
			brne	mlx363_byte_2
mlx363_byte_x:		ret

