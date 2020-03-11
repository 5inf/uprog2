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
spiflash_read:		call	api_resetptr
			call	spi_active
			
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
			call	api_buf_bwrite
			sbiw	r24,1
			brne	spiflash_read_1
			
			call	spi_inactive
			jmp	main_loop_ok


spiflash_setquad:	rcall	spiflash_wready
			rcall	spiflash_qactive
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read memory
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	256bytes-blocks
;------------------------------------------------------------------------------
spiflash_read4:		call	api_resetptr
			rcall	spiflash_qactive
		
			ldi	r24,0x40	;cycles
			mul	r24,r19
			movw	r24,r0

			call	spi_active
			
			ldi	XL,0x6b		;READ QUAD
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			mov	XL,r16		;AL
			call	spi_byte
		
			ldi	XL,0		;dummy
			call	spi_byte
		
			ldi	XL,0x03		;all IO input
			out	CTRLDDR,XL
						
			ldi	r24,0x40
			mov	r25,r19		;size
			
			ldi	r22,SPI_SCK_PULSE
			
spiflash_read4_1:	out	CTRLPIN,r22	;pulse
			in	r23,CTRLPIN
			out	CTRLPIN,r22	;pulse
			lsl	r23
			lsl	r23
			out	CTRLPIN,r22	;pulse
			andi	r23,0xf0
			nop
			in	XL,CTRLPIN	
			out	CTRLPIN,r22	;pulse
			lsr	XL
			lsr	XL
			andi	XL,0x0f
			or	XL,r23
			call	api_buf_bwrite
			sbiw	r24,1
			brne	spiflash_read4_1
			
			call	spi0_reinit
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	256bytes-blocks
;------------------------------------------------------------------------------
spiflash_write:		call	api_resetptr
spiflash_write_1:	rcall	spiflash_wren	;write enable
					
			call	spi_active

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 bytes
			
spiflash_write_2:	call	api_buf_bread
			call	spi_byte
			dec	r24
			brne	spiflash_write_2

			call	spi_inactive
			
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
; PAR4	=	512bytes-blocks
;------------------------------------------------------------------------------
spiflash_write2:	call	api_resetptr
spiflash_write2_1:	rcall	spiflash_wren	;write enable
					
			call	spi_active

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	r24,0		;256 words
			
spiflash_write2_2:	call	api_buf_bread
			call	spi_byte
			call	api_buf_bread
			call	spi_byte
			dec	r24
			brne	spiflash_write2_2

			call	spi_inactive
			
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
; PAR4	=	256bytes-blocks
;------------------------------------------------------------------------------
spiflash_write41:	call	api_resetptr
			rcall	spiflash_qactive

spiflash_write41_1:	rcall	spiflash_wren	;write enable
					
			call	spi_active

			ldi	XL,0x02		;WRITE
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	XL,0x3F		;all IO output
			out	CTRLDDR,XL
			ldi	r22,SPI_SCK_PULSE

			ldi	r24,0x00	;256 bytes
			ldi	r25,1
			
spiflash_write41_2:	call	api_buf_bread
			mov	r23,XL
			lsr	XL
			lsr	XL
			andi	XL,0x3c
			out	CTRLPORT,XL
			nop
			out	CTRLPIN,r22	;pulse
			lsl	r23
			lsl	r23			
			andi	r23,0x3c
			out	CTRLPORT,r23
			nop
			out	CTRLPIN,r22	;pulse
			
			sbiw	r24,1
			brne	spiflash_write41_2
			
			out	CTRLPIN,r22	;pulse off

			call	spi_inactive
			call	spi0_reinit
			
			rcall	spiflash_wready3	
			add	r17,const_1
			adc	r18,const_0
			
			dec	r19
			brne	spiflash_write41_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write 
; PAR1	=	ADDRL
; PAR2	=	ADDRM
; PAR3	=	ADDRH
; PAR4	=	512bytes-blocks
;------------------------------------------------------------------------------
spiflash_write42:	call	api_resetptr
			rcall	spiflash_qactive

spiflash_write42_1:	rcall	spiflash_wren	;write enable
					
			call	spi_active

			ldi	XL,0x38		;WRITE QUAD
			call	spi_byte
			
			mov	XL,r18		;AH
			call	spi_byte
			mov	XL,r17		;AM
			call	spi_byte
			call	spi_zerobyte	;AL

			ldi	XL,0x3F		;all IO output
			out	CTRLDDR,XL
			ldi	r22,SPI_SCK_PULSE


			ldi	r24,0x00	;256 words
			ldi	r25,2
			
spiflash_write42_2:	call	api_buf_bread
			mov	r23,XL
			lsr	XL
			lsr	XL
			andi	XL,0x3c
			out	CTRLPORT,XL
			nop
			out	CTRLPIN,r22	;pulse
			lsl	r23
			lsl	r23			
			andi	r23,0x3c
			out	CTRLPORT,r23
			nop
			out	CTRLPIN,r22	;pulse
			
			sbiw	r24,1
			brne	spiflash_write42_2
			
			out	CTRLPIN,r22	;pulse off

			call	spi_inactive
			call	spi0_reinit
			
			rcall	spiflash_wready3	
			ldi	XL,2
			add	r17,XL
			adc	r18,const_0
			
			dec	r19
			brne	spiflash_write42_1
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
; set bank
; PAR4 = bank
;------------------------------------------------------------------------------
spiflash_set_bank:	call	spi_active
			ldi	XL,0x17			;set bank
			call	spi_byte
			mov	XL,r19			;bank no
			andi	XL,0x7f			;24 bit adressing mode
			call	spi_byte
			call	spi_inactive
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
; subroutines
;------------------------------------------------------------------------------
spiflash_wren:		call	spi_active
			ldi	XL,0x06			;WREN cmd
			call	spi_byte
			jmp	spi_inactive
				

spiflash_wrdis:		call	spi_active
			ldi	XL,0x04			;WRDIS cmd
			call	spi_byte
			jmp	spi_inactive

spiflash_qactive:	call	spi_active
			ldi	XL,0x35			;read config
			call	spi_byte
			ldi	XL,0x00			;status reg 1
			call	spi_byte
			call	spi_inactive
		
			andi	XL,0x02
			breq	spiflash_qactive_1
			ret

spiflash_qactive_1:	rcall	spiflash_wren		;write enable
			call	spi_active
			ldi	XL,0x01			;WRR cmd
			call	spi_byte
			ldi	XL,0x00			;status reg 1
			call	spi_byte
			ldi	XL,0x02			;config reg 1
			call	spi_byte
			call	spi_inactive

			ldi	ZL,10
			ldi	ZH,0
;			call	api_wait_ms
;
			call	spiflash_wready

			call	spi_active
			ldi	XL,0x35			;read config
			call	spi_byte
			ldi	XL,0x00			;status reg 1
			call	spi_byte
			jmp	spi_inactive
			

			;wait for ready
spiflash_wready:	call	spi_active
			ldi	XL,0x05			;get status
			call	spi_byte
spiflash_wready_1:	call	spi_zerobyte
			andi	XL,0x01
			brne	spiflash_wready_1
			jmp	spi_inactive
								
				
			;wait for ready with timeout
spiflash_wready2:	call	spi_active
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
			call	spi_inactive
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
spiflash_wready2_2:	jmp	spi_inactive

			;wait for ready with fast timeout
spiflash_wready3:	ldi	ZL,0
			ldi	ZH,0
			call	spi_active
			ldi	XL,0x05			;get status
			call	spi_byte
spiflash_wready3_1:	call	spi_zerobyte
			andi	XL,0x01
			breq	spiflash_wready3_2
			sbiw	ZL,1
			brne	spiflash_wready3_1
			call	spi_inactive
			pop	r16			;kill stack
			pop	r16
			ldi	r16,0x41		;timeout
			jmp	main_loop
			
spiflash_wready3_2:	jmp	spi_inactive
			

spiflash_sbyte:		call	spi_active
			call	spi_byte
			jmp	spi_inactive
