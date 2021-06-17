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

.equ		UPDI_DATA	= SIG1

.macro RECV_UPDI
			call	updi_recv
.endm

.macro SEND_UPDI
			call	updi_send
			rcall	updi_wait_40us
.endm

.macro SEND_UPDI_LAST
			call	updi_send
.endm

.macro SEND_UPDI_SYNC
			ldi	XL,0x55
			call	updi_send
			rcall	updi_wait_40us
.endm

;------------------------------------------------------------------------------
; init
;------------------------------------------------------------------------------
updi_init_err2:		rjmp	updi_init_err

updi_init:		call	api_vcc_on
			sbi	PORTD,6			;set to one
			sbi	DDRD,6			;set to output
			ldi	ZL,100
			ldi	ZH,0
			call	api_wait_ms
			cpi	r19,0
			breq	updi_init_1
			
			call	api_vpp_on
			rcall	updi_wait_40us
			rcall	updi_wait_40us
			rcall	updi_wait_40us
			call	api_vpp_off
			
			ldi	ZL,30		
updi_init_w0:		dec	ZL
			brne	updi_init_w0
			
updi_init_1:		cbi	PORTD,6
			nop
			nop
			nop
			nop
			nop
			sbi	PORTD,6
			ldi	XL,0
			ldi	XH,10
updi_init_w1:		sbiw	XL,1
			breq	updi_init_err2
			sbis	CTRLPIN,UPDI_DATA
			rjmp	updi_init_w1
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms

			SEND_UPDI_SYNC		
			ldi	XL,0xC2			;UPDI GUARD TIME = 4 cycles			
			SEND_UPDI
			ldi	XL,0x05
			SEND_UPDI
			jmp	main_loop_ok
			
;------------------------------------------------------------------------------
; read ID and fuses
;------------------------------------------------------------------------------
updi_read_id:		call	api_resetptr		;set ptr
			movw	r6,r16
			rcall	updi_nvmkey
			
			ldi	r20,3			;bytes to read		
updi_rid_loop:		SEND_UPDI_SYNC
			
			ldi	XL,0x04			;LDS (A16/B8)			
			SEND_UPDI
			mov	XL,r18
			SEND_UPDI
			mov	XL,r19
			SEND_UPDI_LAST

			RECV_UPDI
			brtc	updi_init_err
			call	api_buf_bwrite

			rcall	updi_wait_40us

			inc	r18			;next addr
			dec	r20			;counter
			brne	updi_rid_loop

			ldi	r20,13			;bytes to read		
updi_rfs_loop:		SEND_UPDI_SYNC
			
			ldi	XL,0x04			;LDS (A16/B8)			
			SEND_UPDI
			mov	XL,r6
			SEND_UPDI
			mov	XL,r7
			SEND_UPDI_LAST

			RECV_UPDI
			brtc	updi_init_err
			call	api_buf_bwrite

			rcall	updi_wait_40us

			inc	r6			;next addr
			dec	r20			;counter
			brne	updi_rfs_loop
			
			jmp	main_loop_ok

updi_init_err:		ldi	r16,0x41		;timeout
			jmp	main_loop


updi_init_data:		.db	0x55,0xe0,0x20,0x67,0x6F,0x72,0x50,0x4d,0x56,0x4e


;------------------------------------------------------------------------------
; run device
;------------------------------------------------------------------------------
updi_exit:		out	CTRLPORT,const_0	;-> all zero
			call	api_vcc_off
			out	CTRLDDR,const_0		;-> tristate
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; NVM lesen (2K)
; PAR1/2 = address
; PAR3/4 = size
;------------------------------------------------------------------------------
updi_read_mem:		call	api_resetptr
			lsr	r19			;/2, we use 16 bits
			ror	r18	
			inc	r19

			SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			mov	XL,r16			;LOW addr
			SEND_UPDI
			mov	XL,r17			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_read_err		
			rcall	updi_wait_40us

updi_read_mem_1:	SEND_UPDI_SYNC			
			ldi	XL,0xA0			;REPEAT			
			SEND_UPDI
			mov	XL,r18			;LOW addr
			dec	XL
			SEND_UPDI_LAST
		
			rcall	updi_wait_40us

			SEND_UPDI_SYNC
			ldi	XL,0x25			;read words			
			SEND_UPDI_LAST

			mov	r24,r18

updi_read_mem_2:	RECV_UPDI			;get LSB
			brtc	updi_read_err		
			call	api_buf_bwrite

			RECV_UPDI			;get LSB
			brtc	updi_read_err		
			call	api_buf_bwrite

			dec	r24
			brne	updi_read_mem_2

			rcall	updi_wait_40us
		
			dec	r19
			brne	updi_read_mem_1

			jmp	main_loop_ok

updi_read_err:		ldi	r16,0x41		;timeout
			jmp	main_loop



;------------------------------------------------------------------------------
; EEP lesen (2K)
; PAR1/2 = address
; PAR4   = size in 32B blocks
;------------------------------------------------------------------------------
updi_read_eeprom:	call	api_resetptr

			SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			mov	XL,r16			;LOW addr
			SEND_UPDI
			mov	XL,r17			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_read_eep_err		
			rcall	updi_wait_40us

updi_read_eep_1:	SEND_UPDI_SYNC			
			ldi	XL,0xA0			;REPEAT			
			SEND_UPDI
			ldi	XL,0x1F			;32 bytes
			SEND_UPDI_LAST
		
			rcall	updi_wait_40us

			SEND_UPDI_SYNC
			ldi	XL,0x24			;read bytes			
			SEND_UPDI_LAST

			ldi	r24,0x20

updi_read_eep_2:	RECV_UPDI			;get LSB
			brtc	updi_read_eep_err		
			call	api_buf_bwrite

			dec	r24
			brne	updi_read_eep_2

			rcall	updi_wait_40us
		
			dec	r19
			brne	updi_read_eep_1

			jmp	main_loop_ok

updi_read_eep_err:	ldi	r16,0x41		;timeout
			jmp	main_loop




;------------------------------------------------------------------------------
; erase
;------------------------------------------------------------------------------
updi_erase:		ldi	ZL,LOW(updi_erase_data*2)
			ldi	ZH,HIGH(updi_erase_data*2)
		
			rcall	updi_sendkey

updi_erase_wait:	ldi	ZL,10
			ldi	ZH,0
			call	api_wait_ms
			
			SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read status			
			SEND_UPDI_LAST
		
			RECV_UPDI			;get ststus
			brtc	updi_erase_err		
			
			andi	XL,0x01
			brne	updi_erase_wait
			
			jmp	main_loop_ok

updi_erase_data:	.db	0x55,0xe0,0x65,0x73,0x61,0x72,0x45,0x4d,0x56,0x4e


updi_erase_err:		ldi	r16,0x41		;timeout
			jmp	main_loop


;------------------------------------------------------------------------------
; flash program
; Param 1/2 = Address
; Param 3 = Page size (bytes)
; Param 4 = num of pages
;------------------------------------------------------------------------------
updi_prog_err2:		rjmp	updi_prog_err

updi_prog_main:		movw	r6,r16			;store address			

			call	api_resetptr
			rcall	updi_nvmkey
			
updi_prog_main_0:	SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			brtc	updi_prog_err2		
			rcall	updi_wait_40us
			andi	XL,0x08
;			breq	updi_prog_main_0			
			
updi_prog_main_1:	SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			mov	XL,r6			;LOW addr
			SEND_UPDI
			mov	XL,r7			;HIGH addr
;			ldi	XL,0x30	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_err2		
			rcall	updi_wait_40us
			
			SEND_UPDI_SYNC			
			ldi	XL,0xA0			;REPEAT			
			SEND_UPDI
			mov	XL,r18			;page size
			lsr	XL
			dec	XL
			SEND_UPDI_LAST

			rcall	updi_wait_40us
			
			SEND_UPDI_SYNC			
			ldi	XL,0x65			;write words			
			SEND_UPDI
						
			mov	r23,r18
			lsr	r23
			
updi_prog_main_2:	call	api_buf_bread
			SEND_UPDI
			call	api_buf_bread
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			brtc	updi_prog_err		
			rcall	updi_wait_40us

			dec	r23
			brne	updi_prog_main_2			
			
			ldi	r22,0x01
			rcall	updi_nvm_cmd

updi_prog_main_3:	SEND_UPDI_SYNC			
			ldi	XL,0x04			;LDS status			
			SEND_UPDI
			ldi	XL,0x02			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_err		
			rcall	updi_wait_40us
	
			andi	XL,0x03
			brne	updi_prog_main_3
			
			add	r6,r18
			adc	r7,const_0
			
			dec	r19
			breq	updi_prog_ok
			rjmp	updi_prog_main_1
			
updi_prog_ok:		jmp	main_loop_ok

updi_prog_err:		ldi	r16,0x42
			jmp	main_loop


;------------------------------------------------------------------------------
; eeprom program
; Param 1-3 = Address
; Param4 = pages (a 32 bytes)
;------------------------------------------------------------------------------
updi_erase_eeprom:	call	api_resetptr
			rcall	updi_nvmkey

			ldi	r22,0x06
			rcall	updi_nvm_cmd

updi_erase_eep_1:	SEND_UPDI_SYNC			
			ldi	XL,0x04			;LDS status			
			SEND_UPDI
			ldi	XL,0x02			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_err		
			rcall	updi_wait_40us
	
			andi	XL,0x03
			brne	updi_erase_eep_1

			jmp	main_loop_ok

;------------------------------------------------------------------------------
; eeprom program
; Param 1/2 = Address
; Param 3 = Page size (bytes)
; Param 4 = num of pages
;------------------------------------------------------------------------------
updi_prog_err3:		rjmp	updi_prog_err

updi_prog_eeprom:	movw	r6,r16			;store address			

			call	api_resetptr
			rcall	updi_nvmkey
			
updi_prog_eep_0:	SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			brtc	updi_prog_err3		
			rcall	updi_wait_40us
			andi	XL,0x08
;			breq	updi_prog_eep_0			
			
updi_prog_eep_1:	SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			mov	XL,r6			;LOW addr
			SEND_UPDI
			mov	XL,r7			;HIGH addr
;			ldi	XL,0x30	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_err3		
			rcall	updi_wait_40us
			
			SEND_UPDI_SYNC			
			ldi	XL,0xA0			;REPEAT			
			SEND_UPDI
			mov	XL,r18			;page size
			dec	XL
			SEND_UPDI_LAST

			rcall	updi_wait_40us
			
			SEND_UPDI_SYNC			
			ldi	XL,0x64			;write bytes			
			SEND_UPDI
						
			mov	r23,r18
			
updi_prog_eep_2:	call	api_buf_bread
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			brtc	updi_prog_err4		
			rcall	updi_wait_40us

			dec	r23
			brne	updi_prog_eep_2			
			
			ldi	r22,0x03
			rcall	updi_nvm_cmd

updi_prog_eep_3:	SEND_UPDI_SYNC			
			ldi	XL,0x04			;LDS status			
			SEND_UPDI
			ldi	XL,0x02			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_err4		
			rcall	updi_wait_40us
	
			andi	XL,0x03
			brne	updi_prog_eep_3
			
			add	r6,r18
			adc	r7,const_0
			
			dec	r19
			breq	updi_prog_eep_ok
			rjmp	updi_prog_eep_1
			
updi_prog_eep_ok:	jmp	main_loop_ok

updi_prog_err4:		ldi	r16,0x42
			jmp	main_loop


;------------------------------------------------------------------------------
; write fuse
; Param 3 = fuse no
; Param 4 = fuse data 
;------------------------------------------------------------------------------
updi_prog_fuse:		rcall	updi_nvmkey

			SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			ldi	XL,0x06			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr
			SEND_UPDI_LAST

			RECV_UPDI			;get ACK
			brtc	updi_prog_fuse_err		
			rcall	updi_wait_40us
	
			mov	r22,r19
			rcall	updi_stinc_b

			clr	r22
			rcall	updi_stinc_b
			
			mov	r22,r18
			ori	r22,0x80
			rcall	updi_stinc_b
			
			ldi	r22,0x12
			rcall	updi_stinc_b
			
			ldi	r22,0x07
			rcall	updi_nvm_cmd

updi_prog_fuse_1:	SEND_UPDI_SYNC			
			ldi	XL,0x04			;LDS status			
			SEND_UPDI
			ldi	XL,0x02			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_prog_fuse_err		
			rcall	updi_wait_40us
	
			sts	0x100,XL
			andi	XL,0x03
			brne	updi_prog_fuse_1
			
			jmp	main_loop_ok
			
updi_prog_fuse_err:	ldi	r16,0x41
			jmp	main_loop
			
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; write user row
; Param 1,2 = RAM start
; Param 4 = row size
;------------------------------------------------------------------------------
updi_prog_user:		call	api_resetptr
			rcall	updi_urowkey

			SEND_UPDI_SYNC			
			ldi	XL,0x69			;write PTR			
			SEND_UPDI
			mov	XL,r16			;LOW addr
			SEND_UPDI
			mov	XL,r17			;HIGH addr
			SEND_UPDI_LAST

			RECV_UPDI			;get ACK
			brtc	updi_prog_fuse_err		
			rcall	updi_wait_40us

			
updi_prog_user_1:	call	api_buf_bread
			mov	r22,XL
			rcall	updi_stinc_b
			dec	r19
			brne	updi_prog_user_1
			rcall	updi_wait_40us


			SEND_UPDI_SYNC			
			ldi	XL,0xCA			;STCS CTRLA		
			SEND_UPDI
			ldi	XL,0x02			;write final
			SEND_UPDI_LAST
			rcall	updi_wait_40us

			ldi	r22,0

updi_prog_user_2:	SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			rcall	updi_wait_40us
			rcall	updi_wait_40us
			sbrs	XL,2
			jmp	updi_prog_user_3
			dec	r22
			brne	updi_prog_user_2
			ldi	r16,0x41
			jmp	main_loop
				
			
updi_prog_user_3:	SEND_UPDI_SYNC			
			ldi	XL,0xC7			;STCS ASI_KEY_STATUS		
			SEND_UPDI
			ldi	XL,0x20			;UROWWRITE
			SEND_UPDI_LAST

			rcall	updi_xreset

			jmp	main_loop_ok
	


;------------------------------------------------------------------------------
; send data from table and reveive ack
; XL=data
;------------------------------------------------------------------------------
updi_send_table:	lpm	XL,Z+
			SEND_UPDI
			dec	r24
			brne	updi_send_table
			lpm	XL,Z+
			SEND_UPDI_LAST
			ret


updi_reset_cpu:		SEND_UPDI_SYNC			
			ldi	XL,0xC8			
			SEND_UPDI
			ldi	XL,0x59
			SEND_UPDI_LAST
			rcall	updi_wait_40us
			SEND_UPDI_SYNC			
			ldi	XL,0xC8			
			SEND_UPDI
			ldi	XL,0x00
			SEND_UPDI_LAST
			rjmp	updi_wait_40us

updi_reset_cpu_1:	SEND_UPDI_SYNC			
			ldi	XL,0x8B			
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ststus
			brts	updi_reset_cpu_2
			pop	r16
			pop	r16
			ldi	r16,0x42
			jmp	main_loop
			
updi_reset_cpu_2:	andi	XL,0x0E
			breq	updi_reset_cpu_1
			ret

;------------------------------------------------------------------------------
; write NVM Key if not already enabled
;------------------------------------------------------------------------------
updi_nvmkey:		SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			rcall	updi_wait_40us
			sbrc	XL,3
			ret

			ldi	ZL,LOW(updi_nvmk_data*2)
			ldi	ZH,HIGH(updi_nvmk_data*2)

			rcall	updi_sendkey

			ldi	r22,0

updi_nvmkey_1:		SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			rcall	updi_wait_40us
			sbrc	XL,3
			ret
			dec	r22
			brne	updi_nvmkey_1
			pop	r16
			pop	r16
			ldi	r16,0x45
			jmp	main_loop
			


updi_nvmk_data:		.db	0x55,0xe0,0x20,0x67,0x6F,0x72,0x50,0x4d,0x56,0x4e

;------------------------------------------------------------------------------
; write USERROW Key if not already enabled
;------------------------------------------------------------------------------
updi_urowkey:		SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			rcall	updi_wait_40us
			sbrc	XL,2
			ret

			ldi	ZL,LOW(updi_urowk_data*2)
			ldi	ZH,HIGH(updi_urowk_data*2)

			rcall	updi_sendkey

			ldi	r22,0

updi_urowkey_1:		SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
			rcall	updi_wait_40us
			sbrc	XL,2
			ret
			dec	r22
			brne	updi_urowkey_1
			pop	r16
			pop	r16
			ldi	r16,0x45
			jmp	main_loop


updi_urowk_data:	.db	0x55,0xe0,0x65,0x74,0x26,0x73,0x55,0x4d,0x56,0x4e


updi_sendkey:		ldi	r24,9
			rcall	updi_send_table
			rcall	updi_wait_40us

			SEND_UPDI_SYNC			
			ldi	XL,0x8B			;read ASI-SYS-STATUS			
			SEND_UPDI_LAST
			RECV_UPDI			;get ACK
updi_xreset:		rcall	updi_wait_40us	
			rcall	updi_reset_cpu
			rjmp	updi_wait_40us			

;------------------------------------------------------------------------------
; write NVM command (R22)
;------------------------------------------------------------------------------
updi_nvm_cmd:		;now store the CMD			
			SEND_UPDI_SYNC			
			ldi	XL,0x44			;write PTR			
			SEND_UPDI
			ldi	XL,0x00			;LOW addr
			SEND_UPDI
			ldi	XL,0x10			;HIGH addr	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_nvm_cmd_err		
			rcall	updi_wait_40us
					
			mov	XL,r22			;CMD	
			SEND_UPDI_LAST
			
			RECV_UPDI			;get ACK
			brtc	updi_nvm_cmd_err		
			rjmp	updi_wait_40us


updi_nvm_cmd_err:	pop	r16
			pop	r16
			ldi	r16,0x43
			jmp	main_loop



;------------------------------------------------------------------------------
; write byte (R22) to *ptr++
;------------------------------------------------------------------------------
updi_stinc_b:		SEND_UPDI_SYNC			
			ldi	XL,0x64			;write PTR			
			SEND_UPDI
			mov	XL,r22
			SEND_UPDI_LAST

			RECV_UPDI			;get ACK
			brtc	updi_sub_err		
			rjmp	updi_wait_40us

updi_sub_err:		pop	r16
			pop	r16
			ldi	r16,0x41
			jmp	main_loop


;------------------------------------------------------------------------------
; wait n clocks
;------------------------------------------------------------------------------
updi_wait_40us:		push	ZL
			ldi	ZL,0			; num of clocks
updi_wait_40us_1:	dec	ZL
			brne	updi_wait_40us_1
			pop	ZL
			ret
		
;-------------------------------------------------------------
; send one byte with 115K/s
; 174 clocks/bit
; XL = Data
;-------------------------------------------------------------
updi_send:		push	ZL
			push	ZH
			push	XL
			push	XH
			push	r20
			clr	r20
updi_send_0:	sbi	PORTD,6			;2 set to one
			sbi	DDRD,6			;2 set to one
			in	XH,PORTD		;1
			andi	XH,0xbf			;1 clear bit
			out	PORTD,XH		;1
			ldi	ZH,8			;1 bits to do (+ Start bit)
			nop				;1 filling
			nop				;1 filling
			nop				;1 filling
updi_send_1:	ldi	ZL,30			;165 (n*3)
updi_send_2:	dec	ZL
			brne	updi_send_2
			eor	r20,XL			;1 parity
			in	XH,PORTD		;1
			andi	XH,0xbf			;1 clear bit
			sec				;1 set carry
			ror	XL			;1
			brcc	updi_send_3		;2
			ori	XH,0x40			;  set bit
updi_send_3:	out	PORTD,XH		;1
			dec	ZH			;1
			brne	updi_send_1		;2
		
updi_send_4:	ldi	ZL,30			;165 (n*3)
updi_send_5:	dec	ZL
			brne	updi_send_5
			in	XH,PORTD		;1
			andi	XH,0xbf			;1 clear bit
			sec				;1 set carry
			ror	r20			;1
			brcc	updi_send_6		;2
			ori	XH,0x40			;  set bit
updi_send_6:	out	PORTD,XH		;1

			ldi	ZL,32			;165 (n*3)
updi_send_7:	dec	ZL
			brne	updi_send_7
		
			ori	XH,0x40			;  set bit
			out	PORTD,XH		;1
			
			ldi	ZL,30			;165
updi_send_8:	dec	ZL
			brne	updi_send_8
			cbi	DDRD,6			;2 set to one
			cbi	PORTD,6			;2 set to one
			pop	r20
			pop	XH
			pop	XL
			pop	ZH
			pop	ZL
			ret

;-------------------------------------------------------------
; receive one byte with 115K/s (UPD)
; 174 clocks/bit
; XL = Data
;-------------------------------------------------------------
updi_recv:		cbi	CTRLDDR,SIG1
			push	ZL
			push	ZH
			clr	ZL			;timeout
			clr	ZH
			set				;OK
updi_recv_1:		sbis	CTRLPIN,SIG1		;wait for start bit
			rjmp	updi_recv_2a
			sbiw	ZL,1
			brne	updi_recv_1
			clt				;timeout
			pop	ZH
			pop	ZL
			ret

updi_recv_2a:		ldi	ZL,45			;x 1,5
updi_recv_2:		dec	ZL
			brne	updi_recv_2

			ldi	ZH,8			;1 8 bits

updi_recv_3:		lsr	XL			;1
			sbic	CTRLPIN,SIG1		;2
			ori	XL,0x80

			ldi	ZL,31			;15
updi_recv_4:		dec	ZL
			brne	updi_recv_4	

			dec	ZH			;1
			brne	updi_recv_3		;2

			ldi	ZL,45			;x1,5
updi_recv_5:		dec	ZL
			brne	updi_recv_5
			pop	ZH
			pop	ZL
			ret