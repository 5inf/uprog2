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

.equ		R8C_RESET	= SIG1
.equ		R8C_MODE	= SIG2

.macro r8c_check_status
		ldi	r23,HIGH(@0)
		ldi	r22,LOW(@0)
		rcall	r8c_check
.endm
; 
;-------------------------------------------------------------------------------
; init BM
;-------------------------------------------------------------------------------
r8c_init:	out	CTRLPORT,const_0
		sbi	CTRLDDR,R8C_MODE		;mode
		sbi	CTRLDDR,R8C_RESET		;nrst
		call	api_vcc_on		;power on
		ldi	ZL,50
		clr	ZH
		call	api_wait_ms
		sbi	CTRLPORT,R8C_RESET		;release reset
		ldi	ZL,50
		clr	ZH
		call	api_wait_ms
		sbi	CTRLPORT,R8C_MODE		;release mode
		ldi	ZL,LOW(300)
		ldi	ZH,HIGH(300)
		call	api_wait_ms
		set				;set OK bit
		ldi	r20,16
r8c_init_1:	clr	XL
		call	send2_9600
		ldi	ZL,22
		clr	ZH
		call	api_wait_ms
		dec	r20
		brne	r8c_init_1
		;set bitrate 9600
		ldi	XL,0xb0
		call	send2_9600
		call	recv2_9600
		ldi	r16,0x46		;error timeout
		brtc	r8c_err
		ldi	r16,0x42		;error wrong answer B0
		cpi	XL,0xb0
;		brne	r8c_err

		;set bitrate 500K
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
;		ldi	XL,0xb7			;standard bitrate setting
		ldi	XL,0xb5			;bitrate setting
		call	send2_9600
		ldi	ZL,1
		ldi	ZH,0
		call	api_wait_ms
;		ldi	XL,0x08			;500K
		ldi	XL,0x00			;500K
		call	send2_9600
		call	recv2_9600
		ldi	r16,0x41		;error timeout
		brtc	r8c_err		;timeout
;		ldi	r16,0x43		;error wrong answer B7
;		cpi	XL,0xb7
;		brne	r8c_err		;wrong answer
		jmp	main_loop_ok

r8c_exit:	out	CTRLPORT,const_0
		sbi	CTRLDDR,R8C_MODE		;mode
		sbi	CTRLDDR,R8C_RESET		;nrst
		ldi	ZL,50
		clr	ZH
		call	api_wait_ms
		call	api_vcc_off
		out	CTRLDDR,const_0
		jmp	main_loop_ok

r8c_err:	sts	0x100,XL		;save wrong result
		jmp	main_loop

r8c_uswait:	push	XL
		mov	XL,XH
r8c_uswait_1:	dec	XL
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		dec	XL
		brne	r8c_uswait_1
		pop	XL
		ret

;-------------------------------------------------------------------------------
; exec
;-------------------------------------------------------------------------------
r8c_exec:	clr	r19			;checksum
		movw	ZL,r16			;number of bytes
		call	api_resetptr

r8c_exec_1:	call	api_buf_bread
		add	r19,XL
		sbiw	ZL,1
		brne	r8c_exec_1

		ldi	XL,0xfa			;download
		call	send2_500k
		movw	r22,r16			;number of bytes
		mov	XL,r22			;LOW num
		call	send2_500k
		mov	XL,r23			;HIGH num
		call	send2_500k
		mov	XL,r19			;checksum
		call	send2_500k
		call	api_resetptr
r8c_exec_2:	call	api_buf_bread
		call	send2_500k
		sub	r22,const_1
		sbc	r23,const_0
		brne	r8c_exec_2
		clr	r16
		jmp	main_loop


;-------------------------------------------------------------------------------
; exec, r19=checksum
;-------------------------------------------------------------------------------
r8c_exec2:	call	api_resetptr
		ldi	XL,0xfa			;download
		call	send2_500k
		mov	XL,r16			;LOW num
		call	send2_500k
		mov	XL,r17			;HIGH num
		call	send2_500k
		mov	XL,r19			;checksum
		call	send2_500k
		ldi	r24,0			;2K
		ldi	r25,8
r8c_exec2_2:	call	api_buf_bread
		call	send2_500k
		sbiw	r24,1
		brne	r8c_exec2_2
		clr	r16
		jmp	main_loop


r8c_exec3:	call	api_resetptr
		movw	r24,r16
		rjmp	r8c_exec2_2		

;-------------------------------------------------------------------------------
; unlock
;-------------------------------------------------------------------------------
r8c_unlock:	rcall	r8c_clearstat
		ldi	XL,0xf5
		call	send2_500k
		ldi	XL,0xdf
		call	send2_500k
		ldi	XL,0xff
		call	send2_500k
		ldi	XL,0x00
		call	send2_500k
		ldi	XL,0x07
		call	send2_500k
		call	api_resetptr
		ldi	r20,7
r8c_unlock_2:	call	api_buf_bread
		call	send2_500k
		dec	r20
		brne	r8c_unlock_2
		ldi	ZL,0
		ldi	ZH,1
		call	api_wait_ms
		r8c_check_status 50000
		jmp	main_loop

;-------------------------------------------------------------------------------
; erase
;-------------------------------------------------------------------------------
r8c_erase:	call	api_resetptr
r8c_erase_1:	call	api_buf_bread		;HIGH addr
		mov	r23,XL
		call	api_buf_bread		;MID addr
		mov	r22,XL
		or	XL,r23
		breq	r8c_erase_2		;empty

		rcall	r8c_clearstat
		ldi	XL,0x20
		call	send2_500k
		mov	XL,r22			;mid addr
		call	send2_500k
		mov	XL,r23			;HIGH addr
		call	send2_500k
		ldi	XL,0xd0
		call	send2_500k
		ldi	ZL,0
		ldi	ZH,2
		call	api_wait_ms
		r8c_check_status 50000
r8c_erase_2:	cpi	YL,0x10			;max 8 blocks
		brne	r8c_erase_1
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; read/write lock bits
; par2 : HIGH addr
; par1 : MID addr
; par4 : 0x57=write, 0x58 read, 0x59 reset
;-------------------------------------------------------------------------------
r8c_lock:	mov	XL,r19			;PAR4
		call	send2_500k
		mov	XL,r17			;HIGH addr
		call	send2_500k
		mov	XL,r16			;MID addr
		call	send2_500k

		call	recv2_500k		;get result
		sts	0x100,XL		
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; program
;-------------------------------------------------------------------------------
r8c_prog:	movw	r24,r16			;addr
		call	api_resetptr		;ptr=0

r8c_prog_1:	rcall	r8c_clearstat
		ldi	XL,0x41
		call	send2_500k
		mov	XL,r24			;MID addr
		call	send2_500k
		mov	XL,r25			;HIGH addr
		call	send2_500k

		clr	r20			;256 bytes
r8c_prog_2:	call	api_buf_bread
		call	send2_500k
		dec	r20
		brne	r8c_prog_2

		ldi	ZL,5
		ldi	ZH,0
		call	api_wait_ms

		r8c_check_status 20000

		adiw	r24,1			;next page
		dec	r18
		brne	r8c_prog_1
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; blank check
;-------------------------------------------------------------------------------
r8c_blank:	rcall	r8c_clearstat
		ldi	XL,0x26
		call	send2_500k
		ldi	XL,0xD0
		call	send2_500k
		ldi	ZL,10
		ldi	ZH,0
		call	api_wait_ms
		r8c_check_status 5000
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read
;-------------------------------------------------------------------------------
r8c_read:	movw	r24,r16			;addr
		call	api_resetptr		;ptr=0

r8c_read_1:	ldi	XL,0xff
		call	send2_500k
		mov	XL,r24			;MID addr
		call	send2_500k
		mov	XL,r25			;HIGH addr
		call	send2_500k

		ldi	r19,0x00		;256 bytes
r8c_read_2:	call	recv2_500k
		brtc	r8c_read_e		;error
		call	api_buf_bwrite
		dec	r19
		brne	r8c_read_2

		ldi	ZL,2
		clr	ZH
		call	api_wait_ms

		adiw	r24,1			;next page
		dec	r18
		brne	r8c_read_1
		jmp	main_loop_ok


r8c_read_e:	sts	0x120,YL
		sts	0x121,YH
		sts	0x122,r18
		ldi	XL,0x55
		sts	0x123,XL
		ldi	r16,0x40
		jmp	main_loop


;-------------------------------------------------------------------------------
; get version
;-------------------------------------------------------------------------------
r8c_version:	call	api_resetptr
		ldi	XL,0xfb
		call	send2_500k

		ldi	r19,8			;8 bytes
r8c_readv_2:	call	recv2_500k
		brtc	r8c_read_e		;error
		call	api_buf_bwrite
		dec	r19
		brne	r8c_readv_2
		clr	XL
		call	api_buf_bwrite
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; clear status register
;-------------------------------------------------------------------------------
r8c_clearstat:	set
		ldi	XL,0x50
		jmp	send2_500k

;--------------------------------------------------------------------------------
; chaeck for r22/r23 milliseconds the status register
;--------------------------------------------------------------------------------
r8c_check:	set				;OK
r8c_check_1:	ldi	ZL,10			;wait 10ms
		ldi	ZH,0
		call	api_wait_ms
		sts	0x120,const_0		;debug
		sts	0x121,const_0
		sts	0x122,const_0
		sts	0x123,const_0

		ldi	XL,0x70			;read status register
		call	send2_500k
		call	recv2_500k
		mov	r20,XL			;SRD
		brtc	r8c_check_to		;error (timeout)
		call	recv2_500k
		mov	r21,XL			;SRD1
		brtc	r8c_check_to2		;error (timeout)
		sbrc	r20,7
		rjmp	r8c_check_2		;ready received
		sub	r22,const_1
		sbc	r23,const_0
		brne	r8c_check_1		;wait again
		ldi	r16,0x45		;0x45 - no ready
		rjmp	r8c_check_err

r8c_check_2:	sts	0x120,r20		;debug (SRD)
		sts	0x121,r21		;debug (SRD1)
		sts	0x122,r22		;debug (cnt low)
		sts	0x123,r23		;debug (cnt high)
		andi	r20,0x30		;0x49-0x4b srd error
		breq	r8c_check_3
		swap	r20
		ldi	r16,0x48
		add	r16,r20
		rjmp	r8c_check_err

r8c_check_3:	andi	r21,0x0c		;0x4c-0x4e srd1 error
		cpi	r21,0x0c
		breq	r8c_check_ok
		lsr	r21
		lsr	r21
		ldi	r16,0x4c
		add	r16,r21
		rjmp	r8c_check_err

r8c_check_ok:	clr	r16			;OK
;		ldi	r16,0x33
		ret

r8c_check_to:	ldi	r16,0x40		;0x40 - time out
r8c_check_err:	pop	r0			;kill stack
		pop	r0
		jmp	main_loop

r8c_check_to2:	ldi	r16,0x50		;0x50 - time out
r8c_check_er2:	pop	r0			;kill stack
		pop	r0
		jmp	main_loop
