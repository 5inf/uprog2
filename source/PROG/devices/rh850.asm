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

.equ	RH850_COMM_SOH	= 0x01
.equ	RH850_COMM_STX	= 0x02
.equ	RH850_COMM_ETX	= 0x03
.equ	RH850_COMM_ETB	= 0x17

.equ	RH850_CMD_MERASE	= 0x20
.equ	RH850_CMD_BERASE	= 0x22
.equ	RH850_CMD_BCHECK	= 0x32
.equ	RH850_CMD_PROG		= 0x40
.equ	RH850_CMD_VERIFY	= 0x13
.equ	RH850_CMD_READID	= 0xC0
.equ	RH850_CMD_SECURE	= 0xA0
.equ	RH850_CMD_OSCSET	= 0x90
.equ	RH850_CMD_RESET		= 0x00
.equ	RH850_CMD_STATUS	= 0x70
.equ	RH850_CMD_ROPT		= 0x27
.equ	RH850_CMD_WOPT		= 0x26


.equ	RH850_RESET	= SIG1
.equ	RH850_SCK	= SIG2
.equ	RH850_FPDR	= SIG3	;to device
.equ	RH850_FPDT	= SIG4	;from device
.equ	RH850_FLMD0	= SIG5

;FLMD0, RH850_RESET, RH850_FPDR, RH850_SCK
.equ	RH850_DIRSET	= SIG1_OR | SIG2_OR | SIG3_OR | SIG5_OR 

;------------------------------------------------------------------------------
; INIT CSI MODE
; PAR4=number of FLMDO pulses
; PAR3=SOD (will be stored)
; PAR2=PR5 OF PM3
;------------------------------------------------------------------------------
rh850_init:		mov	r21,r17
			mov	r8,r18				;store SOD
			clr	r9				;low speed
			ldi	XL,SIG2_OR
			mov	r10,XL				;for faster clock
					
			out	CTRLPORT,const_0		;alles aus
			ldi	XL,RH850_DIRSET			;set direction
			out	CTRLDDR,XL
			call	api_vcc_on			;VCC on
			ldi	ZL,100
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,RH850_FLMD0		;FLMD0=1
			sbi	CTRLPORT,RH850_SCK
			sbi	CTRLPORT,RH850_FPDR
			sbi	CTRLPORT,RH850_FPDT
			ldi	ZL,10
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,RH850_RESET		;release RESET with FLMD0=1
			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms
			cbi	CTRLPORT,RH850_RESET		;release RESET with FLMD0=1
			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,RH850_RESET		;release RESET with FLMD0=1
			mov	ZL,r21
			ldi	ZH,0
			call	wait_ms

			;pulses for switching to csi mode
rh850_init_1:		cbi	CTRLPORT,RH850_FLMD0		;FLMD0=0 (pulse start)
			rcall	rh850_slow_wait
			sbi	CTRLPORT,RH850_FLMD0		;FLMD0=1 (pulse end)
			rcall	rh850_slow_wait
			dec	r19				;pulse counter
			brne	rh850_init_1
			cbi	CTRLDDR,SIG4

			ldi	r24,20
rh850_init_1a:		rcall	rh850_wait_recv			;wait for FPDT HIGH
			brtc	rh850_init_1b
			dec	r24
			brne	rh850_init_1a
rh850_init_err1:	ldi	r16,0x41			;timeout
			jmp	main_loop
			
rh850_init_1b:		ldi	ZL,50
			ldi	ZH,0
			call	api_wait_ms

			rcall	rh850_wait_send			;wait for FPDT LOW
			brts	rh850_init_err1

			ldi	XL,0x55
			rcall	rh850_byte

			ldi	XL,0x00
			rcall	rh850_byte
			cpi	XL,0xc1
			breq	rh850_init_1c
			
rh850_init_err2:	ldi	r16,0x42			;no sync
			jmp	main_loop
					
rh850_init_1c:		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EXIT
;------------------------------------------------------------------------------
rh850_exit:		out	CTRLPORT,const_0	;alles aus
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

rh850_init_err:		ldi	r16,0x40			;wrong status
			jmp	main_loop
			

;------------------------------------------------------------------------------
; start MCU
;------------------------------------------------------------------------------
rh850_run:		out	CTRLPORT,const_0	;alles aus
			ldi	XL,RH850_DIRSET		;set direction
			out	CTRLDDR,XL
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,RH850_RESET	;release RESET with FLMD0=0
			set
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; set clock to high speed
;------------------------------------------------------------------------------
rh850_high_speed:	mov	r9,const_1
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; get device
;------------------------------------------------------------------------------
rh850_get_device:	call	api_resetptr
			ldi	ZL,LOW(rh850_getdev_data*2)
			ldi	ZH,HIGH(rh850_getdev_data*2)
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_status
			brts	rh850_getdev_e1

			ldi	ZL,LOW(rh850_getdev_data*2)
			ldi	ZH,HIGH(rh850_getdev_data*2)
			mov	XL,r8
			rcall	rh850_send_fframe
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
		
		
rh850_getdev_e1:	ldi	r16,0x44			;wrong status
			jmp	main_loop
			
rh850_getdev_data:	.db	0x01,0x38			;get status


;------------------------------------------------------------------------------
; set frequency
; par4=set select
;------------------------------------------------------------------------------
rh850_set_freq:		call	api_resetptr
			ldi	ZL,LOW(rh850_setfreq_data*2)
			ldi	ZH,HIGH(rh850_setfreq_data*2)
			ldi	XL,12
			mul	XL,r19
			add	ZL,r0
			adc	ZH,r1
			
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_status

			brts	rh850_setfreq_e1

			ldi	ZL,LOW(rh850_setfreqx_data*2)
			ldi	ZH,HIGH(rh850_setfreqx_data*2)
			mov	XL,r8
			rcall	rh850_send_fframe
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
		
		
rh850_setfreq_e1:	ldi	r16,0x44			;wrong status
			jmp	main_loop
			
rh850_setfreq_data:	.db	0x09,0x32, 0x00,0x7A,0x12,0x00, 0x03,0xd0,0x90,0x00, 0,0	;8M -> 64M
			.db	0x09,0x32, 0x00,0xB7,0x1B,0x00, 0x03,0xd0,0x90,0x00, 0,0	;12M -> 64M
			.db	0x09,0x32, 0x00,0xF4,0x24,0x00, 0x03,0xd0,0x90,0x00, 0,0	;16M -> 64M
			.db	0x09,0x32, 0x01,0x31,0x2D,0x00, 0x03,0xd0,0x90,0x00, 0,0	;20M -> 64M
			.db	0x09,0x32, 0x01,0x6E,0x36,0x00, 0x03,0xd0,0x90,0x00, 0,0	;24M -> 64M
			.db	0x09,0x32, 0x00,0x00,0x00,0x00, 0x03,0xd0,0x90,0x00, 0,0	;int -> 64M
		
			.db	0x09,0x32, 0x00,0x7A,0x12,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;8M -> 80M
			.db	0x09,0x32, 0x00,0xB7,0x1B,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;12M -> 80M
			.db	0x09,0x32, 0x00,0xF4,0x24,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;16M -> 80M
			.db	0x09,0x32, 0x01,0x31,0x2D,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;20M -> 80M
			.db	0x09,0x32, 0x01,0x6E,0x36,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;24M -> 80M
			.db	0x09,0x32, 0x00,0x00,0x00,0x00, 0x04,0xc4,0xb4,0x00, 0,0	;int -> 80M
		
rh850_setfreqx_data:	.db	0x01,0x32


;------------------------------------------------------------------------------
; inquiry
;------------------------------------------------------------------------------
rh850_inquiry:		call	api_resetptr
			ldi	ZL,LOW(rh850_inquiry_data*2)
			ldi	ZH,HIGH(rh850_inquiry_data*2)
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_status
			brts	rh850_inquiry_e1
			jmp	main_loop_ok
				
rh850_inquiry_e1:	ldi	r16,0x44			;wrong status
			jmp	main_loop
			
rh850_inquiry_data:	.db	0x01,0x00			;inquiry

;------------------------------------------------------------------------------
; auth mode get
;------------------------------------------------------------------------------
rh850_authmode_get:	call	api_resetptr
			ldi	ZL,LOW(rh850_amget_data*2)
			ldi	ZH,HIGH(rh850_amget_data*2)
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_status
			brts	rh850_amget_e1

			ldi	ZL,LOW(rh850_amget_data*2)
			ldi	ZH,HIGH(rh850_amget_data*2)
			mov	XL,r8
			rcall	rh850_send_fframe
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
				
rh850_amget_e1:		ldi	r16,0x44				;wrong status
			jmp	main_loop
			
rh850_amget_data:	.db	0x01,0x2c			;ID authentication mode get

;------------------------------------------------------------------------------
; lock bit enable
;------------------------------------------------------------------------------
rh850_lb_enable:	call	api_resetptr
			ldi	ZL,LOW(rh850_lben_data*2)
			ldi	ZH,HIGH(rh850_lben_data*2)
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
							
rh850_lben_data:	.db	0x01,0x24			;ID lock bit enable

;------------------------------------------------------------------------------
; signature
;------------------------------------------------------------------------------
rh850_signature:	call	api_resetptr
			ldi	ZL,LOW(rh850_signature_data*2)
			ldi	ZH,HIGH(rh850_signature_data*2)
			ldi	XL,RH850_COMM_SOH
			rcall	rh850_send_fframe
			rcall	rh850_get_status
			brts	rh850_signature_e1

			ldi	ZL,LOW(rh850_signature_data*2)
			ldi	ZH,HIGH(rh850_signature_data*2)
			mov	XL,r8
			rcall	rh850_send_fframe
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
				
rh850_signature_e1:	ldi	r16,0x44			;wrong status
			jmp	main_loop
			
rh850_signature_data:	.db	0x01,0x3a			;signature


rh850_set_addr1:	sts	devbuf+0,r16
			sts	devbuf+1,r17
			sts	devbuf+2,r18
			sts	devbuf+3,r19
			jmp	main_loop_ok

rh850_set_addr2:	sts	devbuf+4,r16
			sts	devbuf+5,r17
			sts	devbuf+6,r18
			sts	devbuf+7,r19
			jmp	main_loop_ok



;------------------------------------------------------------------------------
; Blank check
;------------------------------------------------------------------------------
rh850_bcheck:		call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x10			;bcheck command
			rcall	rh850_sendbyte
			lds	XL,devbuf+3		;SA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+2		;SA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+1		;SA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+0		;SA LL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+7		;EA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+6		;EA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+5		;EA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+4		;EA LL
			rcall	rh850_sendbyte		
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_full_frame
			jmp	main_loop_ok
			

;------------------------------------------------------------------------------
; BLOCK ERASE
; PAR1 = ADDR LOW...
;------------------------------------------------------------------------------
rh850_erase:		rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x05			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x12			;erase command
			rcall	rh850_sendbyte
			mov	XL,r19			;SA HH
			rcall	rh850_sendbyte		
			mov	XL,r18			;SA HL
			rcall	rh850_sendbyte		
			mov	XL,r17			;SA LH
			rcall	rh850_sendbyte		
			mov	XL,r16			;SA LL
			rcall	rh850_sendbyte		
		;	push	r16
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			rcall	rh850_get_status
		;	pop	r16
			brts	rh850_erase_err
			jmp	main_loop_ok
rh850_erase_err:;	ldi	r16,0x46
			jmp	main_loop


;------------------------------------------------------------------------------
; DATA BLOCKS ERASE (2K)
; PAR1 = ADDR LOW...
;------------------------------------------------------------------------------
rh850_derase:		ldi	r23,32
			
rh850_derase_1:		rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x05			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x12			;erase command
			rcall	rh850_sendbyte
			mov	XL,r19			;SA HH
			rcall	rh850_sendbyte		
			mov	XL,r18			;SA HL
			rcall	rh850_sendbyte		
			mov	XL,r17			;SA LH
			rcall	rh850_sendbyte		
			mov	XL,r16			;SA LL
			rcall	rh850_sendbyte		
			push	r16
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			rcall	rh850_get_status
			brts	rh850_derase_err
			pop	r16
			ldi	XL,0x40
			add	r16,XL
			adc	r17,const_0
			adc	r18,const_0
			adc	r19,const_0
			
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms

			dec	r23
			brne	rh850_derase_1
			
			jmp	main_loop_ok
rh850_derase_err:	pop	r16
			ldi	r16,0x46
			jmp	main_loop


;------------------------------------------------------------------------------
; Program start
;------------------------------------------------------------------------------
rh850_prog_start:	call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x13			;write command
			rcall	rh850_sendbyte
			lds	XL,devbuf+3		;SA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+2		;SA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+1		;SA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+0		;SA LL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+7		;EA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+6		;EA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+5		;EA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+4		;EA LL
			rcall	rh850_sendbyte		
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status
			jmp	main_loop


;------------------------------------------------------------------------------
; Verify start
;------------------------------------------------------------------------------
rh850_vfy_start:	call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x16			;verify command
			rcall	rh850_sendbyte
			lds	XL,devbuf+3		;SA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+2		;SA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+1		;SA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+0		;SA LL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+7		;EA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+6		;EA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+5		;EA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+4		;EA LL
			rcall	rh850_sendbyte		
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status
			jmp	main_loop

;------------------------------------------------------------------------------
; Bootstrap start
;------------------------------------------------------------------------------
rh850_bst_start:	call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x3F			;bst command
			rcall	rh850_sendbyte
			lds	XL,devbuf+3		;SA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+2		;SA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+1		;SA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+0		;SA LL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+7		;EA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+6		;EA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+5		;EA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+4		;EA LL
			rcall	rh850_sendbyte		
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status
			jmp	main_loop

	
;------------------------------------------------------------------------------
; PROGRAM 1K block
; PAR4=ETX/ETB
;------------------------------------------------------------------------------
rh850_prog_blockx:	movw	r24,r16
			rjmp	rh850_prog_block_0

rh850_prog_block:	ldi	r24,0
			ldi	r25,4

rh850_prog_block_0:	mov	r18,r19
			adiw	r24,1
			call	api_resetptr
			rcall	rh850_send_sod		;SOD senden
			mov	XL,r25			;LENH
			rcall	rh850_sendbyte
			mov	XL,r24			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x13			;write command
			rcall	rh850_sendbyte
			sbiw	r24,1
			
rh850_prog_block_1:	call	api_buf_bread
			rcall	rh850_sendbyte
			sbiw	r24,1
			brne	rh850_prog_block_1

			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
	
			rcall	rh850_send_csum
			mov	XL,r18			;ETX/ETB
			rcall	rh850_sendbyte
		
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
		
			call	api_resetptr
			rcall	rh850_get_status
			jmp	main_loop

	
;------------------------------------------------------------------------------
; Verify 1K block
; PAR4=ETX/ETB
;------------------------------------------------------------------------------
rh850_vfy_blockx:	movw	r24,r16
			rjmp	rh850_vfy_block_0

rh850_vfy_block:	ldi	r24,0
			ldi	r25,4

rh850_vfy_block_0:	mov	r18,r19
			adiw	r24,1
			call	api_resetptr
			rcall	rh850_send_sod		;SOD senden
			mov	XL,r25			;LENH
			rcall	rh850_sendbyte
			mov	XL,r24			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x16			;write command
			rcall	rh850_sendbyte
			sbiw	r24,1
			
rh850_vfy_block_1:	call	api_buf_bread
			rcall	rh850_sendbyte
			sbiw	r24,1
			brne	rh850_vfy_block_1

			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
	
			rcall	rh850_send_csum
			mov	XL,r18			;ETX/ETB
			rcall	rh850_sendbyte
		
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
		
			call	api_resetptr
			rcall	rh850_get_status
			jmp	main_loop
						

;------------------------------------------------------------------------------
; Bootstrap 1K block
; PAR4=ETX/ETB
;------------------------------------------------------------------------------
rh850_bst_blockx:	movw	r24,r16
			rjmp	rh850_bst_block_0

rh850_bst_block:	ldi	r24,0
			ldi	r25,4

rh850_bst_block_0:	mov	r18,r19
			adiw	r24,1
			call	api_resetptr
			rcall	rh850_send_sod		;SOD senden
			mov	XL,r25			;LENH
			rcall	rh850_sendbyte
			mov	XL,r24			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x3F			;write command
			rcall	rh850_sendbyte
			sbiw	r24,1
			
rh850_bst_block_1:	call	api_buf_bread
			rcall	rh850_sendbyte
			sbiw	r24,1
			brne	rh850_bst_block_1

			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
	
			rcall	rh850_send_csum
			mov	XL,r18			;ETX/ETB
			rcall	rh850_sendbyte
		
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
		
			call	api_resetptr
			rcall	rh850_get_status
			jmp	main_loop
						
	
;------------------------------------------------------------------------------
; SKIP 1K block
; PAR4=ETX/ETB
;------------------------------------------------------------------------------
rh850_skip_block:	rcall	rh850_send_sod		;SOD senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x05			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x93			;skip command
			rcall	rh850_sendbyte
			
			ldi	XL,0x00			;skip size
			rcall	rh850_sendbyte
			ldi	XL,0x00			;skip size
			rcall	rh850_sendbyte
			ldi	XL,0x04			;skip size
			rcall	rh850_sendbyte
			ldi	XL,0x00			;skip size
			rcall	rh850_sendbyte
		
			rcall	rh850_send_csum
			mov	XL,r19			;ETX/ETB
			rcall	rh850_sendbyte
		
			call	api_resetptr
			rcall	rh850_get_status
			jmp	main_loop

;------------------------------------------------------------------------------
; Readout start
;------------------------------------------------------------------------------
rh850_read_start:	call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x15			;read command
			rcall	rh850_sendbyte
			lds	XL,devbuf+3		;SA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+2		;SA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+1		;SA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+0		;SA LL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+7		;EA HH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+6		;EA HL
			rcall	rh850_sendbyte		
			lds	XL,devbuf+5		;EA LH
			rcall	rh850_sendbyte		
			lds	XL,devbuf+4		;EA LL
			rcall	rh850_sendbyte		
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status
			jmp	main_loop

;------------------------------------------------------------------------------
; READ 2 1K blocks
;------------------------------------------------------------------------------
rh850_read_block:	call	api_resetptr

			rcall	rh850_send_sod		;SOD senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x15			;write command
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden

			rcall	rh850_get_frame		;get data frame

			cpi	XL,0x15
			brne	rh850_readblock_err

			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms


			rcall	rh850_send_sod		;SOD senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x15			;write command
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden

			rcall	rh850_get_frame		;get data frame

			cpi	XL,0x15
			brne	rh850_readblock_err

			jmp	main_loop_ok

rh850_readblock_err:	jmp	main_loop
						


;------------------------------------------------------------------------------
; get option bytes (both)
;------------------------------------------------------------------------------
rh850_read_opt:		call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x27			;read command
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status

			rcall	rh850_wait_send		;wait for FPDT LOW
			rcall	rh850_send_sod		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x27			;ACK
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden

			rcall	rh850_get_full_frame	;get data frame

			jmp	main_loop_ok


;------------------------------------------------------------------------------
; get CRC
;------------------------------------------------------------------------------
rh850_get_crc:		call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x09			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x18			;CRC command
			rcall	rh850_sendbyte
			ldi	r24,8			;8 bytes

rh850_get_crc_1:	call	api_buf_bread
			rcall	rh850_sendbyte
			dec	r24
			brne	rh850_get_crc_1			
			
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
					
			rcall	rh850_get_status

			call	api_resetptr
		
			rcall	rh850_wait_send		;wait for FPDT LOW
			rcall	rh850_send_sod		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x18			;ACK
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden

			rcall	rh850_waitr_long			
			rcall	rh850_get_full_frame	;get data frame

			jmp	main_loop_ok


rh850_waitr_long:	ldi	r24,0
rh850_waitr_long_1:	ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			rcall	rh850_wait_recv			;wait for FPDT HIGH
			brtc	rh850_waitr_long_2
			dec	r24
			brne	rh850_waitr_long_1			
rh850_waitr_long_2:	ret			

rh850_waits_long:	ldi	r24,100
rh850_waits_long_1:	ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			rcall	rh850_wait_send			;wait for FPDT HIGH
			brtc	rh850_waits_long_2
			dec	r24
			brne	rh850_waits_long_1			
rh850_waits_long_2:	ret			


;------------------------------------------------------------------------------
; set protection
; r19=state
;------------------------------------------------------------------------------
rh850_set_prot:		rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x02			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x20			;Pset command
			rcall	rh850_sendbyte
			mov	XL,r19
			ori	XL,0x1F
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
					
			rcall	rh850_get_status
			jmp	main_loop

;------------------------------------------------------------------------------
; get protection
; byte0=state
;------------------------------------------------------------------------------
rh850_get_prot:		call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x21			;Pget command
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
					
			rcall	rh850_get_status
			
			rcall	rh850_wait_send

			rcall	rh850_send_sod		;SOD senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x01			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x21			;Pget command
			rcall	rh850_sendbyte
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden

			rcall	rh850_get_frame
			
			jmp	main_loop_ok


;------------------------------------------------------------------------------
; write option bytes
;------------------------------------------------------------------------------
rh850_write_opt:	call	api_resetptr
			rcall	rh850_send_soh		;SOH senden
			ldi	XL,0x00			;LENH
			rcall	rh850_sendbyte
			ldi	XL,0x21			;LENL
			rcall	rh850_sendbyte
			ldi	XL,0x26			;write command
			rcall	rh850_sendbyte			
			
			ldi	r25,32
rh850_write_opt_1:	call	api_buf_bread
			rcall	rh850_sendbyte
			dec	r25
			brne	rh850_write_opt_1
					
			rcall	rh850_send_csum
			rcall	rh850_send_etx		;ETX senden
			
			rcall	rh850_get_status

			jmp	main_loop_ok

test:

;------------------------------------------------------------------------------
; status request (1/2 bytes)
;------------------------------------------------------------------------------
rh850_get_status:	clt					;status
			clr	r16
			ldi	r24,50
rh850_get_status_1:	rcall	rh850_wait_recv			;wait for FPDT HIGH
			brtc	rh850_get_status_2
			dec	r24
			brne	rh850_get_status_1			
			ldi	r16,0x43			;timeout
rh850_get_status_e1:	pop	r0
			pop	r0
			jmp	main_loop

rh850_get_status_2:	rcall	rh850_send_zero			;SOH
			rcall	rh850_send_zero			;LENH
			rcall	rh850_send_zero			;LENL
			cpi	XL,2				;err
			breq	rh850_get_status_3
			rcall	rh850_send_zero			;CMD			
			sbrc	XL,7
			set
			rcall	rh850_send_zero			;CSUM			
			rcall	rh850_send_zero			;ETX			
			ret
			
rh850_get_status_3:	rcall	rh850_send_zero			;CMD			
			sbrc	XL,7
			set
			rcall	rh850_send_zero			;ERRCODE
			mov	r16,XL
;			andi	r16,0x7f
			rcall	rh850_send_zero			;CSUM			
			rcall	rh850_send_zero			;ETX			
			ret
			

;------------------------------------------------------------------------------
; fixdata send
; XL=SOH/SOD
; Z=ptr ab LENL
;------------------------------------------------------------------------------
rh850_send_fframe:	clt					;status
			ldi	r24,20
rh850_send_fframe_1:	rcall	rh850_wait_send			;wait for FPDT LOW
			brtc	rh850_send_fframe_2
			dec	r24
			brne	rh850_send_fframe_1			
			ldi	r16,0x43			;timeout
			pop	r0
			pop	r0
			jmp	main_loop

rh850_send_fframe_2:	clr	r5				;clear CSUM
			rcall	rh850_byte			;SOH/SOD			
			rcall	rh850_send_zero			;LENH			
			lpm	r24,Z+				;get length
			mov	XL,r24
			rcall	rh850_sendbyte			;LENL			
rh850_send_fframe_3:	lpm	XL,Z+
			rcall	rh850_sendbyte			;frame data			
			dec	r24
			brne	rh850_send_fframe_3
			rcall	rh850_send_csum
			rjmp	rh850_send_etx
			
			
;------------------------------------------------------------------------------
; get a frame and write data to buffer
; XL=ack
;------------------------------------------------------------------------------
rh850_get_frame:	clt					;status
			ldi	r24,200
rh850_get_frame_1:	rcall	rh850_wait_recv			;wait for FPDT HIGH
			brtc	rh850_get_frame_2
			dec	r24
			brne	rh850_get_frame_1			
			ldi	r16,0x43			;timeout
			pop	r0
			pop	r0
			jmp	main_loop

rh850_get_frame_2:	rcall	rh850_send_zero			;SOH
			rcall	rh850_send_zero			;LENH
			mov	r25,XL
			rcall	rh850_send_zero			;LENL
			mov	r24,XL
			rcall	rh850_send_zero			;CMD			
			mov	r16,XL
			sbiw	r24,1				;-CMD
				
rh850_get_frame_3:	mov	XL,r24
			or	XL,r25
			breq	rh850_get_frame_4
			rcall	rh850_send_zero			;data			
			call	api_buf_bwrite
			sbiw	r24,1
			rjmp	rh850_get_frame_3

rh850_get_frame_4:	rcall	rh850_send_zero			;CSUM			
			rcall	rh850_send_zero			;ETX
			mov	XL,r16			
			ret

			
;------------------------------------------------------------------------------
; get a full frame and write data to buffer (debug)
; XL=ack
;------------------------------------------------------------------------------
rh850_get_full_frame:	clt					;status
			ldi	r24,200
rh850_get_fframe_1:	rcall	rh850_wait_recv			;wait for FPDT HIGH
			brtc	rh850_get_fframe_2
			dec	r24
			brne	rh850_get_fframe_1			
			ldi	r16,0x43			;timeout
			pop	r0
			pop	r0
			jmp	main_loop

rh850_get_fframe_2:	rcall	rh850_send_zero			;SOH
			call	api_buf_bwrite
			rcall	rh850_send_zero			;LENH
			call	api_buf_bwrite
			mov	r25,XL
			rcall	rh850_send_zero			;LENL
			call	api_buf_bwrite
			mov	r24,XL
			rcall	rh850_send_zero			;CMD			
			call	api_buf_bwrite
			mov	r16,XL
			sbiw	r24,1				;-CMD

rh850_get_fframe_3:	mov	XL,r24
			or	XL,r25
			breq	rh850_get_fframe_4
			rcall	rh850_send_zero			;data			
			call	api_buf_bwrite
			sbiw	r24,1
			rjmp	rh850_get_fframe_3

rh850_get_fframe_4:	rcall	rh850_send_zero			;CSUM			
			call	api_buf_bwrite
			rcall	rh850_send_zero			;ETX
			call	api_buf_bwrite
			mov	XL,r16			
			ret


;###############################################################################
; some special bytes
;###############################################################################
rh850_send_zero:	clr	XL
			rjmp	rh850_sendbyte


rh850_send_soh:		ldi	XL,RH850_COMM_SOH
			clr	r5
			rjmp	rh850_byte

rh850_send_sod:		mov	XL,r8
			clr	r5
			rjmp	rh850_byte

rh850_send_stx:		ldi	XL,RH850_COMM_STX
			clr	r5
			rjmp	rh850_byte

rh850_send_etx:		ldi	XL,RH850_COMM_ETX
			rjmp	rh850_byte

rh850_send_etb:		ldi	XL,RH850_COMM_ETB
			rjmp	rh850_byte

rh850_clear_csum:	clr	r5
			ret

rh850_send_csum:	mov	XL,r5
			rjmp	rh850_byte

;###############################################################################
; COMMUNICATION SUBROUTINES
;###############################################################################
rh850_sendbyte:		sub	r5,XL				;checksum

rh850_byte:		ldi	XH,0x08
			sbrs	r9,0
			rjmp	rh850_slow_byte
rh850_byte_1:		sbrc	XL,7				;1
			sbi	CTRLPORT,RH850_FPDR		;2 data HIGH	
			sbrs	XL,7				;1
			cbi	CTRLPORT,RH850_FPDR		;2 data LOW
			out	CTRLPIN,r10			;2 SCK
			lsl	XL				;1 result
			sbic	CTRLPIN,RH850_FPDT		;1 FPDT
			inc	XL				;1
			out	CTRLPIN,r10			;2 SCK
			dec	XH				;1
			brne	rh850_byte_1			;2/1
			ret

rh850_slow_byte:	push	ZL
			ldi	ZL,0
rh850_slow_byte_w0:	dec	ZL
			brne	rh850_slow_byte_w0
			ldi	ZL,0x80
rh850_slow_byte_w1:	dec	ZL
			brne	rh850_slow_byte_w1
			pop	ZL

rh850_slow_byte_1:	cbi	CTRLPORT,RH850_SCK		;2 SCK
			sbrc	XL,7				;1
			sbi	CTRLPORT,RH850_FPDR		;2 data HIGH	
			sbrs	XL,7				;1
			cbi	CTRLPORT,RH850_FPDR		;2 data LOW
			lsl	XL				;1 result
			rcall	rh850_slow_wait
			sbic	CTRLPIN,RH850_FPDT		;1 FPDT
			inc	XL				;1
			sbi	CTRLPORT,RH850_SCK		;2 SCK
			rcall	rh850_slow_wait			
			dec	XH				;1
			brne	rh850_slow_byte_1		;2/1
			ret

rh850_slow_wait:	push	XH
			ldi	XH,0
rh850_slow_wait_1:	dec	XH
			nop
			nop
			brne	rh850_slow_wait_1
			pop	XH
			ret	

			
			;wait for FPDT LOW
rh850_wait_send:	push	ZH
			push	ZL
			clr	ZL
			clr	ZH
			clt
rh850_wait_send_1:	sbis	CTRLPIN,RH850_FPDT		;1 FPDT
			rjmp	rh850_wait_send_2
			rcall	rh850_ret			
			sbiw	ZL,1
			brne	rh850_wait_send_1
			set					;timeout
rh850_wait_send_2:	pop	ZL
			pop	ZH
			ret

			
			;wait for FPDT HIGH
rh850_wait_recv:	push	ZH
			push	ZL
			clr	ZL
			clr	ZH
			clt
rh850_wait_recv_1:	sbic	CTRLPIN,RH850_FPDT		;1 FPDT
			rjmp	rh850_wait_recv_2			
;			rcall	rh850_ret			
			sbiw	ZL,1
			brne	rh850_wait_recv_1
			set					;timeout
rh850_wait_recv_2:	pop	ZL
			pop	ZH
rh850_ret:		ret
	
			
			