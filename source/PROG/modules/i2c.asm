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
; init I2C
; par1 0=100K 1=400K
; par2 page size
; par3 address bytes
; par4 page write time
;------------------------------------------------------------------------------
i2c_init:		mov	r4,r17			;copy pagesize
			mov	r5,r18
			mov	r6,r19
			mov	r7,r16
			
			call	api_vcc_on

			ldi	XL,17
			sbrs	r7,0			;skip if fast
			ldi	XL,92
			sts	TWBR,XL

			ldi	XL,0x00			;/1
			sts	TWSR,XL

			ldi	XL,(1<<TWEN) | (1<<TWINT)	;enable twi
			sts	TWCR,XL

			jmp	main_loop_ok


;------------------------------------------------------------------------------
; exit I2C
;------------------------------------------------------------------------------
i2c_exit:		sts	TWCR,const_0
			call	api_vcc_off
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; write address
; r24 LOW addr
; r25 HIGH addr
;-------------------------------------------------------------------------------
i2c_wad:		rcall	i2c_start		;start condition
			cpi	r23,0x08		;check for result
			brne	i2c_wad_e		;error

			mov	XL,r18			;devsel
			andi	XL,0xfe			;write
			rcall	i2c_wbyte
			cpi	r23,0x18		;check for result
			brne	i2c_wad_e		;error
		
			mov	XL,r5			;addr bytes
			cpi	XL,1			;1?
			breq	i2c_wad_2

			mov	XL,r25			;addr high
			rcall	i2c_wbyte
			cpi	r23,0x28		;check for result
			brne	i2c_wad_e		;error


i2c_wad_2:		mov	XL,r24			;addr low
			rcall	i2c_wbyte
			cpi	r23,0x28		;check for result
			brne	i2c_wad_e		;error
			ret	

i2c_wad_e:		pop	r0			;kill stack
			pop	r0
			ldi	r16,0x40		;set error
			rcall	i2c_stop
			jmp	main_loop		;stop condition and end

i2c_err:		ldi	r16,0x42		;set error
			rcall	i2c_stop
			jmp	main_loop		;stop condition and end


;-------------------------------------------------------------------------------
; read data bytes from external eeprom
;
;par1:	LOW addr
;par2:	HIGH addr
;par3:	device addr
;par4:	pages
;-------------------------------------------------------------------------------
i2c_read:		movw	r24,r16
			call	api_resetptr

			rcall	i2c_wad			;write address
	
			rcall	i2c_start		;repeated start condition
			cpi	r23,0x10
			brne	i2c_err			;error

			mov	XL,r18			;devsel
			ori	XL,0x01			;read
			rcall	i2c_wbyte
			cpi	r23,0x40
			brne	i2c_err			;error
	
			mul	r4,r19			;pages*pagesize

			movw	r24,r0			;bytes to do
		
i2c_read_4:		cpi	r25,0
			brne	i2c_read_5
			cpi	r24,1
			brne	i2c_read_5
			rcall	i2c_rbyten		;read byte with NACK
			call	api_buf_bwrite		;write byte to buffer
			cpi	r23,0x58		;error?
			brne	i2c_err
			rcall	i2c_stop
			jmp	main_loop_ok		;stop condition and end

i2c_read_5:		rcall	i2c_rbyte		;read byte with ACK
			cpi	r23,0x50		;error?
			brne	i2c_err
			call	api_buf_bwrite		;write byte to buffer
			sbiw	r24,1
			rjmp	i2c_read_4
			rcall	i2c_stop
			jmp	main_loop_ok		;stop condition and end


;-------------------------------------------------------------------------------
; write data  to external eeprom
;
;par1:	LOW addr
;par2:	HIGH addr
;par3:	device addr
;par4:	pages
;-------------------------------------------------------------------------------
i2c_write:		movw	r24,r16			;copy addr
			call	api_resetptr

i2c_write_1:		rcall	i2c_wad			;write address
			mov	r22,r4			;pagesize

i2c_write_2:		call	api_buf_bread
			rcall	i2c_wbyte		;write byte
			cpi	r23,0x28		;error?
			brne	i2c_err
			dec	r22
			brne	i2c_write_2
			rcall	i2c_stop
			mov	ZL,r6			;page write time
			ldi	ZH,0
			call	api_wait_ms

			add	r24,r4			;addr += pagesize
			adc	r25,const_0

			dec	r19			;pages
			brne	i2c_write_1
			jmp	main_loop_ok		;stop condition and end

i2c_write_e:		ldi	r16,0x41
			jmp	main_loop

;-------------------------------------------------------------------------------
; read temperature from fb
;-------------------------------------------------------------------------------
i2c_read_lm75:		rcall	i2c_start		;start condition
			cpi	r23,0x08
			brne	i2c_readfbe		;error
			ldi	XL,0x45			;read
			rcall	i2c_wbyte		;write byte
			sts	0x101,r23
			cpi	r23,0x40
			brne	i2c_readfbe		;error
			rcall	i2c_rbyten
			sts	0x102,r23
			cpi	r23,0x58		;error?
			brne	i2c_readfbe
			sts	0x100,XL
			clr	r16
			rcall	i2c_stop
			jmp	main_loop_ok

i2c_readfbe:		ldi	r16,0x41
			rcall	i2c_stop
			jmp	main_loop

;-------------------------------------------------------------------------------
; read data from lps25h
;-------------------------------------------------------------------------------
lps25h_start:		rcall	i2c_start		;start condition
			mov	XL,r18
			rcall	i2c_wbyte		;write byte
			ldi	XL,0xA0			;addr
			rcall	i2c_wbyte		;write byte
			ldi	XL,0x80			;power on
			rcall	i2c_wbyte		;write byte
			ldi	XL,0x01			;start
			rcall	i2c_wbyte		;write byte
			rcall	i2c_stop

			ldi	ZL,50
			ldi	ZH,0
			call	api_wait_ms

			jmp	main_loop_ok
		


;-------------------------------------------------------------------------------
; generate stop condition
;-------------------------------------------------------------------------------
i2c_stop:		ldi	r20,(1<<TWSTO) | (1<<TWINT) | (1<<TWEN)
			sts	TWCR,r20			;set control
			ret

;-------------------------------------------------------------------------------
; generate start condition
;-------------------------------------------------------------------------------
i2c_start:		ldi	r20,(1<<TWSTA) | (1<<TWINT) | (1<<TWEN)
			sts	TWCR,r20			;set control
i2c_start_1:		lds	r20,TWCR			;get control
			sbrs	r20,TWINT			;skip if ready
			rjmp	i2c_start_1			;loop
			lds	r23,TWSR			;get status
			andi	r23,0xf8			;mask bits
			ldi	r20,(1<<TWEN)			;clear start cond
			sts	TWCR,r20			;set control
			ret					;thats all

;-------------------------------------------------------------------------------
; set control to tempreg1 and wait for TWI is ready
;-------------------------------------------------------------------------------
i2c_wready:		sts	TWCR,r20			;set control
i2c_wready1:		lds	r20,TWCR			;get control
			sbrs	r20,TWINT			;skip if ready
			rjmp	i2c_wready1			;loop
			lds	r23,TWSR			;get status
			andi	r23,0xf8			;mask bits
			ret					;thats all

;-------------------------------------------------------------------------------
; write byte (XL) to I2C
;-------------------------------------------------------------------------------
i2c_wbyte:		sts	TWDR,XL
			ldi	r20,(1<<TWINT) | (1<<TWEN)
			rjmp	i2c_wready

;-------------------------------------------------------------------------------
; read byte (XL) from I2C (ACK)
;-------------------------------------------------------------------------------
i2c_rbyte:		ldi	r20,(1<<TWINT) | (1<<TWEN) | (1<<TWEA)
			rcall	i2c_wready
			lds	XL,TWDR				;get data
			ret

;-------------------------------------------------------------------------------
; read byte (XL) from I2C (NACK)
;-------------------------------------------------------------------------------
i2c_rbyten:		ldi	r20,(1<<TWINT) | (1<<TWEN)
			rcall	i2c_wready
			lds	XL,TWDR				;get data
			ret
