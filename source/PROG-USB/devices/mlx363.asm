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

			.org (PC+127) & 0xFF80

mlx363_crc_table:	.db 0x00,0x2f,0x5e,0x71,0xbc,0x93,0xe2,0xcd
			.db 0x57,0x78,0x09,0x26,0xeb,0xc4,0xb5,0x9a
			.db 0xae,0x81,0xf0,0xdf,0x12,0x3d,0x4c,0x63
			.db 0xf9,0xd6,0xa7,0x88,0x45,0x6a,0x1b,0x34	
			.db 0x73,0x5c,0x2d,0x02,0xcf,0xe0,0x91,0xbe
			.db 0x24,0x0b,0x7a,0x55,0x98,0xb7,0xc6,0xe9
			.db 0xdd,0xf2,0x83,0xac,0x61,0x4e,0x3f,0x10
			.db 0x8a,0xa5,0xd4,0xfb,0x36,0x19,0x68,0x47
			.db 0xe6,0xc9,0xb8,0x97,0x5a,0x75,0x04,0x2b
			.db 0xb1,0x9e,0xef,0xc0,0x0d,0x22,0x53,0x7c
			.db 0x48,0x67,0x16,0x39,0xf4,0xdb,0xaa,0x85
			.db 0x1f,0x30,0x41,0x6e,0xa3,0x8c,0xfd,0xd2
			.db 0x95,0xba,0xcb,0xe4,0x29,0x06,0x77,0x58
			.db 0xc2,0xed,0x9c,0xb3,0x7e,0x51,0x20,0x0f
			.db 0x3b,0x14,0x65,0x4a,0x87,0xa8,0xd9,0xf6
			.db 0x6c,0x43,0x32,0x1d,0xd0,0xff,0x8e,0xa1
			.db 0xe3,0xcc,0xbd,0x92,0x5f,0x70,0x01,0x2e
			.db 0xb4,0x9b,0xea,0xc5,0x08,0x27,0x56,0x79
			.db 0x4d,0x62,0x13,0x3c,0xf1,0xde,0xaf,0x80
			.db 0x1a,0x35,0x44,0x6b,0xa6,0x89,0xf8,0xd7
			.db 0x90,0xbf,0xce,0xe1,0x2c,0x03,0x72,0x5d
			.db 0xc7,0xe8,0x99,0xb6,0x7b,0x54,0x25,0x0a
			.db 0x3e,0x11,0x60,0x4f,0x82,0xad,0xdc,0xf3
			.db 0x69,0x46,0x37,0x18,0xd5,0xfa,0x8b,0xa4
			.db 0x05,0x2a,0x5b,0x74,0xb9,0x96,0xe7,0xc8
			.db 0x52,0x7d,0x0c,0x23,0xee,0xc1,0xb0,0x9f
			.db 0xab,0x84,0xf5,0xda,0x17,0x38,0x49,0x66
			.db 0xfc,0xd3,0xa2,0x8d,0x40,0x6f,0x1e,0x31
			.db 0x76,0x59,0x28,0x07,0xca,0xe5,0x94,0xbb
			.db 0x21,0x0e,0x7f,0x50,0x9d,0xb2,0xc3,0xec
			.db 0xd8,0xf7,0x86,0xa9,0x64,0x4b,0x3a,0x15
			.db 0x8f,0xa0,0xd1,0xfe,0x33,0x1c,0x6d,0x42
	
