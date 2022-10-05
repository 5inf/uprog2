;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2019 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.macro SPIFL_ACT
			cbi	CTRLPORT,SIG1	;CSN
.endm

.macro SPIFL_INH
			sbi	CTRLPORT,SIG1	;CSN
.endm

;------------------------------------------------------------------------------
; fast init
;------------------------------------------------------------------------------
spiflash_init:		call	api_resetptr
			call	spi0_init
			ldi	ZL,0
			ldi	ZH,1
			call	api_wait_ms	
			jmp	main_loop_ok
			
spiflash_exit:		call	spi_exit
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read memory
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	256bytes-blocks
;------------------------------------------------------------------------------
spiflash_read:		movw	YL,const_0
			SPIFL_ACT		;CSN
			
			ldi	XL,0x03		;READ
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			mov	XL,r16		;AL
			call	spi_byte
						
			ldi	r24,0
			mov	r25,r19		;size
			
spiflash_read_1:	call	spi_zerobyte
			st	Y+,XL
			sbiw	r24,1
			brne	spiflash_read_1
			
			SPIFL_INH
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read memory
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	ADDRX
;------------------------------------------------------------------------------
spiflash_read4:		movw	YL,const_0
			SPIFL_ACT		;CSN
			
			ldi	XL,0x13		;READ
			call	spi_byte
			
			mov	XL,r19		;AX
			call	spi_byte		
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			mov	XL,r16		;AL
			call	spi_byte
						
			ldi	r24,0
			ldi	r25,8		;size
			
spiflash_read4_1:	call	spi_zerobyte
			st	Y+,XL
			sbiw	r24,1
			brne	spiflash_read4_1
			
			SPIFL_INH
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; read 2K memory, streamed version
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	ADDRX
;------------------------------------------------------------------------------
spiflash_reads:		SPIFL_ACT		;CSN
			
			ldi	XL,0x03		;READ
			call	spi_byte						
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			mov	XL,r16		;AL
			call	spi_byte
						
			ldi	r24,0
			ldi	r25,8		;size
			
spiflash_reads_1:	call	spi_zerobyte
			call	host_put
			
			sbiw	r24,1
			brne	spiflash_reads_1
			
			SPIFL_INH
			jmp	main_loop_ok_noret


spiflash_read4s:	SPIFL_ACT		;CSN
			
			ldi	XL,0x13		;READ
			call	spi_byte
			
			mov	XL,r19		;AX
			call	spi_byte		
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			mov	XL,r16		;AL
			call	spi_byte
						
			ldi	r24,0
			ldi	r25,8		;size
			
spiflash_read4s_1:	call	spi_zerobyte
			call	host_put
			
			sbiw	r24,1
			brne	spiflash_read4s_1
			
			SPIFL_INH
			jmp	main_loop_ok_noret


;------------------------------------------------------------------------------
; read config bytes
;------------------------------------------------------------------------------
spiflash_read_conf:	rcall	spiflash_wready
			cpi	r19,0x00		;mode 0x00 (use status register 2)
			brne	spiflash_read_conf
	
			rcall	read_config
			sts	0x100,XL
			rcall	read_config2
			sts	0x101,XL
			rcall	read_config3
			sts	0x102,XL
			jmp	main_loop_ok		;quad bit is already set

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	256bytes-blocks
;------------------------------------------------------------------------------
spiflash_write:		movw	YL,const_0
spiflash_write_1:	rcall	spiflash_wren	;write enable
					
			SPIFL_ACT

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 bytes
			
spiflash_write_2:	ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spiflash_write_2

			SPIFL_INH
			
			rcall	spiflash_wready3	
			add	r17,const_1
			adc	r18,const_0
			dec	r19
			brne	spiflash_write_1
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	ADDRX
;------------------------------------------------------------------------------
spiflash_write4:	movw	YL,const_0
			ldi	r25,8		;pages
			
spiflash_write4_1:	rcall	spiflash_wren	;write enable
					
			SPIFL_ACT

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r19		;AX
			call	spi_byte
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 bytes
			
spiflash_write4_2:	ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spiflash_write4_2

			SPIFL_INH
			
			rcall	spiflash_wready3	
			add	r17,const_1
			adc	r18,const_0
			adc	r19,const_0
			dec	r25
			brne	spiflash_write4_1
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	512bytes-blocks
;------------------------------------------------------------------------------
spiflash_write2:	movw	YL,const_0
spiflash_write2_1:	rcall	spiflash_wren	;write enable
					
			SPIFL_ACT

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 words
			
spiflash_write2_2:	ld	XL,Y+
			call	spi_byte
			ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spiflash_write2_2

			SPIFL_INH
			
			rcall	spiflash_wready3	
			ldi	XL,2
			add	r17,XL
			adc	r18,const_0
			
			dec	r19
			brne	spiflash_write2_1
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	ADDRX
;------------------------------------------------------------------------------
spiflash_write24:	movw	YL,const_0
			ldi	r25,4		;pages

spiflash_write24_1:	rcall	spiflash_wren	;write enable
					
			SPIFL_ACT

			ldi	XL,0x12		;WRITE
			call	spi_byte
			
			mov	XL,r19		;AX
			call	spi_byte
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 words
			
spiflash_write24_2:	ld	XL,Y+
			call	spi_byte
			ld	XL,Y+
			call	spi_byte
			dec	r24
			brne	spiflash_write24_2

			SPIFL_INH
			
			rcall	spiflash_wready3	
			ldi	XL,2
			add	r17,XL
			adc	r18,const_0
			adc	r19,const_0
			
			dec	r25
			brne	spiflash_write24_1
			jmp	main_loop_ok

			
;------------------------------------------------------------------------------
; bulk erase
; PAR3/4 timeout in 10ms steps
;------------------------------------------------------------------------------
spiflash_erase_bulk:	rcall	spiflash_wren		;write enable
			rcall	spiflash_wready

			ldi	XL,0xc7
			rcall	spiflash_sbyte
				
spiflash_erase_bulk1:	movw	ZL,r18
			rcall	spiflash_wready2	
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; bulk erase and no wait for done
; PAR3/4 timeout in 10ms steps
;------------------------------------------------------------------------------
spiflash_erase_nw:	rcall	spiflash_wren		;write enable
			rcall	spiflash_wready

			ldi	XL,0xc7
			rcall	spiflash_sbyte

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; set bank
; PAR4 = bank
; PAR3 = 1=only write 
;------------------------------------------------------------------------------
spiflash_set_bank:	sbrc	r18,0
			rjmp	spiflash_set_bank1
			clr	r5
			SPIFL_ACT
			ldi	XL,0x17			;set bank
			call	spi_byte
			mov	XL,r19			;bank no
			andi	XL,0x7f			;24 bit adressing mode
			call	spi_byte
			SPIFL_INH
			jmp	main_loop_ok

spiflash_set_bank1:	mov	r4,r19
			mov	r5,const_1
			jmp	main_loop_ok			



;------------------------------------------------------------------------------
; get status
; PAR1 = num of data
; PAR2 = cmd
;------------------------------------------------------------------------------
spiflash_getstat:	call	api_resetptr
			call	spi_active
			mov	XL,r17			;CMD
			call	spi_byte
			
spiflash_getstat_1:	call	spi_zerobyte
			call	api_buf_bwrite
			dec	r16
			brne	spiflash_getstat_1
			
			call	spi_inactive
			
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; set status
; PAR1 = num of data
; PAR2 = cmd
; PAR3/4 timeout in 10ms steps
;------------------------------------------------------------------------------
spiflash_setstat:	rcall	spiflash_wren		;write enable
			call	spi_active
			mov	XL,r17			;copy cmd
			call	spi_byte
			
spiflash_setstat_1:	call	api_buf_bread
			call	spi_byte
			dec	r16
			brne	spiflash_setstat_1
			call	spi_inactive
			
			movw	ZL,r18
			rcall	spiflash_wready2	
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; enable and disable writing
;------------------------------------------------------------------------------
spiflash_wren:		ldi	XL,0x06			;WREN cmd
			rjmp	spiflash_sbyte
				
spiflash_wrdis:		ldi	XL,0x04			;WRDIS cmd
			rjmp	spiflash_sbyte

spiflash_nwren:		ldi	XL,0x50			;WREN cmd
			rjmp	spiflash_sbyte

;------------------------------------------------------------------------------
; enable quad mode
;------------------------------------------------------------------------------
read_config:		ldi	XL,0x05
read_confign:		SPIFL_ACT
			call	spi_byte
			ldi	XL,0x00			;status reg 1
			call	spi_byte
			SPIFL_INH
			ret

read_config2:		ldi	XL,0x35
			rjmp	read_confign

read_config3:		ldi	XL,0x15
			rjmp	read_confign


;------------------------------------------------------------------------------
; wait for ready
;------------------------------------------------------------------------------
spiflash_wready:	SPIFL_ACT
			ldi	XL,0x05			;get status
			call	spi_byte
spiflash_wready_1:	call	spi_zerobyte
			andi	XL,0x01
			brne	spiflash_wready_1
			SPIFL_INH
			ret
										
			;wait for ready with timeout
spiflash_wready2:	SPIFL_ACT
			ldi	XL,0x05			;get status
			call	spi_byte
spiflash_wready2_1:	call	spi_zerobyte
			andi	XL,0x01
			breq	spiflash_wready2_2
			push	ZL
			push	ZH
			ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			pop	ZH
			pop	ZL
			sbiw	ZL,1
			brne	spiflash_wready2_1
			SPIFL_INH
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
spiflash_wready2_2:	SPIFL_INH
			ret

			;wait for ready with fast timeout
spiflash_wready3:	ldi	ZL,0
			ldi	ZH,0
			SPIFL_ACT
			ldi	XL,0x05			;get status
			call	spi_byte
spiflash_wready3_1:	call	spi_zerobyte
			andi	XL,0x01
			breq	spiflash_wready3_2
			sbiw	ZL,1
			brne	spiflash_wready3_1
			SPIFL_INH
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
spiflash_wready3_2:	jmp	spi_inactive
			

spiflash_sbyte:		SPIFL_ACT
			call	spi_byte
			SPIFL_INH
			ret

spiflash_getstatus:	ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			SPIFL_ACT
			ldi	XL,0x05			;get status
			call	spi_byte
			call	spi_zerobyte
			andi	XL,0x01
			ldi	r16,0x60
			or	r16,XL
			SPIFL_INH
			jmp	main_loop
			
