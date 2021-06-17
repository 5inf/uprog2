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

.equ	V850_COMM_SOH	= 0x01
.equ	V850_COMM_STX	= 0x02
.equ	V850_COMM_ETX	= 0x03
.equ	V850_COMM_ETB	= 0x17

.equ	V850_CMD_MERASE	= 0x20
.equ	V850_CMD_BERASE	= 0x22
.equ	V850_CMD_BCHECK	= 0x32
.equ	V850_CMD_PROG	= 0x40
.equ	V850_CMD_VERIFY	= 0x13
.equ	V850_CMD_READID	= 0xC0
.equ	V850_CMD_SECURE	= 0xA0
.equ	V850_CMD_OSCSET	= 0x90
.equ	V850_CMD_RESET	= 0x00
.equ	V850_CMD_STATUS	= 0x70

.equ	V850_RESET	= SIG1
.equ	V850_SCK	= SIG2
.equ	V850_SI		= SIG3	;to device
.equ	V850_SO		= SIG4	;from device
.equ	V850_FLMD0	= SIG5
.equ	V850_TRIGGER	= SIG6

;FLMD0, V850_RESET, V850_SCK
.equ	V850_DIRSET	= SIG1_OR | SIG2_OR | SIG5_OR | SIG6_OR

;------------------------------------------------------------------------------
; INIT CSI MODE
; PAR4 = number of pulses 
;------------------------------------------------------------------------------
v850_init:		ldi	XL,SIG2_OR
			mov	r10,XL				;for faster clock
					
			out	CTRLPORT,const_0		;alles aus
			ldi	XL,V850_DIRSET			;set direction
			out	CTRLDDR,XL
			call	api_vcc_on			;VCC on
			sbi	CTRLPORT,V850_TRIGGER
			ldi	ZL,150
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,V850_SCK
;			sbi	CTRLPORT,V850_SI
			ldi	ZL,2
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,V850_FLMD0		;FLMD0=1
;			cbi	CTRLPORT,V850_SI
			ldi	ZL,5
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,V850_RESET		;release RESET with FLMD0=1
			mov	ZL,r18
			ldi	ZH,0
			call	wait_ms

			;pulses for switching to csi mode
v850_init_1:		cbi	CTRLPORT,V850_FLMD0		;FLMD0=0 (pulse start)
			rcall	v850_slow_wait
			sbi	CTRLPORT,V850_FLMD0		;FLMD0=1 (pulse end)
			rcall	v850_slow_wait
			dec	r19				;pulse counter
			brne	v850_init_1

;			rcall	v850_wait_send
			ldi	ZL,150
			ldi	ZH,0
			call	wait_ms

			sbi	CTRLDDR,V850_SI			;data out
			sbi	CTRLPORT,V850_TRIGGER		;trigger LA

			rcall	v850_reset_cmd
		
			ldi	ZL,10
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_init_err1
			jmp	main_loop_ok
			
v850_init_err1:		ldi	r16,0x41			;init error
			sts	0x100,r15			;error code
			jmp	main_loop
					
v850_init_1c:		jmp	main_loop_ok


;------------------------------------------------------------------------------
; EXIT
;------------------------------------------------------------------------------
v850_exit:		out	CTRLPORT,const_0	;alles aus
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; start MCU
;------------------------------------------------------------------------------
v850_run:		out	CTRLPORT,const_0	;alles aus
			ldi	XL,V850_DIRSET		;set direction
			out	CTRLDDR,XL
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms
			sbi	CTRLPORT,V850_RESET	;release RESET with FLMD0=0
			set
			jmp	main_loop_ok



;------------------------------------------------------------------------------
; get device status
; PAR4 = frequency (MHZ)
;------------------------------------------------------------------------------
v850_set_osc:		rcall	v850_send_soh		;SOH senden
			ldi	XL,0x05			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x90			;set osc command
			rcall	v850_sendbyte
			mov	XL,r19			;freq
			rcall	v850_sendbyte
			clr	XL			;0
			rcall	v850_sendbyte
			clr	XL			;0
			rcall	v850_sendbyte
			ldi	XL,0x04			;4=exponent
			rcall	v850_sendbyte
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	ZL,100
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_set_osc_e1

			jmp	main_loop_ok
		
		
v850_set_osc_e1:	ldi	r16,0x42			;wrong status
			sts	0x100,r15			;error code
			jmp	main_loop
			
v850_set_osc_data:	.db	0x01,0x38			;get status




;------------------------------------------------------------------------------
; get device status
;------------------------------------------------------------------------------
v850_get_signature:	call	api_resetptr
			
			rcall	v850_send_soh		;SOH senden
			ldi	XL,0x01			;LEN
			rcall	v850_sendbyte
			ldi	XL,0xC0			;read device ID command
			rcall	v850_sendbyte
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden
			rcall	v850_wait_100u		

			rcall	v850_request_status
			rcall	v850_wait_100u		
			rcall	v850_get_status
			brts	v850_getsig_e1

			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	v850_get_full_frame

			jmp	main_loop_ok
		
		
v850_getsig_e1:		ldi	r16,0x42			;wrong status
			sts	0x100,r15			;error code
			jmp	main_loop
			

;------------------------------------------------------------------------------
; main flash blank check
; par1-4 end addr
;------------------------------------------------------------------------------
v850_bcheck_main:	call	api_resetptr
			rcall	v850_send_soh		;SOH senden
			ldi	XL,0x07			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x32			;bcheck command
			rcall	v850_sendbyte
			ldi	XL,0x00			;SAH
			rcall	v850_sendbyte		
			ldi	XL,0x00			;SAM
			rcall	v850_sendbyte		
			ldi	XL,0x00			;SAL
			rcall	v850_sendbyte		
			mov	XL,r18			;EAH
			rcall	v850_sendbyte		
			mov	XL,r17			;EAH
			rcall	v850_sendbyte		
			mov	XL,r16			;EAH
			rcall	v850_sendbyte		
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	r24,20

v850_bcheckm_loop:	ldi	ZL,100
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brtc	v850_bcheckm_ok
			
			mov	XL,r15
			cpi	XL,0x11			;not blank
			breq	v850_bcheckm_nb
			
			dec	r24
			brne	v850_bcheckm_loop
v850_bcheckm_err:	ldi	r16,0x43		;timeout
			jmp	main_loop
			
v850_bcheckm_ok:	jmp	main_loop_ok	

v850_bcheckm_nb:	ldi	r16,0x44		;not blank
			jmp	main_loop
			

;------------------------------------------------------------------------------
; flash blank check
; par1-2 	- start addr (<<8)
; par3-4	- size in 4K increments 
;------------------------------------------------------------------------------
v850_bcheck:		call	api_resetptr
			ldi	r20,0x32		;bcheck command
			rcall	v850_addr_cmd

			ldi	r24,20

v850_bcheck_loop:	ldi	ZL,100
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brtc	v850_bcheck_ok
			
			mov	XL,r15
			cpi	XL,0x11			;not blank
			breq	v850_bcheck_nb
			
			dec	r24
			brne	v850_bcheck_loop
v850_bcheck_err:	ldi	r16,0x43		;timeout
			jmp	main_loop
			
v850_bcheck_ok:		jmp	main_loop_ok	

v850_bcheck_nb:		ldi	r16,0x44		;not blank
			jmp	main_loop
			


;------------------------------------------------------------------------------
; CHIP ERASE
;------------------------------------------------------------------------------
v850_chip_erase:	rcall	v850_send_soh		;SOH senden
			ldi	XL,0x01			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x20			;erase command
			rcall	v850_sendbyte
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	r24,20

v850_cerase_loop:	ldi	ZL,0
			ldi	ZH,4
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brtc	v850_cerase_ok
			
			dec	r24
			brne	v850_cerase_loop
v850_cerase_err:	ldi	r16,0x43		;timeout
			jmp	main_loop
			
v850_cerase_ok:		jmp	main_loop_ok	

;------------------------------------------------------------------------------
; Program start
;------------------------------------------------------------------------------
v850_prog_2k:		call	api_resetptr
			rcall	v850_send_soh		;SOH senden
			ldi	XL,0x07			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x40			;program command
			rcall	v850_sendbyte
			mov	XL,r18			;SAH
			rcall	v850_sendbyte		
			mov	XL,r17			;SAM
			rcall	v850_sendbyte		
			mov	XL,r16			;SAL
			rcall	v850_sendbyte
			
			ldi	r16,0xff
			ldi	XL,0x07
			add	r17,XL
			adc	r18,const_0
					
			mov	XL,r18			;EAH
			rcall	v850_sendbyte		
			mov	XL,r17			;EAH
			rcall	v850_sendbyte		
			mov	XL,r16			;EAH
			rcall	v850_sendbyte		
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_prog2k_e1

			ldi	r24,8			;blocks to do
			
v850_prog_2k_1:		ldi	r18,0x03		;ETX for block 8
			cpse	r24,const_1
			ldi	r18,0x17		;ETB for blocks 1-7
			
			rcall	v850_wait_100u	
			rcall	v850_block256		;write block

			ldi	r25,80
					
v850_prog2k_w1:		cpi	r25,0
			breq	v850_prog2k_e1			
;			ldi	ZL,8
;			ldi	ZH,0
;			call	api_wait_ms			
			rcall	v850_wait_100u	
			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status2
			dec	r25
			ldi	XL,0xff
			cp	XL,r15
			breq	v850_prog2k_w1
			cp	XL,r14
			breq	v850_prog2k_w1
			
			brts	v850_prog2k_e1
			
			dec	r24
			brne	v850_prog_2k_1	

v850_prog2k_2:		ldi	r24,8
			rcall	v850_wait_100u	
			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brtc	v850_prog2k_3
			mov	XL,r15
			cpi	XL,0xff
			brne	v850_prog2k_e1
			dec	r24
			brne	v850_prog2k_2
		
v850_prog2k_e1:		ldi	r16,0x42			;wrong status
			sts	0x100,r15			;error code
			jmp	main_loop

v850_prog2k_3:		jmp	main_loop_ok

;------------------------------------------------------------------------------
; Verify start
;------------------------------------------------------------------------------
v850_verify_start:	call	api_resetptr
			ldi	r20,0x13		;verify command
			rcall	v850_addr_cmd

			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_vfystart_e1

			jmp	main_loop_ok
		
v850_vfystart_e1:	ldi	r16,0x42			;wrong status
			sts	0x100,r15			;error code
			jmp	main_loop

;------------------------------------------------------------------------------
; Verify start
;------------------------------------------------------------------------------
v850_verifym_start:	call	api_resetptr
			rcall	v850_send_soh		;SOH senden
			ldi	XL,0x07			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x13			;verify command
			rcall	v850_sendbyte
			ldi	XL,0x00			;SAH
			rcall	v850_sendbyte		
			ldi	XL,0x00			;SAM
			rcall	v850_sendbyte		
			ldi	XL,0x00			;SAL
			rcall	v850_sendbyte		
			mov	XL,r18			;EAH
			rcall	v850_sendbyte		
			mov	XL,r17			;EAH
			rcall	v850_sendbyte		
			mov	XL,r16			;EAH
			rcall	v850_sendbyte		
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_vfymstart_e1

			jmp	main_loop_ok
		
v850_vfymstart_e1:	ldi	r16,0x42			;wrong status
			sts	0x100,r15			;error code
			jmp	main_loop



;------------------------------------------------------------------------------
; write 8 256 bytes blocks
; PAR4=ETX/ETB for last block
;------------------------------------------------------------------------------
v850_verify_blocks:	call	api_resetptr
			ldi	r24,8			;blocks to do
			
v850_vfy_blocks_1:	ldi	r18,0x17		;ETB for block 1-7
			cpi	r24,1
			brne	v850_vfy_blocks_2		
			
			mov	r18,r19			;ETX for block 8
			cpi	r18,0x03
			brne	v850_vfy_blocks_2
;			sbi	CTRLPORT,V850_TRIGGER
			rcall	v850_block256		;write block
					
			ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			rjmp	v850_vfy_blocks_3
			
v850_vfy_blocks_2:	rcall	v850_block256		;write block
					
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms

v850_vfy_blocks_3:	cbi	CTRLPORT,V850_TRIGGER

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status2
			brts	v850_vfy_blocks_e1
			
			dec	r24
			brne	v850_vfy_blocks_1	
			jmp	main_loop_ok

		
v850_vfy_blocks_e1:	ldi	r16,0x42		;wrong status
			sts	0x100,r15		;error code
			jmp	main_loop


;------------------------------------------------------------------------------
; secure command (write prohibition)
;------------------------------------------------------------------------------
v850_protect:		rcall	v850_reset_cmd
		
			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms

			rcall	v850_request_status
			rcall	v850_wait_100u	
			rcall	v850_get_status
			brts	v850_prot_err1

			rcall	v850_wait_100u	
			
			;secure command
			rcall	v850_send_soh		;SOH senden
			ldi	XL,0x03			;LEN
			rcall	v850_sendbyte
			ldi	XL,0xA0			;secure command
			rcall	v850_sendbyte	
			ldi	XL,0x00			;fixed to 0x00
			rcall	v850_sendbyte		
			ldi	XL,0x00			;fixed to 0x00
			rcall	v850_sendbyte		
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden

			ldi	ZL,2
			ldi	ZH,0
			call	wait_ms

			rcall	v850_rg_status
			brts	v850_prot_err1

			sbi	CTRLPORT,V850_TRIGGER
		
			rcall	v850_wait_100u	

			;secure data
			rcall	v850_send_stx		;STX senden
			ldi	XL,0x04			;LEN
			rcall	v850_sendbyte
			ldi	XL,0xFB			;write prohibition
			rcall	v850_sendbyte	
			ldi	XL,0x03			;fixed to 0x03 last boot cluster block
			rcall	v850_sendbyte		
			ldi	XL,0x00			;fixed to 0xFF
			rcall	v850_sendbyte		
			ldi	XL,0x00			;fixed to 0xFF
			rcall	v850_sendbyte					
			rcall	v850_send_csum
			rcall	v850_send_etx		;ETX senden


			ldi	ZL,50
			ldi	ZH,0
			call	wait_ms


			rcall	v850_wait_100u	
			rcall	v850_rg_status
			brts	v850_prot_err2

			jmp	main_loop_ok
			
v850_prot_err1:		ldi	r16,0x4B		;protect error
			sts	0x100,r15		;error code
			jmp	main_loop

v850_prot_err2:		mov	XL,r15
			cpi	XL,0x08
			brne	v850_prot_err1
			ldi	r16,0x4C		;always protected
			sts	0x100,r15		;error code
			jmp	main_loop




						
v850_block256:		rcall	v850_send_stx		;SOD senden
			ldi	XL,0x00			;LEN
			rcall	v850_sendbyte
			ldi	r25,0
v850_block256_1:	call	api_buf_bread
			rcall	v850_sendbyte
			dec	r25
			brne	v850_block256_1
			rcall	v850_send_csum
			mov	XL,r18			;ETX/ETB
			rjmp	v850_sendbyte


;------------------------------------------------------------------------------
; write comman with address block and start cmd
; r20 = command
; r16/r17 	- start addr (<<8)
; r18/r19	- size (<<8) 
;------------------------------------------------------------------------------
v850_addr_cmd:		rcall	v850_send_soh		;SOH senden
			ldi	XL,0x07			;LEN
			rcall	v850_sendbyte
			mov	XL,r20			;bcommand
			rcall	v850_sendbyte
			mov	XL,r17			;SAH start addr
			rcall	v850_sendbyte		
			mov	XL,r16			;SAM
			rcall	v850_sendbyte		
			clr	XL			;SAL ia always zero
			rcall	v850_sendbyte
			
			add	r16,r18
			adc	r17,r19
			sub	r16,const_1
			sbc	r17,const_0
				
			mov	XL,r17			;EAH
			rcall	v850_sendbyte		
			mov	XL,r16			;EAM
			rcall	v850_sendbyte		
			ldi	XL,0xff			;EAL
			rcall	v850_sendbyte		
			rcall	v850_send_csum
			rjmp	v850_send_etx		;ETX senden

		
;------------------------------------------------------------------------------
; reset cmd
;------------------------------------------------------------------------------
v850_reset_cmd:		rcall	v850_send_soh		;SOH senden
			ldi	XL,0x01			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x00			;reset command
			rcall	v850_sendbyte
			rcall	v850_send_csum
			rjmp	v850_send_etx		;ETX senden

		
;------------------------------------------------------------------------------
; reset cmd
;------------------------------------------------------------------------------
v850_request_status:	rcall	v850_send_soh		;SOH senden
			ldi	XL,0x01			;LEN
			rcall	v850_sendbyte
			ldi	XL,0x70			;request status command
			rcall	v850_sendbyte
			rcall	v850_send_csum
			rjmp	v850_send_etx		;ETX senden

;------------------------------------------------------------------------------
; status request (1/2 bytes)
;------------------------------------------------------------------------------
v850_get_status:	rcall	v850_send_zero			;STX
			rcall	v850_send_zero			;LEN
			rcall	v850_send_zero			;ACK			
			mov	r15,XL
			rcall	v850_send_zero			;CSUM			
			rcall	v850_send_zero			;ETX			
			clt					;status
			mov	XL,r15
			cpi	XL,0x06				;ACK value
			breq	v850_get_status_ok
			cpi	XL,0x86				;ACK value
			breq	v850_get_status_ok
			set
v850_get_status_ok:	ret

v850_get_status2:	rcall	v850_send_zero			;STX
			rcall	v850_send_zero			;LEN
			rcall	v850_send_zero			;ACK1			
			mov	r15,XL
			rcall	v850_send_zero			;ACK2			
			mov	r14,XL
			rcall	v850_send_zero			;CSUM			
			rcall	v850_send_zero			;ETX			
			clt					;status
			ldi	XL,0x06				;ACK value
			cpse	r15,XL
			set
			cpse	r14,XL
			set
			ret
			
v850_rg_status:		rcall	v850_wait_100u	
			rcall	v850_request_status
			rcall	v850_wait_100u	
			rjmp	v850_get_status


;------------------------------------------------------------------------------
; fixdata send
; XL=SOH/SOD
; Z=ptr ab LENL
;------------------------------------------------------------------------------
v850_send_fframe:	clt					;status
			ldi	r24,20
v850_send_fframe_1:	rcall	v850_wait_send			;wait for SO LOW
			brtc	v850_send_fframe_2
			dec	r24
			brne	v850_send_fframe_1			
			ldi	r16,0x43			;timeout
			pop	r0
			pop	r0
			jmp	main_loop

v850_send_fframe_2:	clr	r5				;clear CSUM
			rcall	v850_byte			;SOH/SOD			
			rcall	v850_send_zero			;LENH			
			lpm	r24,Z+				;get length
			mov	XL,r24
			rcall	v850_sendbyte			;LENL			
v850_send_fframe_3:	lpm	XL,Z+
			rcall	v850_sendbyte			;frame data			
			dec	r24
			brne	v850_send_fframe_3
			rcall	v850_send_csum
			rjmp	v850_send_etx
			
			
;------------------------------------------------------------------------------
; get a frame and write data to buffer
; XL=ack
;------------------------------------------------------------------------------
v850_get_frame:		rcall	v850_send_zero			;SOH
			rcall	v850_send_zero			;LENH
			mov	r25,XL
			rcall	v850_send_zero			;LENL
			mov	r24,XL
			rcall	v850_send_zero			;CMD			
			mov	r16,XL
			sbiw	r24,1				;-CMD
				
v850_get_frame_3:	mov	XL,r24
			or	XL,r25
			breq	v850_get_frame_4
			rcall	v850_send_zero			;data			
			call	api_buf_bwrite
			sbiw	r24,1
			rjmp	v850_get_frame_3

v850_get_frame_4:	rcall	v850_send_zero			;CSUM			
			rcall	v850_send_zero			;ETX
			mov	XL,r16			
			ret

			
;------------------------------------------------------------------------------
; get a full frame and write data to buffer
;------------------------------------------------------------------------------
v850_get_full_frame:	rcall	v850_send_zero			;SOH
			rcall	v850_send_zero			;LEN
			mov	r24,XL
			call	api_buf_bwrite

v850_get_fframe_1:	rcall	v850_send_zero			;data			
			call	api_buf_bwrite
			dec	r24
			brne	v850_get_fframe_1

v850_get_fframe_4:	rcall	v850_send_zero			;CSUM			
			call	api_buf_bwrite
			rcall	v850_send_zero			;ETX
			call	api_buf_bwrite	
			ret


;###############################################################################
; some special bytes
;###############################################################################
v850_send_zero:	clr	XL
			rjmp	v850_sendbyte


v850_send_soh:		ldi	XL,V850_COMM_SOH
			clr	r5
			rjmp	v850_byte

v850_send_sod:		mov	XL,r8
			clr	r5
			rjmp	v850_byte

v850_send_stx:		ldi	XL,V850_COMM_STX
			clr	r5
			rjmp	v850_byte

v850_send_etx:		ldi	XL,V850_COMM_ETX
			rjmp	v850_byte

v850_send_etb:		ldi	XL,V850_COMM_ETB
			rjmp	v850_byte

v850_clear_csum:	clr	r5
			ret

v850_send_csum:		mov	XL,r5
			rjmp	v850_byte

;###############################################################################
; COMMUNICATION SUBROUTINES
;###############################################################################
v850_sendbyte:		sub	r5,XL				;checksum

v850_byte:		ldi	XH,0x08
v850_byte_1:		out	CTRLPIN,r10			;2 SCK
			sbrc	XL,7				;1
			sbi	CTRLPORT,V850_SI		;2 data HIGH	
			sbrs	XL,7				;1
			cbi	CTRLPORT,V850_SI		;2 data LOW
			lsl	XL				;1 result
			sbic	CTRLPIN,V850_SO		;1 SO
			inc	XL				;1
			out	CTRLPIN,r10			;2 SCK
			nop
			nop
			nop
			nop
			nop
			dec	XH				;1
			brne	v850_byte_1			;2/1

			ldi	XH,160
v850_byte_2:		dec	XH
			brne	v850_byte_2
			ret


v850_wait_100u:		ldi	XH,200
v850_wait_100u_1:	dec	XH
			nop
			nop
			nop
			nop
			nop
			brne	v850_wait_100u_1
			ret


v850_slow_wait:		push	XH
			ldi	XH,200
v850_slow_wait_1:	dec	XH
			nop
			nop
			brne	v850_slow_wait_1
			pop	XH
			ret	

			
			;wait for SO LOW
v850_wait_send:		push	ZH
			push	ZL
			clr	ZL
			clr	ZH
			clt
v850_wait_send_1:	sbis	CTRLPIN,V850_SO		;1 SO
			rjmp	v850_wait_send_2			
			sbiw	ZL,1
			brne	v850_wait_send_1
			set					;timeout
v850_wait_send_2:	pop	ZL
			pop	ZH
			ret

			
			;wait for SO HIGH
v850_wait_recv:	push	ZH
			push	ZL
			clr	ZL
			clr	ZH
			clt
v850_wait_recv_1:	sbic	CTRLPIN,V850_SO		;1 SO
			rjmp	v850_wait_recv_2			
			sbiw	ZL,1
			brne	v850_wait_recv_1
			set					;timeout
v850_wait_recv_2:	pop	ZL
			pop	ZH
			ret
	
			
