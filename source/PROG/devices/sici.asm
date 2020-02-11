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
.equ	SICI_LINE	= SIG1

;------------------------------------------------------------------------------
; sici initialisierung
;------------------------------------------------------------------------------
sici_init:		cbi	CTRLPORT,SICI_LINE	;all to LOW
			cbi	CTRLDDR,SICI_LINE

			sbrc	r18,0
			rcall	wait_v

			call	api_vcc_on

			ldi	ZL,1			;5ms
			clr	ZH
			call	wait_ms

			call	api_resetptr
			clr	r16

			sbrc	r19,0
			rjmp	sici_init_1
			
			ldi	XH,0x07
			ldi	XL,0x71
			rcall	sici_xch_ver

			ldi	XH,0x47
			ldi	XL,0x11
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

sici_init_1:

			ldi	XH,0x06
			ldi	XL,0xC1
			rcall	sici_xch_ver

			ldi	XH,0x40
			ldi	XL,0x00
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

			ldi	ZL,8			;8ms
			clr	ZH
			call	wait_ms

			sbrc	r19,0
			rjmp	sici_init_2

			ldi	XH,0x06
			ldi	XL,0xC1
			rcall	sici_xch_ver

			ldi	XH,0xC0
			ldi	XL,0x00
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch



sici_init_2:		jmp	main_loop

sici_err:		ldi	r16,0x21
			jmp	main_loop


wait_v:			ldi	r24,0
			ldi	r25,30
wait_v_loop:		call	read_vext
			cpi	ZL,30
			brcc	wait_v_ok
			ldi	ZL,1
			ldi	ZH,0
			call	wait_ms
			sbiw	r24,1
			brne	wait_v_loop
			
			pop	r0
			pop	r0
			ldi	r16,0x43
			jmp	main_loop
			
wait_v_ok:		ret

;------------------------------------------------------------------------------
; sici exit
;------------------------------------------------------------------------------
sici_exit:		call	api_vcc_off
			ldi	ZL,50			;20ms
			clr	ZH
			call	wait_ms
			jmp	main_loop_ok

;------------------------------------------------------------------------------
; read working register 
;------------------------------------------------------------------------------
sici_rwork:		call	api_resetptr
			clr	r16

			ldi	XH,0x80
			ldi	XL,0x21
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

			jmp	main_loop


;------------------------------------------------------------------------------
; read EEPROM page
; PAR4 = PAGE 
;------------------------------------------------------------------------------
sici_rpage:		call	api_resetptr
			clr	r16
	
			ldi	XH,0x46
			ldi	XL,0x81
			rcall	sici_xch_ver

			ldi	XH,0x00
			mov	XL,r19
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch


			ldi	r21,0xC6
			ldi	r20,0x01
			rcall	sici_reep		

			ldi	r21,0x86
			ldi	r20,0x11
			rcall	sici_reep		

			ldi	r21,0x86
			ldi	r20,0x21
			rcall	sici_reep
					
			ldi	r21,0xC6
			ldi	r20,0x31
			rcall	sici_reep
					
			ldi	r21,0x86
			ldi	r20,0x41
			rcall	sici_reep
					
			ldi	r21,0xC6
			ldi	r20,0x51
			rcall	sici_reep
					
			ldi	r21,0xC6
			ldi	r20,0x61
			rcall	sici_reep
					
			ldi	r21,0x86
			ldi	r20,0x71
			rcall	sici_reep		
			
			jmp	main_loop

sici_reep:		movw	XL,r20		
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

			ldi	XH,0x00
			ldi	XL,0x00
			rjmp	sici_xch

;------------------------------------------------------------------------------
; read EEPROM page
; PAR4 = PAGE 
; PAR3 = dataset
;------------------------------------------------------------------------------
sici_wpage:		call	api_resetptr
			clr	r16
			inc	YH			;write to buffer pos 256...
			inc	YH			;write to buffer pos 512...
			inc	YH			;write to buffer pos 768...

			ldi	ZL,16
			mul	ZL,r18
			movw	ZL,r0
			inc	ZH
			
			ldi	XH,0x46
			ldi	XL,0x81
			rcall	sici_xch_ver

			ldi	XH,0x00
			mov	XL,r19
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch
			
			ldi	r21,0x06
			ldi	r20,0x01
			rcall	sici_weep		

			ldi	r21,0x46
			ldi	r20,0x11
			rcall	sici_weep		

			ldi	r21,0x46
			ldi	r20,0x21
			rcall	sici_weep
					
			ldi	r21,0x06
			ldi	r20,0x31
			rcall	sici_weep
					
			ldi	r21,0x46
			ldi	r20,0x41
			rcall	sici_weep
					
			ldi	r21,0x06
			ldi	r20,0x51
			rcall	sici_weep
					
			ldi	r21,0x06
			ldi	r20,0x61
			rcall	sici_weep
					
			ldi	r21,0x46
			ldi	r20,0x71
			rcall	sici_weep		
			

			ldi	XH,0x46
			ldi	XL,0x81
			rcall	sici_xch_ver

			ldi	XH,0x03
			ldi	XL,0xFF
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch
			

			ldi	XH,0x46
			ldi	XL,0x71
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x09
			rcall	sici_xch_ver

			ldi	XH,0x00
			ldi	XL,0x00
			rcall	sici_xch

			ldi	ZL,80
			ldi	ZH,0
			call	wait_ms	
			
			jmp	main_loop

sici_weep:		movw	XL,r20		
			rcall	sici_xch_ver

			ld	XL,Z+
			ld	XH,Z+
			rcall	sici_xch

			ldi	XH,0x00
			ldi	XL,0x00
			rjmp	sici_xch

;------------------------------------------------------------------------------
; exchange 16 bits	X->X
; - pulse start
; - 40 clocks
; - pulse end if 0
; - 80 clocks
; - pulse end
; - 40 clocks
; - puse start
; - 20 clocks
; - puse end
; - 40 clocks
; - sense
; - 160 clocks
;------------------------------------------------------------------------------
sici_xch_ver:		set
			rjmp	sici_xch_0
sici_xch:		clt
sici_xch_0:		ldi	r20,16
			movw	r10,XL
			call	api_buf_lwrite
			movw	XL,r10
sici_xch_loop:		sbi	CTRLDDR,SICI_LINE		;2
			ldi	r21,12				;1
sici_xch_w1:		dec	r21				;12
			brne	sici_xch_w1			;23
			nop					;1
			sbrs	XH,7				;1
			cbi	CTRLDDR,SICI_LINE		;2 release if zero

			sbrc	XH,7				;1
			sbi	CTRLDDR,SICI_LINE		;1 dummy
			
			ldi	r21,39				;1
sici_xch_w2:		dec	r21				;39
			brne	sici_xch_w2			;77
			cbi	CTRLDDR,SICI_LINE		;2 master bitend
			
			
			ldi	r21,12				;1
sici_xch_w3:		dec	r21				;12
			brne	sici_xch_w3			;23
				
			lsl	XL				;1 shift left
			rol	XH				;1 shift
	
			
			sbi	CTRLDDR,SICI_LINE		;2 sensor bit start
			
			ldi	r21,6				;1
sici_xch_w4:		dec	r21				;6
			brne	sici_xch_w4			;11
			
			cbi	CTRLDDR,SICI_LINE		;2 sensor bit
			
			ldi	r21,19				;1
sici_xch_w5:		dec	r21				;19
			brne	sici_xch_w5			;37
			
			sbis	CTRLPIN,SICI_LINE		;1
			inc	XL
			
			ldi	r21,50				;1
sici_xch_w6:		dec	r21				;19
			brne	sici_xch_w6			;37
			
			dec	r20
			brne	sici_xch_loop


			ldi	r21,100				;1
sici_xch_w7:		dec	r21				;19
			brne	sici_xch_w7			;37


			brtc	sici_xch_end
			cp	XL,r10
			brne	sici_xch_err
			cp	XH,r11
			brne	sici_xch_err
			
sici_xch_end:		jmp	api_buf_lwrite		
			
sici_xch_err:		ldi	r16,0x42
			jmp	api_buf_lwrite		
			
