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

.macro SPIEEP_ACT
			cbi	CTRLPORT,SIG1	;CSN
.endm

.macro SPIEEP_INH
			sbi	CTRLPORT,SIG1	;CSN
.endm



;------------------------------------------------------------------------------
; fast init
;------------------------------------------------------------------------------
spieeprom_init:		call	api_resetptr
			call	spi0_init
			ldi	ZL,0
			ldi	ZH,1
			call	api_wait_ms	
			jmp	main_loop_ok
			
spieeprom_exit:		call	spi_exit
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read memory
; PAR1	=	ADDRL
; PAR2	=	ADDRH
; PAR3	=	BYTESL
; PAR4	=	BYTESH
;------------------------------------------------------------------------------
spieeprom_read:		movw	YL,const_0
			SPIEEP_ACT		;CSN
			
			ldi	XL,0x03		;READ
			sbrc	r17,0		;AH
			ori	XL,0x08
			call	spi_byte
			
			mov	XL,r16		;AL
			call	spi_byte
						
			movw	r24,r18
			
spieeprom_read_1:	call	spi_zerobyte
			st	Y+,XL
			sbiw	r24,1
			brne	spieeprom_read_1
			
			SPIEEP_INH
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read memory
; PAR1	=	ADDRL
; PAR2	=	ADDRH
; PAR3	=	BYTESL
; PAR4	=	BYTESH
;------------------------------------------------------------------------------
spieeprom_read1:	movw	YL,const_0
			SPIEEP_ACT		;CSN
			
			ldi	XL,0x03		;READ
			call	spi_byte
			
			mov	XL,r17		;AH
			call	spi_byte

			mov	XL,r16		;AL
			call	spi_byte

						
			movw	r24,r18
			
spieeprom_read1_1:	call	spi_zerobyte
			st	Y+,XL
			sbiw	r24,1
			brne	spieeprom_read1_1
			
			SPIEEP_INH
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	pages
; PAR4	=	pagesize
;------------------------------------------------------------------------------
spieeprom_write:	movw	YL,const_0
spieeprom_write_1:	rcall	spieeprom_wren	;write enable
			rcall	spieeprom_wready3	
					
			SPIEEP_ACT

			ldi	XL,0x02		;WRITE
			sbrc	r17,0		;AH
			ori	XL,0x08
			call	spi_byte
			
			mov	XL,r16		;AL
			call	spi_byte

			mov	r24,r19		;bytes per page
			
spieeprom_write_2:	ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spieeprom_write_2

			SPIEEP_INH
			
			rcall	spieeprom_wready3	
			add	r16,r19
			adc	r17,const_0
			dec	r18
			brne	spieeprom_write_1
			
			jmp	main_loop_ok
			


;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	pages
; PAR4	=	pagesize
;------------------------------------------------------------------------------
spieeprom_write1:	movw	YL,const_0
spieeprom_write1_1:	rcall	spieeprom_wren	;write enable
			rcall	spieeprom_wready3	
					
			SPIEEP_ACT

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r17		;AH
			call	spi_byte

			mov	XL,r16		;AL
			call	spi_byte

			mov	r24,r19		;bytes per page
			
spieeprom_write1_2:	ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spieeprom_write1_2

			SPIEEP_INH
			
			rcall	spieeprom_wready3	
			add	r16,r19
			adc	r17,const_0
			dec	r18
			brne	spieeprom_write1_1
			
			jmp	main_loop_ok
			

;------------------------------------------------------------------------------
; get status
; PAR1 = num of data
; PAR2 = cmd
;------------------------------------------------------------------------------
spieeprom_getstat:	call	api_resetptr
			sts	0x100,const_0
			rcall	spieeprom_wready3	
			call	spi_active
			ldi	XL,0x05			;CMD
			call	spi_byte
			call	spi_zerobyte
			call	api_buf_bwrite
			
			call	spi_inactive
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; set status
; PAR1 = num of data
; PAR2 = cmd
; PAR3/4 timeout in 10ms steps
;------------------------------------------------------------------------------
spieeprom_setstat:	rcall	spieeprom_wren		;write enable
			rcall	spieeprom_wready3	

			call	spi_active
			ldi	XL,0x01			;WRSR cmd
			call	spi_byte

			call	spi_active
			mov	XL,r19			;WRSR cmd
			call	spi_byte

			call	spi_inactive
			
			rcall	spieeprom_wready3	
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; subroutines
;------------------------------------------------------------------------------
spieeprom_wren:		ldi	XL,0x06			;WREN cmd
			rjmp	spieeprom_sbyte

				
spieeprom_wrdis:	ldi	XL,0x04			;WRDIS cmd
			rjmp	spieeprom_sbyte


			;wait for ready with fast timeout
spieeprom_wready3:	ldi	ZL,10
			ldi	ZH,0
			SPIEEP_ACT
			ldi	XL,0x05			;get status
			call	spi_byte
spieeprom_wready3_1:	call	spi_zerobyte
			andi	XL,0x01
			breq	spieeprom_wready3_2
			push	ZL
			push	ZH
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
			pop	ZH
			pop	ZL
			sbiw	ZL,1
			brne	spieeprom_wready3_1
			SPIEEP_INH
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
spieeprom_wready3_2:	jmp	spi_inactive
			

spieeprom_sbyte:	SPIEEP_ACT
			call	spi_byte
			SPIEEP_INH
			ret
