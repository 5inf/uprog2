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

;------------------------------------------------------------------------------
; init / exit
;------------------------------------------------------------------------------
dataflash_init:		call	api_resetptr
			call	spi3_init	
			ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			jmp	main_loop_ok
			
dataflash_exit:		call	spi_exit
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; set param
;------------------------------------------------------------------------------
dataflash_param:	lds	r4,0x100	;page size low
			lds	r5,0x101	;page size high
		
			lds	r6,0x102	;used size low
			lds	r7,0x103	;used size high
		
			lds	r8,0x104	;page skip low
			lds	r9,0x105	;page skip high
			
			lds	r10,0x106	;raw mode
			lds	r11,0x107	;unused
				
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read memory (only 2^n bytes)
; PAR1	=	ADDRM
; PAR2	=	ADDRH
; PAR3	=	pagesize H
; PAR4	=	num pages
;------------------------------------------------------------------------------
dataflash_read:		call	api_resetptr
			
dataflash_read_loop:	call	spi_active
			
			ldi	XL,0xD2			;READ
			call	spi3_byte
			
			mov	XL,r17			;AH
			call	spi3_byte
			mov	XL,r16			;AM
			call	spi3_byte
			ldi	XL,0			;AL=0
			call	spi3_byte
				
			ldi	r24,4			;4 dummy bytes
dataflash_read_1:	call	spi3_zerobyte
			dec	r24
			brne	dataflash_read_1		

			mov	r25,r18			;used bytes
			andi	r25,0x7f		;mask
			ldi	r24,0

			;read data
dataflash_read_3:	call	spi3_zerobyte
			call	api_buf_bwrite
			sbiw	r24,1
			brne	dataflash_read_3
			call	spi_inactive
			
			;increment address
dataflash_read_8:	mov	XL,r18
			andi	XL,0x7f
			sbrc	r18,7
			lsl	XL
			add	r16,XL			;add page size
			adc	r17,const_0	
			
			dec	r19
			brne	dataflash_read_loop	
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read memory (full page)
; PAR1	=	ADDRM
; PAR2	=	ADDRH
; PAR3	=	pagesize H
; PAR4	=	pages
;------------------------------------------------------------------------------
dataflash_fread:	call	api_resetptr
			
dataflash_fread_loop:	call	spi_active
			
			ldi	XL,0xD2			;READ
			call	spi3_byte
			
			mov	XL,r17			;AH
			call	spi3_byte
			mov	XL,r16			;AM
			call	spi3_byte
			ldi	XL,0			;AL
			call	spi3_byte
				
			ldi	r24,4			;4 dummy bytes
dataflash_fread_1:	call	spi3_zerobyte
			dec	r24
			brne	dataflash_fread_1		

			mov	r25,r18			;used bytes
			mov	r24,r18
			lsl	r24
			lsl	r24
			lsl	r24
			mov	r23,r24

			;read data
dataflash_fread_3:	call	spi3_zerobyte
			call	api_buf_bwrite
			sbiw	r24,1
			brne	dataflash_fread_3
			call	spi_inactive

			;additional FF bytes		
			mov	r25,r18			;used bytes
			ldi	r24,0
			
			sub	r24,r23
			sbc	r25,const_0
					
dataflash_fread_4:	ldi	XL,0xff
			call	api_buf_bwrite
			sbiw	r24,1
			brne	dataflash_fread_4
			
			;increment address
dataflash_fread_8:	mov	XL,r18
			lsl	XL
			add	r16,XL			;add page size
			adc	r17,const_0	
			
			dec	r19
			brne	dataflash_fread_loop	
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRH
; PAR3	=	bytes/page *256 +128*short
; PAR4	=	pages
;------------------------------------------------------------------------------
dataflash_write:	call	api_resetptr

dataflash_write_loop:	call	spi_active
			ldi	XL,0x84			;write to buffer 1
			call	spi3_byte
			
			call	spi3_zerobyte		;address=0
			call	spi3_zerobyte
			call	spi3_zerobyte
			
			mov	r25,r18			;used bytes
			andi	r25,0x7f		;mask
			ldi	r24,0
			
dataflash_write_1:	call	api_buf_bread
			call	spi3_byte
			sbiw	r24,1
			brne	dataflash_write_1
			
			call	spi_inactive
								
			;now program page
dataflash_write_4:	call	spi_active
			ldi	XL,0x83			;program buffer 1
			call	spi3_byte
				
			mov	XL,r17		;AH
			call	spi3_byte
			mov	XL,r16		;AM
			call	spi3_byte
			ldi	XL,00		;AL
			call	spi3_byte

			call	spi_inactive

			ldi	ZL,100
			ldi	ZH,0
			rcall	dataflash_wready2

			mov	XL,r18			;page size
			andi	XL,0x7f
			sbrc	r18,7
			lsl	XL
			add	r16,XL			;add page size
			adc	r17,const_0	
			
			dec	r19
			brne	dataflash_write_loop	

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	pages
;------------------------------------------------------------------------------
dataflash_fwrite:	call	api_resetptr

dataflash_fwrite_loop:	call	spi_active
			ldi	XL,0x84			;write to buffer 1
			call	spi3_byte
			
			call	spi3_zerobyte		;address=0
			call	spi3_zerobyte
			call	spi3_zerobyte
			
			mov	r25,r18			;used bytes
			mov	r24,r18
			lsl	r24
			lsl	r24
			lsl	r24
			mov	r23,r24

dataflash_fwrite_1:	call	api_buf_bread
			call	spi3_byte
			sbiw	r24,1
			brne	dataflash_fwrite_1
		
			call	spi_inactive

			;additional FF bytes		
			mov	r25,r18			;used bytes
			ldi	r24,0
			
			sub	r24,r23
			sbc	r25,const_0

dataflash_fwrite_2:	adiw	YL,1
			sbiw	r24,1
			brne	dataflash_fwrite_2
			
			
			;now program page
dataflash_fwrite_4:	call	spi_active
			ldi	XL,0x83			;program buffer 1
			call	spi3_byte

			mov	XL,r17		;AH
			call	spi3_byte
			mov	XL,r16		;AM
			call	spi3_byte
			ldi	XL,00		;AL
			call	spi3_byte

			call	spi_inactive

			ldi	ZL,100
			ldi	ZH,100
			rcall	dataflash_wready2

			mov	XL,r18
			lsl	XL
			add	r16,XL			;add page size
			adc	r17,const_0	
			
			dec	r19
			brne	dataflash_fwrite_loop	

			jmp	main_loop_ok

			
;------------------------------------------------------------------------------
; block erase
; PAR3/4 timeout in 10ms steps
;------------------------------------------------------------------------------
dataflash_erase:	call	spi_active
			ldi	XL,0x50			;bulk erase cmd
			call	spi3_byte

			mov	XL,r17		;AH
			call	spi3_byte
			mov	XL,r16		;AM
			call	spi3_byte
			ldi	XL,00		;AL
			call	spi3_byte

dataflash_erase_1:	call	spi_inactive
			
			movw	ZL,r18
			rcall	dataflash_wready2	
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; set binary
; PAR3/4 time in 10ms steps
;------------------------------------------------------------------------------
dataflash_setbin:	call	spi_active
			ldi	XL,0x3d
			call	spi3_byte
			ldi	XL,0x2a
			call	spi3_byte
			ldi	XL,0x80	
			call	spi3_byte
			ldi	XL,0xa6
			call	spi3_byte
			
			rjmp	dataflash_erase_1

;------------------------------------------------------------------------------
; get status
; rval=status register
;------------------------------------------------------------------------------
dataflash_getstat:	call	spi_active
			ldi	XL,0x57			;get status register
			call	spi3_byte
			call	spi3_zerobyte
			call	spi_inactive
			mov	r16,XL			;copy to rval
			sts	0x100,r4
			sts	0x101,r5
			sts	0x102,r6
			sts	0x103,r7
			sts	0x104,r8
			sts	0x105,r9
			sts	0x106,r10
			sts	0x107,r11

			jmp	main_loop


;------------------------------------------------------------------------------
; subroutines
;------------------------------------------------------------------------------
			;wait for ready
dataflash_wready:	call	spi_active
			ldi	XL,0x57			;get status register
			call	spi3_byte
dataflash_wready_1:	call	spi3_zerobyte
			call	spi_inactive
			andi	XL,0x80
			breq	dataflash_wready
			ret
								
				
			;wait for ready with timeout
dataflash_wready2:	call	spi_active
			ldi	XL,0x57			;get status register
			call	spi3_byte
dataflash_wready2_1:	call	spi3_zerobyte
			call	spi_inactive
			andi	XL,0x80
			brne	dataflash_wready2_2
			push	ZL
			push	ZH
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
			pop	ZH
			pop	ZL
			sbiw	ZL,1
			brne	dataflash_wready2
			call	spi_inactive
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
dataflash_wready2_2:	ret
